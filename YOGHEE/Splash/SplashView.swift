//
//  SplashView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        Image("Splash")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
