//
//  TimerView.swift
//  ApexApp
//
//  Created by Круглич Влад on 25.04.25.
//

import SwiftUI

struct TimerView: View {
    @State private var timeRemaining = 60
    @State private var timerIsRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button(action: {
                    timerIsRunning.toggle()
                }) {
                    Image(systemName: timerIsRunning ? "pause.circle" : "play.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                Text("\(timeFormatted(timeRemaining))")
                    .font(.custom("Montserrat-Light", size: 40))
                    .foregroundColor(timerIsRunning ? .green : .red)
                    .onReceive(timer) { _ in
                        if timerIsRunning && timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
                    .padding(.horizontal, 20)
                Button(action: {
                    timeRemaining = 60
                    timerIsRunning = false
                }) {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            Stepper("", value: $timeRemaining, in: 1...3600, step: 5)
                .padding(.trailing, 0)
                .background(.gray)
                .frame(width: 100)
                .cornerRadius(10)
        }
        .padding()
    }
    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TimerView()
}
