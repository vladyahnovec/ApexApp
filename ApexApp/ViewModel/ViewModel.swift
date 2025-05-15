//
//  ViewModel.swift
//  ApexApp
//
//  Created by Круглич Влад on 4.04.25.
//

import Foundation
import FirebaseFirestore

class ViewModel: ObservableObject {
    @Published var currentView = "Auth"
    //MARK: - Пользователь
    @Published var user: User = User(id: "", mail: "", password: "", likeExercises: []) 
    @Published var userTrainings: [Training] = []
    
    //MARK: - Даты
    @Published var trainingDate = ""
    
    //MARK: - Категории упражнений
    @Published var categories: [Category] = []
    @Published var currentCategory = ""
    
    //MARK: - Упражнения
    @Published var exercises: [Exercise] = []
    @Published var exercise: Exercise = Exercise(name: "", description: "", categoryID: "", img: "")
    @Published var exercisesByCategory: [Exercise] = []
    @Published var exercisesByCategoryCopy: [Exercise] = []
    
    //MARK: - Данные пользователя из applehealth
    @Published var steps = ""
    @Published var calories = ""
    @Published var distance = ""
    @Published var weight = ""
    
    //MARK: - Все упражнения по категории
    func filterExercisesByCategory(categoryID: String) {
        exercisesByCategory = exercises.filter {$0.categoryID == categoryID}
        currentCategory = categories.first(where: {$0.id == categoryID})?.name ?? ""
        exercisesByCategoryCopy = exercisesByCategory
    }
    //MARK: - Все упражнения по категории
    func filterExercisesByName(name: String) {
        exercisesByCategory = exercises.filter {$0.categoryName == name}
        exercisesByCategoryCopy = exercisesByCategory
    }
    
    //MARK: - Добавить упражнения в избранное в бд
    func addExerciseToLike(exerciseId: String) {
        self.user.likeExercises.append(exerciseId)
        sortByLikeExercises()
    }
    
    //MARK: - Удалить упражнения из избранных из бд
    func removeExerciseToLike(exerciseId: String) {
        self.user.likeExercises.removeAll { $0 == exerciseId }
        sortByLikeExercises()
    }
    
    //MARK: - Сортировка по like/unlike упражнения
    func sortByLikeExercises() {
        self.exercisesByCategory = self.exercisesByCategory.sorted { first, second in
            let firstIsLiked = user.likeExercises.contains(first.id ?? "")
            let secondIsLiked = user.likeExercises.contains(second.id ?? "")
            
            if firstIsLiked && !secondIsLiked {
                return true
            } else if !firstIsLiked && secondIsLiked {
                return false
            } else {
                return false
            }
        }
    }
    
    // MARK: - Поиск упражнений по тексту
    func findExerciseByText(findText: String) {
        if findText.isEmpty {
            exercisesByCategory = exercisesByCategoryCopy
        } else {
            exercisesByCategory = exercisesByCategoryCopy.filter {
                $0.name.lowercased().contains(findText.lowercased())
            }
        }
    }
    
    // MARK: - Получение тренировки на день
    func getTrainingByDate() -> [Training] {
        return userTrainings.filter { $0.date == trainingDate }
    }
    
    // MARK: - Получение упражнения по имени
    func getExerciseByName(name: String) {
        if let foundExercise = self.exercises.first(where: { $0.name.lowercased() == name.lowercased() }) {
            self.exercise = foundExercise
        }
    }
}
