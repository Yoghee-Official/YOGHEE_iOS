//
//  ClassRegisterView.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/11/26.
//

import SwiftUI
import SwiftUIIntrospect

struct ClassRegisterView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.ratio()) {
                // TODO: 클래스 등록 폼 구현
                VStack(spacing: 16.ratio()) {
                    Text("클래스 등록 페이지")
                        .pretendardFont(.bold, size: 20)
                        .foregroundColor(.DarkBlack)
                    
                    Text("여기에 클래스 등록 폼을 구현하세요.")
                        .pretendardFont(.regular, size: 14)
                        .foregroundColor(.Info)
                }
                .padding(.top, 40.ratio())
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16.ratio())
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: "클래스 등록")
//        .onAppear {
//            enableSwipeBackGesture()  // View 레벨에서 직접 호출
//        }
    }
}

#Preview {
    NavigationStack {
        ClassRegisterView()
    }
}
