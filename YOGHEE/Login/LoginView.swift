//
//  LoginView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var id: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 8) {
                Text("YOGHEE")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("로그인")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 40)
            
            VStack(spacing: 16) {
                TextField("아이디", text: $id)
                    .textFieldStyle(CustomTextFieldStyle())
                
                SecureField("비밀번호", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Text("OR")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            HStack(spacing: 20) {
                Button(action: {
                    // TODO: Apple 로그인
                }) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    viewModel.handleIntent(.kakaoLogin)
                }) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    // Google 로그인
                }) {
                    Text("G")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.bottom, 20)
            
            Button(action: {
                // TODO: 아이디/비밀번호 찾기
            }) {
                Text("아이디 / 비밀번호 찾기")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(.bottom, 30)
            
            Button(action: {
                // TODO: 로그인
            }) {
                Text("로그인")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.brown.opacity(0.8))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            HStack(spacing: 4) {
                Text("계정이 없으신가요?")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray.opacity(0.6))
                
                Button(action: {
                    // TODO: 회원가입
                }) {
                    Text("회원가입")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .background(Color.offWhite)
        .navigationBarHidden(true)
        
        // Loading & Error States
        .overlay(
            VStack {
                if viewModel.state.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                }
                
                if let errorMessage = viewModel.state.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
            }
        )
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    LoginView()
}
