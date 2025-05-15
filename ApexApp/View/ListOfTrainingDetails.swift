import SwiftUI

struct ListOfTrainingDetails: View {
    @ObservedObject var vm: ViewModel
    @State private var heightKeyboard: CGFloat = 0
    
    var body: some View {
        VStack {
            // MARK: - Шапка
            HeaderView(vm: vm, backTo: "ListOfTraining")
                .padding(.top, 50)
            
            // MARK: - Поиск
            Spacer()
            FindView(vm: vm)
                .ignoresSafeArea(.keyboard)
            Spacer()
            
            // MARK: - Текст
            VStack {
                HStack {
                    Text(vm.currentCategory)
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 18))
                        .padding(.vertical, 20)
                    Spacer()
                }
                
                // MARK: - Каждая тренировка
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(vm.exercisesByCategory, id: \.id) { exercise in
                            Button(action: {
                                vm.currentView = "ExerciseDetails"
                                vm.exercise = exercise
                            }) {
                                VStack {
                                    HStack {
                                        Text(exercise.name)
                                            .font(.custom("Montserrat-Light", size: 20))
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(.leading, 20)
                                    
                                    HStack {
                                        Text(exercise.description)
                                            .font(.custom("Montserrat-Thin", size: 16))
                                            .foregroundStyle(Color.gray)
                                            .frame(width: 200, height: 100)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(.leading, 20)
                                    
                                    HStack {
                                        Spacer()
                                        // MARK: - Изображение like/nolike
                                        if let exerciseId = exercise.id, vm.user.likeExercises.contains(exerciseId) {
                                            Button(action: {
                                                guard let userId = vm.user.id else { return }
                                                FirebaseManager.shared.removeExerciseFromLikes(
                                                    exerciseId: exerciseId,
                                                    userId: userId
                                                ) { result in
                                                    switch result {
                                                    case .success:
                                                        vm.removeExerciseToLike(exerciseId: exerciseId)
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
                                        } else {
                                            Button(action: {
                                                guard let exerciseId = exercise.id, let userId = vm.user.id else { return }
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
                                }
                                .frame(width: 350, height: 200)
                                .background(.black.opacity(0.4))
                                .background(Image(exercise.img)
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(0.3))
                                .cornerRadius(20)
                                .foregroundStyle(Color.white)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .padding(.top, heightKeyboard)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: heightKeyboard)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.darkBlueColorBG)
        // MARK: - Решение проблемы с клавиатурой
        .onAppear {
            vm.sortByLikeExercises()
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.heightKeyboard = keyboardFrame.height
                }
            }
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                self.heightKeyboard = 0
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
}

#Preview {
    ListOfTrainingDetails(vm: ViewModel())
}
