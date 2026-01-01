//
//  LoginView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct LoginView: View {
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
                    // TODO: Kakao 로그인
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
        }
        .background(Color.SandBeige)
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
