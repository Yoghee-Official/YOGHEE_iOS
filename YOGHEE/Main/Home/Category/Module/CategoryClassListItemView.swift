//
//  CategoryClassListItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/2/25.
//

import SwiftUI

// MARK: - Category Class List Item View
struct CategoryClassListItemView: View {
    let categoryClass: CategoryClassDTO
    let categoryType: ClassType
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    @State private var currentPage: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            imageSection
            infoSection
        }
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        ZStack(alignment: .topLeading) {
            imageSlider
            
            if categoryClass.isYogheeClub {
                clubBadge
            }
            
            if categoryClass.images.count > 1 {
                pageIndicator
            }
            
            favoriteButton
        }
        .frame(height: 211.ratio())
        .frame(maxWidth: .infinity)
    }
    
    private var imageSlider: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(categoryClass.images.enumerated()), id: \.offset) { index, imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 211.ratio())
                .frame(maxWidth: .infinity)
                .clipped()
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 211.ratio())
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture(perform: onTap)
    }
    
    private var clubBadge: some View {
        Text("CLUB")
            .pretendardFont(.bold, size: 12)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.MindOrange)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .offset(x: 16, y: 173.ratio())
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<categoryClass.images.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .offset(y: 191.ratio())
    }
    
    private var favoriteButton: some View {
        HStack {
            Spacer()
            Button(action: onFavoriteToggle) {
                Image(categoryClass.isFavorite ? "SaveIconBig" : "SaveIconEmptyBig")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 30)
            }
            .padding(.trailing, 16)
        }
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(categoryClass.className)
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.black)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center, spacing: 0) {
                leftInfoSection
                Spacer()
                rightInfoSection
            }
        }
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private var leftInfoSection: some View {
        switch categoryType {
        case .oneDay:
            oneDayInfoView
        case .regular:
            regularInfoView
        }
    }
    
    private var oneDayInfoView: some View {
        HStack(spacing: 8) {
            Text("T. \(categoryClass.masterName)")
                .infoTextStyle()
                .lineLimit(1)
            
            Text("★ \(String(format: "%.1f", categoryClass.rating)) (\(categoryClass.review))")
                .infoTextStyle()
        }
    }
    
    private var regularInfoView: some View {
        HStack(spacing: 8) {
            Text(categoryClass.address)
                .infoTextStyle()
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Image("FavoriteIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 9)
                
                Text("\(categoryClass.favoriteCount)+")
                    .infoTextStyle()
            }
        }
    }
    
    private var rightInfoSection: some View {
        HStack(spacing: 4) {
            if categoryClass.discount > 0 || categoryClass.clubDiscount > 0 {
                discountView
            }
            
            Text("\(categoryClass.price.formatted())원")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.black)
                .padding(.horizontal, 4)
        }
    }
    
    private var discountView: some View {
        HStack(spacing: 2) {
            if categoryClass.discount > 0 {
                Text("\(categoryClass.discount)%")
                    .discountTextStyle()
            }
            if categoryClass.clubDiscount > 0 {
                Text("+")
                    .discountTextStyle()
                Text("\(categoryClass.clubDiscount)%")
                    .discountTextStyle()
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - View Extensions
private extension View {
    func infoTextStyle() -> some View {
        self
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.black)
    }
    
    func discountTextStyle() -> some View {
        self
            .pretendardFont(.bold, size: 16)
            .foregroundColor(.MindOrange)
    }
}

// MARK: - Previews
#Preview("정규수련") {
    CategoryClassListItemView(
        categoryClass: .mockData,
        categoryType: .regular,
        onTap: {},
        onFavoriteToggle: {}
    )
    .padding()
    .background(Color.SandBeige)
}

#Preview("하루수련") {
    CategoryClassListItemView(
        categoryClass: .mockData,
        categoryType: .oneDay,
        onTap: {},
        onFavoriteToggle: {}
    )
    .padding()
    .background(Color.SandBeige)
}
