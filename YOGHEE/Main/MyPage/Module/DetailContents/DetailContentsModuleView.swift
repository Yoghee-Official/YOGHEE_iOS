//
//  DetailContentsModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/15/25.
//

import SwiftUI

struct DetailContentsModuleView: View {
    let onItemTap: (String) -> Void
    
    private let menuItems = ["설정", "계정관리", "이용약관", "고객센터", "환불정책"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 15) {
                // 상단 구분선
                Rectangle()
                    .fill(Color.DarkBlack)
                    .frame(height: 2)
                
                // 메뉴 항목들
                ForEach(menuItems, id: \.self) { item in
                    VStack(spacing: 15) {
                        Button(action: {
                            onItemTap(item)
                        }) {
                            HStack {
                                Text(item)
                                    .pretendardFont(.bold, size: 14)
                                    .foregroundColor(.DarkBlack)
                                    .tracking(-0.408)
                                
                                Spacer()
                                
                                Image("FrontArrowLineIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 6, height: 12)
                            }
                            .frame(width: 293, height: 17)
                        }
                        
                        // 항목 사이 구분선
                        if item != menuItems.last {
                            Rectangle()
                                .fill(Color.DarkBlack)
                                .frame(height: 0.5)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

#Preview {
    DetailContentsModuleView { item in
        print("\(item) 클릭")
    }
}

