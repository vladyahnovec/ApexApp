import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private init() {}
    
    // MARK: - Получаем всех пользователей
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let users = try querySnapshot?.documents.compactMap { document in
                    try document.data(as: User.self)
                } ?? []
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Регистрация
    func registerUser(mail: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: mail, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let authUser = authResult?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания пользователя"])))
                return
            }
            
            let newUser = User(
                id: authUser.uid, mail: mail, password: password, likeExercises: [String]()
            )
            
            do {
                try self.db.collection("users").document(authUser.uid).setData(from: newUser)
                completion(.success(newUser))
            } catch {
                completion(.failure(error))
            }

        }
    }
    
    // MARK: - Авторизация
    func loginUser(mail: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users")
            .whereField("mail", isEqualTo: mail)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "", code: -1)))
                    return
                }
                let storedPassword = document.get("password") as? String ?? ""
                if storedPassword == password {
                    self.auth.signIn(withEmail: mail, password: password) { _, error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            do {
                                let user = try document.data(as: User.self)
                                completion(.success(user))
                            } catch {
                                completion(.failure(error))
                            }
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: -1)))
                }
            }
    }
    // MARK: - Получить все категории
    func getAllCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        db.collection("categories").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let categories = try querySnapshot?.documents.compactMap { document in
                    try document.data(as: Category.self)
                } ?? []
                completion(.success(categories))
            } catch {
                completion(.failure(error))
            }
        }
    }
    // MARK: - Получить все упражнения
    func getAllExercises(completion: @escaping (Result<[Exercise], Error>) -> Void) {
        db.collection("exercises").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let exercises = try querySnapshot?.documents.compactMap { document in
                    try document.data(as: Exercise.self)
                } ?? []
                completion(.success(exercises))
            } catch {
                completion(.failure(error))
            }
        }
    }
    // MARK: - Получить все тренировки пользователя
    func getTrainingForUser(userId: String, completion: @escaping (Result<[Training], Error>) -> Void) {
        db.collection("training")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let trainings = try documents.compactMap { document in
                        try document.data(as: Training.self)
                    }
                    completion(.success(trainings))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - Добавить тренировку пользователя
    func addTraining(training: Training, completion: @escaping (Bool) -> Void) {
            do {
                let data = try Firestore.Encoder().encode(training)
                
                db.collection("training").addDocument(data: data) { error in
                    if let error = error {
                        print("Error adding training: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Training successfully added!")
                        completion(true)
                    }
                }
            } catch {
                print("Error encoding training: \(error.localizedDescription)")
                completion(false)
            }
        }
    
    // MARK: - Добавить упражнение в избранное
    func addExerciseToLike(exerciseId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !userId.isEmpty, !exerciseId.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "userId или exerciseId пустые"])
            completion(.failure(error))
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"])
                completion(.failure(error))
                return
            }
            
            let currentLikes = document.get("likeExercises") as? [String] ?? []
            
            if currentLikes.contains(exerciseId) {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Упражнение уже в избранном"])
                completion(.failure(error))
                return
            }
            
            userRef.updateData([
                "likeExercises": FieldValue.arrayUnion([exerciseId])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Удалить упражнение из избранного
    func removeExerciseFromLikes(exerciseId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !userId.isEmpty, !exerciseId.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "userId или exerciseId пустые"])
            completion(.failure(error))
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"])
                completion(.failure(error))
                return
            }
            
            let currentLikes = document.get("likeExercises") as? [String] ?? []
            
            guard currentLikes.contains(exerciseId) else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Упражнение не найдено в избранном"])
                completion(.failure(error))
                return
            }
            
            userRef.updateData([
                "likeExercises": FieldValue.arrayRemove([exerciseId])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    
}

