//
//  LoginView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var container = LoginContainer()
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7.ratio()) {
                Button(action: {
                    // TODO: Apple 로그인
                }) {
                    Image(systemName: "applelogo")
                        .pretendardFont(size: 20)
                        .foregroundColor(.black)
                        .frame(width: 48.ratio(), height: 48.ratio())
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    // TODO: Naver 로그인
                }) {
                    Text("N")
                        .pretendardFont(.bold, size: 20)
                        .foregroundColor(.black)
                        .frame(width: 48.ratio(), height: 48.ratio())
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
                        .pretendardFont(size: 20)
                        .foregroundColor(.black)
                        .frame(width: 48.ratio(), height: 48.ratio())
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
                .disabled(container.state.isLoading)
                
                Button(action: {
                    // TODO: Google 로그인
                }) {
                    Text("G")
                        .pretendardFont(.bold, size: 20)
                        .foregroundColor(.black)
                        .frame(width: 48.ratio(), height: 48.ratio())
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            
            if let errorMessage = container.state.errorMessage {
                Text(errorMessage)
                    .pretendardFont(size: 14)
                    .foregroundColor(.red)
                    .padding(.top, 16.ratio())
            }
            
            // 최하단 버튼 영역
            VStack(spacing: 12.ratio()) {
                Button(action: {
                    Task {
                        await authManager.checkAutoLogin()
                    }
                }) {
                    Text("로그인 유지")
                        .pretendardFont(.medium, size: 14)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44.ratio())
                        .background(Color.white)
                        .cornerRadius(8.ratio())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8.ratio())
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
                .disabled(authManager.isLoading)
                
                Button(action: {
                    authManager.logout()
                }) {
                    Text("로그아웃")
                        .pretendardFont(.medium, size: 14)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44.ratio())
                        .background(Color.white)
                        .cornerRadius(8.ratio())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8.ratio())
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20.ratio())
            .padding(.top, 32.ratio())
        }
        .background(Color.SandBeige)
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
