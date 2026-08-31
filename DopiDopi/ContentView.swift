//
//  ContentView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingSplash = false
//                }
//            }
        }
    }
}

#Preview {
    ContentView()
}
