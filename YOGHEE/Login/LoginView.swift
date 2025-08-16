//
//  LoginView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Button(action: {
                viewModel.handleIntent(.kakaoLogin)
            }) {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.yellow)
                    Text("카카오로 로그인")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
            .disabled(viewModel.state.isLoading)
            
            if viewModel.state.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            if let errorMessage = viewModel.state.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
