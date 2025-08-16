//
//  LoginView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // 로그인 성공 시 사용자 정보 표시 (임시)
            if viewModel.state.isLoggedIn, let user = viewModel.state.userInfo {
                VStack(spacing: 16) {
                    Text("로그인 성공!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("닉네임: \(user.kakaoAccount?.profile?.nickname ?? "알 수 없음")")
                        .font(.body)
                    
                    Text("이메일: \(user.kakaoAccount?.email ?? "알 수 없음")")
                        .font(.body)
                    
                    Button("홈으로 이동") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 40)
            } else {
                // 로그인 버튼
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
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
