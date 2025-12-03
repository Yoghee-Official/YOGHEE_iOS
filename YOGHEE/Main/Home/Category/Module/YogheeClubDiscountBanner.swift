//
//  YogheeClubDiscountBanner.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/27/24.
//

import SwiftUI

struct YogheeClubDiscountBanner: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("요기클럽 회원")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text(" ")
            
            Text("추가 5% 상시 할인!")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "FFEC73"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.MindOrange)
        .cornerRadius(8)
    }
}

#Preview {
    YogheeClubDiscountBanner()
        .padding()
}

