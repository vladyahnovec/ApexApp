//
//  ActivityView.swift
//  ApexApp
//
//  Created by Круглич Влад on 3.04.25.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        //MARK: - Ячейки активностей пользователя
        VStack {
            HStack(spacing: 20) {
                VStack {
                    Text("Шаги")
                        .font(.custom("Montserrat-Light", size: 20))
                    Image("steps")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text(vm.steps)
                        .font(.custom("Montserrat-Bold", size: 30))
                }
                .foregroundColor(Color.white)
                    .frame(width: 165, height: 225)
                    .background(Color.darkBlueColor)
                    .cornerRadius(20)
                VStack {
                    Text("Калории")
                        .font(.custom("Montserrat-Light", size: 20))
                    Image("calories")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding(.leading, 10)
                    Text(vm.calories)
                        .font(.custom("Montserrat-Bold", size: 30))
                }
                .foregroundColor(Color.white)
                    .frame(width: 165, height: 225)
                    .background(Color.darkBlueColor)
                    .cornerRadius(20)
            }
            HStack(spacing: 20) {
                VStack {
                    Text("Дистанция")
                        .font(.custom("Montserrat-Light", size: 20))
                    Image("distance")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text(vm.distance)
                        .font(.custom("Montserrat-Bold", size: 30))
                }
                .foregroundColor(Color.white)
                    .frame(width: 165, height: 225)
                    .background(Color.darkBlueColor)
                    .cornerRadius(20)
                VStack {
                    Text("Вес")
                        .font(.custom("Montserrat-Light", size: 20))
                    Image("weight")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text(vm.weight)
                        .font(.custom("Montserrat-Bold", size: 30))
                }
                .foregroundColor(Color.white)
                    .frame(width: 165, height: 225)
                    .background(Color.darkBlueColor)
                    .cornerRadius(20)
            }
        }
    }
}

#Preview {
    ActivityView(vm: ViewModel())
}
