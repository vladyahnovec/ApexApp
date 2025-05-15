import SwiftUI
import Firebase

struct CreateTraining: View {
    @ObservedObject var vm: ViewModel
    @State private var selectedDate = Date()
    @State private var category = ""
    @State private var selectedExercise: Exercise?
    @State private var approach = ""
    @State private var count = ""
    @State private var showSuccessAlert = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.M"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack {
            HeaderView(vm: vm, backTo: "Home")
                .padding(.top, 50)
            
            VStack {
                HStack {
                    Text("Список тренировок")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 18))
                    Spacer()
                }
                //MARK: - выбор даты
                HStack {
                    Text("Выберите день")
                        .font(.custom("Montserrat-Light", size: 16))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .frame(width: 110)
                        .padding(.trailing, 15)
                        .background(.white)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .frame(width: 350, height: 40)
                .background(Color.darkBlueColor)
                .cornerRadius(20)
                //MARK: - выбор категории
                HStack {
                    Text("Тип тренировки")
                        .font(.custom("Montserrat-Light", size: 16))
                        .foregroundStyle(Color.white)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    Picker("", selection: $category) {
                        ForEach(vm.categories, id: \.self) { category in
                            Text(category.name)
                                .tag(category.name)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.white)
                    .onChange(of: category) { _ in
                        vm.filterExercisesByName(name: category)
                        selectedExercise = nil
                    }
                }
                .frame(width: 350, height: 40)
                .background(Color.darkBlueColor)
                .cornerRadius(20)
                //MARK: - выбор упражнения
                VStack {
                    HStack {
                        Text("Выберите упражнение")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                            .padding(.top, 10)
                        Spacer()
                    }
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(vm.exercisesByCategory, id: \.self) { exercise in
                                Button(action: {
                                    selectedExercise = exercise
                                }) {
                                    HStack {
                                        Text(exercise.name)
                                            .foregroundColor(selectedExercise?.id == exercise.id ? .green : .white)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        if selectedExercise?.id == exercise.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(Color.darkBlueBG.opacity(0.5))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    //MARK: - ввод параметров
                    VStack(spacing: 15) {
                        HStack {
                            Text("Подходы:")
                                .foregroundStyle(.white)
                            Spacer()
                            TextField("", text: $approach)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 70)
                        }
                        .frame(width: 190)
                        
                        HStack {
                            Text("Повторения:")
                                .foregroundStyle(.white)
                            Spacer()
                            TextField("", text: $count)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 70)
                        }
                        .frame(width: 190)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        guard let exercise = selectedExercise else { return }
                        
                        let training = Training(
                            approach: approach,
                            count: count,
                            date: formattedDate,
                            exerciseId: exercise.id ?? "",
                            name: exercise.name,
                            userId: vm.user.id ?? ""
                        )
                        
                        FirebaseManager.shared.addTraining(training: training) { success in
                            if success {
                                showSuccessAlert = true
                                resetForm()
                            }
                        }
                    }) {
                        Text("Создать")
                            .foregroundStyle(Color.white)
                            .frame(width: 300, height: 50)
                            .background(Color.darkBlueBG)
                            .cornerRadius(20)
                            .font(.custom("Montserrat-Medium", size: 18))
                            .padding(.vertical, 10)
                    }
                    .disabled(selectedExercise == nil || approach.isEmpty || count.isEmpty)
                }
                .frame(width: 350, height: 500)
                .background(Color.darkBlueColor)
                .cornerRadius(20)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color.darkBlueBG)
        .onAppear {
            vm.filterExercisesByName(name: "Для рук")
        }
        .alert("Тренировка создана!", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    // MARK: - сброс формы
    private func resetForm() {
        selectedExercise = nil
        approach = ""
        count = ""
    }
}

#Preview {
    CreateTraining(vm: ViewModel())
}
