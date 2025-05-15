//
//  AuthView.swift
//  ApexApp
//
//  Created by Круглич Влад on 2.04.25.
//

import SwiftUI

struct AuthView : View {
    @ObservedObject var vm: ViewModel
    @State var userMail = ""
    @State var userPassword = ""
    @State var error = ""
    var body: some View {
        //MARK: - Авторизация
        VStack(spacing: 0) {
            //MARK: - Логотип
            Image("logo")
                .padding(EdgeInsets(top: 125, leading: 0, bottom: 100, trailing: 0))
            VStack(spacing: 0) {
                //MARK: - Текст "Авторизация"
                HStack {
                    Spacer()
                    Text("Авторизация")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Bold", size: 20))
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 40, trailing: 0))
                    Spacer()
                }
                //MARK: - Поле для ввода почты
                ZStack {
                    Rectangle()
                        .fill(Color.darkBlueBG)
                        .frame(width: 310, height: 40)
                        .cornerRadius(15)
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(Color.white)
                            .font(.system(size: 25))
                            .padding(.leading, 40)
                        Spacer()
                    }
                    Text(userMail.isEmpty ? "Почта" : "")
                        .foregroundStyle(Color.white.opacity(0.5))
                        .padding(.trailing, 140)
                    TextField("", text: $userMail)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 80)
                }
                //MARK: - Поле для ввода пароля
                ZStack {
                    Rectangle()
                        .fill(Color.darkBlueBG)
                        .frame(width: 310, height: 40)
                        .cornerRadius(15)
                    HStack {
                        Image(systemName: "lock.circle")
                            .foregroundColor(Color.white)
                            .font(.system(size: 25))
                            .padding(.leading, 40)
                        Spacer()
                    }
                    Text(userPassword.isEmpty ? "Пароль" : "")
                        .foregroundStyle(Color.white.opacity(0.5))
                        .padding(.trailing, 130)
                    TextField("", text: $userPassword)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 80)
                }
                .padding(.top, 25)
                //MARK: - Текст с ошибкой
                Text(self.error.isEmpty ? "" : self.error)
                    .foregroundStyle(Color.red)
                    .font(.system(size: 12))
                    .padding(.top, 10)
                //MARK: - Кнопка ВХОДА
                Button(action: {
                    FirebaseManager.shared.loginUser(mail: userMail, password: userPassword) { result in
                        switch result {
                        case .success(let user):
                            vm.user = user
                            print(user)
                            vm.currentView = "Home"
                        case .failure(_):
                            self.error = "Такой пользователь не существует"
                        }
                    }
                }) {
                    Text("Вход")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 18))
                }
                .frame(width: 310, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.darkBlueBG, lineWidth: 3)
                )
                .padding(.top, 20)
                Spacer()
            }
            .frame(width: 350, height: 288)
            .background(Color.darkBlueColor)
            .cornerRadius(20)
            //MARK: - У вас нет аккаунта?
            HStack {
                Button(action: {
                    vm.currentView = "Registration"
                }) {
                    Text("У вас нет аккаунта?")
                        .foregroundStyle(Color.white)
                        .padding(.leading, 40)
                        .padding(.top, 10)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color.darkBlueBG)
    }
}

#Preview {
    AuthView(vm: ViewModel())
}
