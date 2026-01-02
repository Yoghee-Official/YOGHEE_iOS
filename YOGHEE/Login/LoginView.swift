//
//  LoginView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var container = LoginContainer()
    
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
        }
        .background(Color.SandBeige)
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
