//
//  UserTraining.swift
//  ApexApp
//
//  Created by Круглич Влад on 25.04.24.
//

import SwiftUI

struct UserTraining: View {
    @ObservedObject var vm: ViewModel
    @State var trainings: [Training]
    
    var body: some View {
        VStack {
            HeaderView(vm: vm, backTo: "Home")
                .padding(.top, 50)
            .padding(20)
            ScrollView {
                ForEach(trainings.indices, id: \.self) { index in
                    Button {
                        vm.currentView = "ExerciseDetails"
                        vm.exercise = vm.exercises.first(where: { $0.name == trainings[index].name }) ?? Exercise(name: "", description: "", categoryID: "", categoryName: "", img: "")
                    } label: {
                        HStack {
                            Text(trainings[index].name)
                                .font(.custom("Montserrat-Medium", size: 20))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text(trainings[index].approach)
                            Text("x")
                            Text(trainings[index].count)
                        }
                        .frame(width: UIScreen.main.bounds.width - 80, height: 70)
                        .padding(.horizontal, 20)
                        .background(.darkBlue)
                        .cornerRadius(10)
                        .padding(.top, 20)
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.darkBlueColorBG)
        .foregroundStyle(.white)
        .onAppear {
            FirebaseManager.shared.getTrainingForUser(userId: vm.user.id ?? "") { result in
                switch result {
                case .success(let training):
                    vm.userTrainings = training
                    trainings = vm.getTrainingByDate()
                case .failure(let error):
                    print("Error fetching trainings: \(error.localizedDescription)")
                }
            }
        }
    }
}
