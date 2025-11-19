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
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CategoryMainView(categoryId: "1", categoryName: "릴렉스")
    }
}

