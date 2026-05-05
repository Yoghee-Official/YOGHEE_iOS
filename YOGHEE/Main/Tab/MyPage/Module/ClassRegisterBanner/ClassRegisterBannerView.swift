//
//  ClassRegisterBannerView.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/11/26.
//

import SwiftUI

struct ClassRegisterBannerView: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8.ratio()) {
                Text("클래스 등록하기")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.DarkBlack)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56.ratio())
            .background(Color.FlowBlue)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.DarkBlack, lineWidth: 2)
            )
        }
        .padding(.horizontal, 16.ratio())
    }
}

#Preview {
    ClassRegisterBannerView {
        print("클래스 등록하기 클릭")
    }
    .background(Color.SandBeige)
}
