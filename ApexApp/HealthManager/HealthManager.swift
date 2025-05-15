import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthManager {
    static let shared = HealthManager()
    
    private let healthStore: HKHealthStore
    
    private init() {
        self.healthStore = HKHealthStore()
        requestHealthKitAuthorization()
    }
    
    //MARK: - Запрос доступа к applehealth
    private func requestHealthKitAuthorization() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            print("Не удалось создать типы HealthKit")
            return
        }
        
        let healthTypes: Set<HKSampleType> = [stepType, caloriesType, distanceType, bodyMassType]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("Ошибка авторизации HealthKit: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - получаем шаги
    func fetchTodaySteps(completion: @escaping (String) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion("0")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: stepsType,
                                    quantitySamplePredicate: predicate) { _, result, error in
            if let error = error {
                print("Ошибка получения шагов: \(error.localizedDescription)")
                completion("0")
                return
            }
            
            guard let result = result, let quantity = result.sumQuantity() else {
                completion("0")
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            completion(String(format: "%.0f", stepCount))
        }
        
        healthStore.execute(query)
    }
    //MARK: - получаем калории
    func fetchTodayCalories(completion: @escaping (String) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion("0")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: caloriesType,
                                    quantitySamplePredicate: predicate) { _, result, error in
            if let error = error {
                print("Ошибка получения калорий: \(error.localizedDescription)")
                completion("0")
                return
            }
            
            guard let result = result, let quantity = result.sumQuantity() else {
                completion("0")
                return
            }
            
            let calories = quantity.doubleValue(for: .kilocalorie())
            completion(String(format: "%.0f", calories))
        }
        
        healthStore.execute(query)
    }
    //MARK: - получаем дистанцию в км
    func fetchTodayDistance(completion: @escaping (String) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion("0")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: distanceType,
                                    quantitySamplePredicate: predicate) { _, result, error in
            if let error = error {
                print("Ошибка получения дистанции: \(error.localizedDescription)")
                completion("0")
                return
            }
            
            guard let result = result, let quantity = result.sumQuantity() else {
                completion("0")
                return
            }
            
            let distanceInKilometers = quantity.doubleValue(for: .meterUnit(with: .kilo))
            completion(String(format: "%.2f", distanceInKilometers))
        }
        
        healthStore.execute(query)
    }
    //MARK: - получаем вес пользователя
    func fetchBodyMass(completion: @escaping (String) -> Void) {
            guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
                completion("0")
                return
            }
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: bodyMassType,
                                    predicate: nil,
                                    limit: 1,
                                    sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    print("Ошибка получения массы тела: \(error.localizedDescription)")
                    completion("0")
                    return
                }
                
                guard let samples = samples, let mostRecentSample = samples.first as? HKQuantitySample else {
                    completion("0")
                    return
                }
                
                let weightInKilograms = mostRecentSample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                completion(String(format: "%.1f", weightInKilograms))
            }
            
            healthStore.execute(query)
        }
}
