//
//  CategoryMainView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/18/25.
//

import SwiftUI

struct CategoryMainView: View {
    let categoryId: String
    let categoryName: String
    let categoryType: String
    
    var body: some View {
        VStack {
            Text("카테고리: \(categoryName)")
                .font(.title)
            Text("ID: \(categoryId)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("추후 피그마 디자인에 맞춰 개발 예정")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var navigationTitle: String {
        switch categoryType {
        case "R": return "위치탐색"
        case "O": return "취향탐색"
        default: return categoryName
        }
    }
}

#Preview("정규수련 - 서울") {
    NavigationStack {
        CategoryMainView(categoryId: "1", categoryName: "서울", categoryType: "R")
    }
}

#Preview("하루수련 - 릴렉스") {
    NavigationStack {
        CategoryMainView(categoryId: "1", categoryName: "릴렉스", categoryType: "O")
    }
}


