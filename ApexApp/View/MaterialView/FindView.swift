//
//  FindView.swift
//  ApexApp
//
//  Created by Круглич Влад on 24.04.25.
//

import SwiftUI

struct FindView: View {
    @ObservedObject var vm: ViewModel
    @State var findText = ""
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 25))
                    .padding(.leading, 20)
                Text(findText.isEmpty ? "Напишите..." : "")
                Spacer()
            }
            TextField("", text: $findText)
                .padding(.horizontal, 60)
                .onChange(of: findText) { newValue in
                    vm.findExerciseByText(findText: newValue)
                }
        }
        .foregroundColor(.white)
        .frame(width: 350, height: 50)
        .background(Color.darkBlueColor)
        .cornerRadius(10)
        .font(.custom("Montserrat-Light", size: 20))
    }
}

#Preview {
    FindView(vm: ViewModel())
}
