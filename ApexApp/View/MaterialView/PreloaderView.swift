//
//  PreloaderView.swift
//  ApexApp
//
//  Created by Круглич Влад on 5.05.25.
//

import SwiftUI

struct PreloaderView: View {
    
    @State private var angle:Double = 0.0
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0.1,to: 1.0)
                .stroke(style: StrokeStyle(lineWidth: 5,lineCap: .round,lineJoin: .round))
                .foregroundStyle(.blue)
                .rotationEffect(Angle(degrees: angle))
                .onAppear{
                    withAnimation(Animation.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                        angle = 360
                    }
                }
                .frame(width: 200, height: 200)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.darkBlueColorBG)
    }
}
