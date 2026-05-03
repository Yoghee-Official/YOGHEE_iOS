//
//  LeaderProfileModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/16/25.
//

import SwiftUI

struct LeaderProfileModuleView: View {
    let profileData: LeaderProfileDTO?
    let onProfileEditTap: () -> Void
    let onSettingTap: () -> Void
    let onNotificationTap: () -> Void
    let onLevelInfoTap: () -> Void
    let onCategoryTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.FlowBlue
            
            VStack(spacing: 0) {
                // 상단 영역 (프로필 + 설정/알림)
                ZStack(alignment: .top) {
                    // 프로필 이미지 - 중앙
                    HStack {
                        Spacer()
                        profileImageSection
                        Spacer()
                    }
                    
                    // 우측 상단 버튼들 - 우측 정렬
                    HStack {
                        Spacer()
                        topRightButtons
                    }
                    .padding(.trailing, 26)
                }
                .padding(.top, 18)
                
                // 메인 컨텐츠
                VStack(spacing: 28) {
                    // 인사말 + 통계
                    greetingSection
                    
                    // 프로모션 메시지
                    promotionSection
                    
                    // 카드 영역
                    cardsSection
                    
                    Spacer()
                }
                .padding(.top, 16)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 472.ratio())
    }
    
    // MARK: - Profile Image Section
    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            // 프로필 이미지
            AsyncImage(url: URL(string: profileData?.profileImage ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image("HeaderLogo")
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 86.ratio(), height: 86.ratio())
            .clipShape(Circle())
            .overlay {
                RoundedRectangle(cornerRadius: 86)
                    .inset(by: 0.5)
                    .stroke(Color.SandBeige, lineWidth: 1)
            }
            
            // + 버튼
            Button(action: onProfileEditTap) {
                ZStack {
                    Circle()
                        .fill(Color.DarkBlack)
                        .frame(width: 22, height: 22)
                    
                    Text("+")
                        .pretendardFont(.bold, size: 14)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.CleanWhite)
                }
            }
        }
    }
    
    // MARK: - Top Right Buttons
    private var topRightButtons: some View {
        VStack(spacing: 12) {
            // 설정 버튼
            Button(action: onSettingTap) {
                Image("settingIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            
            // 알림 버튼
            Button(action: onNotificationTap) {
                Image("NotificationButtonFull")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 43, height: 29)
            }
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(spacing: 24) {
            Text("반가워요 !\n지도자 \(profileData?.nickname ?? "")님")
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 15) {
                // 첫 번째 박스
                ZStack {
                    GlassUI.mySmall()
                    Text("누적된 리뷰 : \(profileData?.totalReview ?? 0)")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                }
                
                // 두 번째 박스
                ZStack {
                    GlassUI.mySmall()
                    Text("개설된 수련 : \(profileData?.totalMyClass ?? 0)")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                }
            }
        }
    }
    
    // MARK: - Promotion Section
    private var promotionSection: some View {
        VStack(spacing: 4) {
            if let introduction = profileData?.introduction {
                Text(introduction)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .multilineTextAlignment(.center)
            } //else {
//                Text("소개글을 작성해주세요!")
//                    .pretendardFont(.medium, size: 12)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
            //}
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Cards Section
    private var cardsSection: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 26
            let cardSpacing: CGFloat = 12
            let availableWidth = geometry.size.width - (horizontalPadding * 2) - cardSpacing
            let cardWidth = availableWidth / 2
            
            HStack(spacing: cardSpacing) {
                // 왼쪽 카드 - 자격증
                certificateCardContent(width: cardWidth)
                    .frame(width: cardWidth, height: 130.ratio())
                
                // 오른쪽 카드 - 인기 카테고리
                categoryCardContent(width: cardWidth)
                    .frame(width: cardWidth, height: 130.ratio())
            }
            .padding(.horizontal, horizontalPadding)
        }
        .frame(height: 130.ratio())
    }
    
    private func certificateCardContent(width: CGFloat) -> some View {
        Button(action: onLevelInfoTap) {
            ZStack {
                GlassUI.myBig()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("대표 자격증")
                        .pretendardFont(.regular, size: 10)
                        .foregroundColor(.DarkBlack)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(profileData?.certificate ?? "-")
                                .pretendardFont(.bold, size: 14)
                                .foregroundColor(.DarkBlack)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                }
                .padding(.top, 8)
                .padding(.leading, 12)
            }
        }
    }
    
    private func categoryCardContent(width: CGFloat) -> some View {
        Button(action: onCategoryTap) {
            ZStack {
                GlassUI.myBig()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("월간 분석")
                        .pretendardFont(.regular, size: 10)
                        .foregroundColor(.DarkBlack)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        // 메인 텍스트
                        VStack(alignment: .leading, spacing: 0) {
                            if let popularCategory = profileData?.popularCategory {
                                Text(popularCategory)
                                    .pretendardFont(.bold, size: 14)
                                    .foregroundColor(.DarkBlack)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer() // TODO: 나중에 빼기 (알아서 위 아래 붙을 수 있는 방법 찾기)
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            if let popularCategory = profileData?.popularCategory {
                                Text("누적 예약 횟수")
                                    .pretendardFont(.regular, size: 10)
                                    .foregroundColor(.DarkBlack)
                            }
                            
                            Text("\(profileData?.reservedCount ?? 0)")
                                .pretendardFont(.bold, size: 16)
                                .foregroundColor(.MindOrange)
                                .frame(width: 136, alignment: .trailing)
                        }
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 12)
            }
        }
    }
}

#Preview {
    LeaderProfileModuleView(
        profileData: LeaderProfileDTO(
            nickname: "앨리스",
            profileImage: nil,
            totalReview: 123,
            totalMyClass: 6,
            introduction: "요가를 사랑하는 앨리스입니다. \n 함께 수련해요!",
            certificate: "RYT 200",
            popularCategory: "하타",
            reservedCount: 482
        ),
        onProfileEditTap: { print("프로필 편집 클릭") },
        onSettingTap: { print("설정 클릭") },
        onNotificationTap: { print("알림 클릭") },
        onLevelInfoTap: { print("자격증 카드 클릭") },
        onCategoryTap: { print("카테고리 카드 클릭") }
    )
}
