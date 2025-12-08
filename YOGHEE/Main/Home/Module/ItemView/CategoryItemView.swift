//
//  CategoryItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/8/25.
//

import SwiftUI

struct CategoryItemView: View {
    let category: CategoryDTO
    let isFirst: Bool
    let isWide: Bool
    let onTap: () -> Void
    
    private var itemWidth: CGFloat {
        isWide ? 226 : 109
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                if isFirst {
                    Image("CategoryBackgroundFirst")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: itemWidth, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: itemWidth, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 239/255, green: 237/255, blue: 235/255).opacity(0.8), lineWidth: 1)
                        )
                }
                
                Text(category.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                    .padding(.top, 6)
            }
            .frame(width: itemWidth, height: 70)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        CategoryItemView(
            category: CategoryDTO(categoryId: "1", name: "서울", description: "", mainDisplay: "Y", type: .regular),
            isFirst: true,
            isWide: false,
            onTap: {}
        )
        
        CategoryItemView(
            category: CategoryDTO(categoryId: "2", name: "경기도", description: "", mainDisplay: "Y", type: .regular),
            isFirst: false,
            isWide: false,
            onTap: {}
        )
        
        CategoryItemView(
            category: CategoryDTO(categoryId: "3", name: "이색요가", description: "", mainDisplay: "Y", type: .oneDay),
            isFirst: false,
            isWide: true,
            onTap: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

