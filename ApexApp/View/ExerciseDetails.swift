//
//  ExerciseDetails.swift
//  ApexApp
//
//  Created by Круглич Влад on 3.04.25.
//

import SwiftUI
struct ExerciseDetails: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        VStack {
            //MARK: - Шапка
            HeaderView(vm: vm, backTo: "Home")
                .padding(.top, 50)
            VStack {
                //MARK: - Текст тренировки
                Image(vm.exercise.img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 340, height: 200)
                    .padding(.top, 20)
                HStack {
                    Text(vm.exercise.name)
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 20))
                    Spacer()
                    //MARK: - Изображение like/nolike
                    if vm.user.likeExercises.contains(vm.exercise.id ?? "") {
                        Button(action: {
                            guard let userId = vm.user.id else { return }
                            FirebaseManager.shared.removeExerciseFromLikes(
                                exerciseId: vm.exercise.id ?? "",
                                userId: userId
                            ) { result in
                                switch result {
                                case .success:
                                    vm.removeExerciseToLike(exerciseId: vm.exercise.id ?? "")
                                case .failure(let error):
                                    print("Ошибка при удалении: \(error.localizedDescription)")
                                }
                            }
                            vm.sortByLikeExercises()
                        }) {
                            Image("like")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.horizontal, 20)
                        }
                    }
                    else {
                        Button(action: {
                            guard let exerciseId = vm.exercise.id, let userId = vm.user.id else { return }
                            FirebaseManager.shared.addExerciseToLike(
                                exerciseId: exerciseId,
                                userId: userId
                            ) { result in
                                switch result {
                                case .success:
                                    vm.addExerciseToLike(exerciseId: exerciseId)
                                case .failure(let error):
                                    print("Ошибка при добавлении в избранное: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Image("nolike")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 20)
                Text(vm.exercise.description)
                    .foregroundStyle(Color.white)
                    .font(.custom("Montserrat-Light", size: 18))
            }
            .padding(.horizontal, 20)
            TimerView()
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color.darkBlueBG)
    }
}

#Preview {
    ExerciseDetails(vm: ViewModel())
}
