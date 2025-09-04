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
            
            VStack(spacing: 14) {
                TextField("아이디", text: .init(
                    get: { container.state.id },
                    set: { container.handleIntent(LoginIntent.updateId($0)) }
                ))
                .textFieldStyle(CustomTextFieldStyle(type: .id, text: container.state.id, hasLoginError: false, loginErrorMessage: nil))
                
                SecureField("비밀번호", text: .init(
                    get: { container.state.password },
                    set: { container.handleIntent(LoginIntent.updatePassword($0)) }
                ))
                .textFieldStyle(CustomTextFieldStyle(type: .password, text: container.state.password, hasLoginError: container.state.hasLoginError, loginErrorMessage: container.state.errorMessage))
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
                    container.handleIntent(LoginIntent.kakaoLogin)
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
                if container.state.isLoginButtonEnabled {
                    container.handleIntent(LoginIntent.normalLogin)
                }
            }) {
                Text("로그인")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.36, green: 0.27, blue: 0.2).opacity(container.state.isLoginButtonEnabled ? 1.0 : 0.5))
                    .cornerRadius(30)
            }
            .disabled(!container.state.isLoginButtonEnabled)
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
        // TODO: Effect 기능은 추후 구현 예정
        /*
        .onChange(of: container.effect) { _ in
            guard let effect = container.effect else { return }
            handleEffect(effect)
            container.clearEffect()
        }
        */
//        .statusBarHidden(true) << 필요한건지 확인
    }
    
    // TODO: Effect 기능은 추후 구현 예정
    /*
    private func handleEffect(_ effect: LoginEffect) {
        switch effect {
        case .navigateToHome:
            // TODO: 홈 화면으로 네비게이션
            print("Navigate to Home")
        case .showError(let message):
            // TODO: 에러 토스트 표시
            print("Show Error: \(message)")
        }
    }
    */
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    enum CustomTextFieldType {
        case id
        case password
    }
    let type: CustomTextFieldType
    let text: String
    let hasLoginError: Bool
    let loginErrorMessage: String?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration
                .padding(.horizontal, 23)
                .padding(.vertical, 32)
                .background(Color.white)
                .frame(height: 64)
                .cornerRadius(92)
                .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 92)
                        .inset(by: 0.5)
                        .stroke(shouldShowBorder() ? Color(red: 1, green: 0.33, blue: 0.13) : Color.clear, lineWidth: 1)
                )
            
            HStack {
                Text(getErrorText())
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 1, green: 0.33, blue: 0.13))
                    .padding(.leading, 27)
                    .opacity(shouldShowError() ? 1.0 : 0.0)
                Spacer()
            }
            .frame(height: 14)
            .padding(.top, 8)
        }
    }
    
    private func shouldShowError() -> Bool {
        switch type {
        case .id:
            return text.isEmpty
        case .password:
            return text.isEmpty || hasLoginError
        }
    }
    
    private func shouldShowBorder() -> Bool {
        switch type {
        case .id:
            return text.isEmpty
        case .password:
            return text.isEmpty || hasLoginError
        }
    }
    
    private func getErrorText() -> String {
        switch type {
        case .id:
            return text.isEmpty ? "* 필수입력 항목입니다." : ""
        case .password:
            if hasLoginError {
                return loginErrorMessage ?? "* 아이디/비밀번호가 맞지않습니다."
            } else if text.isEmpty {
                return "* 필수입력 항목입니다."
            } else {
                return ""
            }
        }
    }
}

#Preview {
    LoginView()
}
