//
//  TabBarView.swift
//  ApexApp
//
//  Created by Круглич Влад on 24.04.25.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                vm.currentView = "Home"
            }) {
                Image(systemName: "house")
            }
            Spacer()
            Button(action: {
                vm.currentView = "ListOfTraining"
            }) {
                Image(systemName: "list.bullet")
            }
            Spacer()
            Button(action: {
                vm.currentView = "CreateTraining"
            }) {
                Image(systemName: "calendar.badge.plus")
            }
            Spacer()
        }
        .foregroundColor(.white)
        .font(.system(size: 30))
        .frame(width: UIScreen.main.bounds.width, height: 90)
        .background(Color.darkBlueColor)
    }
}

#Preview {
    TabBarView(vm: ViewModel())
}
