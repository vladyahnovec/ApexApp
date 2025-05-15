import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // MARK: - Навигация
            VStack {
                if vm.currentView == "Auth" {
                    AuthView(vm: vm)
                }
                else if vm.currentView == "Home" {
                    HomeView(vm: vm)
                }
                else if vm.currentView == "ListOfTraining" {
                    ListOfTraining(vm: vm)
                }
                else if vm.currentView == "ListOfTrainingDetails" {
                    ListOfTrainingDetails(vm: vm)
                }
                else if vm.currentView == "CreateTraining" {
                    CreateTraining(vm: vm)
                }
                else if vm.currentView == "ExerciseDetails" {
                    ExerciseDetails(vm: vm)
                }
                else if vm.currentView == "Registration" {
                    RegistrationView(vm: vm)
                }
                else if vm.currentView == "UserTraining" {
                    UserTraining(vm: vm, trainings: [Training(id: "1", approach: "1", count: "1", date: "1", exerciseId: "1", name: "1", userId: "1")])
                }
            }
            .padding()
            
            // MARK: - Preloader
            if isLoading {
                PreloaderView()
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    // MARK: - Загрузка данных
    private func loadData() {
        isLoading = true
        var completedTasks = 0
        let totalTasks = 7
        
        let completeTask = {
            completedTasks += 1
            if completedTasks == totalTasks {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
        
        FirebaseManager.shared.getAllExercises { result in
            switch result {
            case .success(let exercises):
                vm.exercises = exercises
            case .failure(let error):
                print("Ошибка загрузки упражнений: \(error)")
            }
            completeTask()
        }
        
        FirebaseManager.shared.getAllCategories { result in
            switch result {
            case .success(let categories):
                vm.categories = categories
            case .failure(let error):
                print("Ошибка загрузки категорий: \(error)")
            }
            completeTask()
        }
        
        FirebaseManager.shared.getTrainingForUser(userId: vm.user.id ?? "") { result in
            switch result {
            case .success(let training):
                vm.userTrainings = training
            case .failure(let error):
                print("Ошибка загрузки тренировок: \(error)")
            }
            completeTask()
        }
        
        HealthManager.shared.fetchTodayCalories { result in
            vm.calories = result
            completeTask()
        }
        
        HealthManager.shared.fetchTodaySteps { result in
            vm.steps = result
            completeTask()
        }
        
        HealthManager.shared.fetchTodayDistance { result in
            vm.distance = result
            completeTask()
        }
        
        HealthManager.shared.fetchBodyMass { result in
            vm.weight = result
            completeTask()
        }
    }
}


#Preview {
    ContentView()
}
