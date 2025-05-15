//
//  HeaderView.swift
//  ApexApp
//
//  Created by Круглич Влад on 3.04.25.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var vm: ViewModel
    var backTo = " "
    var body: some View {
        //MARK: - Шапка
        HStack {
            //MARK: - Кнопка назад
            Button(action: { vm.currentView = backTo }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
            }
            .opacity(backTo.isEmpty ? 0 : 1)
            .disabled(backTo.isEmpty)
            Spacer()
            //MARK: - Логотип приложения
            Image("logo")
                .resizable()
                .frame(width: 40, height: 40)
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
        .background(Color.darkBlueBG)
    }
}


#Preview {
    HeaderView(vm: ViewModel())
}
