//
//  HomeView.swift
//  ApexApp
//
//  Created by Круглич Влад on 3.04.25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        VStack {
            VStack {
                //MARK: - Шапка
                HeaderView(vm: vm, backTo: "")
                    .padding(.top, 50)
                //MARK: - Текст "Ваши тренировки"
                HStack {
                    Text("Календарь")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 18))
                    Spacer()
                }
                //MARK: - Календарь
                CalendarView(vm: vm)
                //MARK: - Текст "Ваша активность"
                HStack {
                    Text("Ваши активности")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 18))
                    Spacer()
                }
                //MARK: - Ваша активность
                ActivityView(vm: vm)
                
                Spacer()
                
                //MARK: - Таббар
                TabBarView(vm: vm)
            }
            .padding(.horizontal, 20)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color.darkBlueBG)
    }
}

#Preview {
    HomeView(vm: ViewModel())
}
