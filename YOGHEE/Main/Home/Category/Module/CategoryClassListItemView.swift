//
//  CategoryCenterListItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/2/25.
//

import SwiftUI
import UIKit

// MARK: - Category Center List Item View
struct CategoryClassListItemView: View {
    let categoryClass: CategoryClassDTO
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    @State private var currentPage: Int = 0  // 현재 이미지 페이지
    
    var body: some View {
        VStack(spacing: 0) {
            // 이미지 슬라이더 + 배지 + 찜하기
            ZStack(alignment: .topLeading) {
                // 이미지 슬라이더
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
                .tabViewStyle(.page(indexDisplayMode: .never)) // 기본 인디케이터 숨김
                .frame(height: 211.ratio())
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture(perform: onTap)
                
                // CLUB 배지
                if categoryClass.isYogheeClub {
                    Text("CLUB")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.MindOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .offset(x: 16, y: 173.ratio())
                }
                
                // 커스텀 이미지 페이지 인디케이터
                if categoryClass.images.count > 1 {
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
                
                // 찜하기 버튼 - 우측 상단 정렬
                HStack {
                    Spacer()
                    Button(action: onFavoriteToggle) {
                        Image(categoryClass.isFavorite ? "FavoriteClassIcon" : "FavoriteClassIconEmpty")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 30)
                    }
                    .padding(.trailing, 16)
                }
            }
            .frame(height: 211.ratio())
            .frame(maxWidth: .infinity)
            
            // 정보 영역
            VStack(alignment: .leading, spacing: 4) {
                // 클래스명
                Text(categoryClass.className)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 주소 + 찜 개수 + 할인율 + 가격
                HStack(alignment: .center, spacing: 0) {
                    // 주소
                    Text(categoryClass.address)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    // 찜 아이콘 + 개수
                    HStack(spacing: 4) {
                        Image("FavoriteIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 9)
                        
                        Text("\(categoryClass.favoriteCount)+")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    // 할인율 + 가격
                    HStack(spacing: 4) {
                        if categoryClass.discount > 0 || categoryClass.clubDiscount > 0 {
                            HStack(spacing: 2) {
                                if categoryClass.discount > 0 {
                                    Text("\(categoryClass.discount)%")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.MindOrange)
                                }
                                if categoryClass.clubDiscount > 0 {
                                    Text("+")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.MindOrange)
                                    Text("\(categoryClass.clubDiscount)%")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.MindOrange)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        Text("\(categoryClass.price.formatted())원")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 4)
                    }
                }
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    CategoryClassListItemView(
        categoryClass: CategoryClassDTO(
            classId: "1",
            className: "반려견과 자연에서! 빈야사 요가",
            address: "서울 영등포구 당산동", images: [
                "https://via.placeholder.com/343x211/FF5520/FFFFFF?text=Image+1",
                "https://via.placeholder.com/343x211/D6F695/000000?text=Image+2",
                "https://via.placeholder.com/343x211/FFEC73/000000?text=Image+3"
            ],
            masterId: "master1",
            masterName: "마스터",
            rating: 4.5,
            review: 100,
            price: 12000,
            favoriteCount: 13387,
            isFavorite: false,
            discount: 47,
            clubDiscount: 5,
            isYogheeClub: true
        ),
        onTap: {
            print("수련원으로 이동")
        },
        onFavoriteToggle: {
            print("찜하기 토글")
        }
    )
    .padding()
    .background(Color.SandBeige)
}

