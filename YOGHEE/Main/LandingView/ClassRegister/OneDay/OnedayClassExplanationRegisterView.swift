//
//  OnedayClassExplanationRegisterView.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/21/26.
//

import SwiftUI

struct OnedayClassExplanationRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.ratio()) {
                // TODO: 수련 설명 폼 구현
                VStack(spacing: 16.ratio()) {
                    Text("수련 설명 페이지")
                        .pretendardFont(.bold, size: 20)
                        .foregroundColor(.DarkBlack)
                    
                    Text("여기에 수련 설명 폼을 구현하세요.")
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
        .customNavigationBar(title: "수련 설명")
    }
}

#Preview {
    NavigationStack {
        OnedayClassExplanationRegisterView(container: ClassRegisterContainer())
    }
}
