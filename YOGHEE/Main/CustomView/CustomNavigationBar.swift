//
//  CustomNavigationBar.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/21/26.
//

import SwiftUI

// MARK: - View Modifier
struct CustomNavigationBarModifier: ViewModifier {
    let title: String
    let backgroundColor: Color
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image("BackArrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24.ratio(), height: 24.ratio())
                    }
                    .padding(.leading, 16.ratio())
                    
                    Spacer()
                    
                    Text(title)
                        .pretendardFont(.bold, size: 17)
                        .foregroundColor(.DarkBlack)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 24.ratio() + 16.ratio(), height: 1)
                }
                .frame(height: 44)
                .background(backgroundColor)
            }
    }
}

// MARK: - View Extension
extension View {
    /// 커스텀 네비게이션 바를 적용합니다
    /// - Parameters:
    ///   - title: 네비게이션 바 타이틀
    ///   - backgroundColor: 배경색 (기본값: SandBeige)
    func customNavigationBar(
        title: String,
        backgroundColor: Color = .SandBeige
    ) -> some View {
        modifier(CustomNavigationBarModifier(
            title: title,
            backgroundColor: backgroundColor
        ))
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack(spacing: 20) {
                Text("커스텀 네비게이션 바 미리보기")
                    .pretendardFont(.bold, size: 20)
                
                Text("뒤로가기 버튼을 눌러보세요")
                    .pretendardFont(.regular, size: 14)
            }
            .padding()
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: "샘플 타이틀")
    }
}
