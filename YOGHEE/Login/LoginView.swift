//
//  LoginView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var container = LoginContainer()
    @State private var id: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 11) {
                Image("Yoghee")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
                
                Text("로그인")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(height: 24)
            .padding(.top, 51)
            
            VStack(spacing: 36) {
                TextField("아이디", text: $id)
                    .textFieldStyle(CustomTextFieldStyle())
                
                SecureField("비밀번호", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            .padding(.top, 55)
            .padding(.horizontal, 39)
            
            Text("OR")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                .padding(.top, 54)
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 7) {
                Button(action: {
                    // TODO: Apple 로그인
                }) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 48, height: 48)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    container.handleIntent(.kakaoLogin)
                }) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 48, height: 48)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    // TODO: Google 로그인
                }) {
                    Text("G")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 48, height: 48)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.top, 12)
            .frame(maxWidth: .infinity)
            
            Button(action: {
                // TODO: 아이디/비밀번호 찾기
            }) {
                Text("아이디 / 비밀번호 찾기")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
            }
            .padding(.top, 34)
            .frame(maxWidth: .infinity)
            
            Button(action: {
                // TODO: 로그인
            }) {
                Text("로그인")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.36, green: 0.27, blue: 0.2).opacity(0.5))
                    .cornerRadius(30)
            }
            .padding(.top, 34)
            .padding(.horizontal, 97)
            
            HStack(spacing: 4) {
                Text("계정이 없으신가요?")
                    .font(.system(size: 12))
                
                Button(action: {
                    // TODO: 회원가입
                }) {
                    Text("회원가입")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .background(Color.init(red: 0.99, green: 0.98, blue: 0.96))
        .navigationBarHidden(true)
//        .statusBarHidden(true) << 필요한건지 확인
        
        // Loading & Error States
//        .overlay(
//            VStack {
//                if container.state.isLoading {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .scaleEffect(1.2)
//                        .padding()
//                        .background(Color.white.opacity(0.9))
//                        .cornerRadius(10)
//                }
//                
//                if let errorMessage = container.state.errorMessage {
//                    Text(errorMessage)
//                        .font(.caption)
//                        .foregroundColor(.red)
//                        .padding()
//                        .background(Color.white.opacity(0.9))
//                        .cornerRadius(8)
//                        .padding(.horizontal, 20)
//                }
//            }
//        )
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 23)
            .padding(.vertical, 32)
            .background(Color.white)
            .frame(height: 64)
            .cornerRadius(92)
            .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 0)
    }
}

#Preview {
    LoginView()
}
