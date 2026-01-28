//
//  UserProfileModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/16/25.
//

import SwiftUI

struct UserProfileModuleView: View {
    let profileData: UserProfileDTO?
    let onProfileEditTap: () -> Void
    let onSettingTap: () -> Void
    let onNotificationTap: () -> Void
    let onLevelInfoTap: () -> Void
    let onCategoryTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.GheeYellow
            
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
            Text("반가워요 !\n요기니 \(profileData?.nickname ?? "")님")
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 15) {
                // 첫 번째 박스
                ZStack {
                    GlassUI.mySmall()
                    Text("누적 수련 : \(profileData?.totalClass ?? 0)")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                }
                
                // 두 번째 박스
                ZStack {
                    GlassUI.mySmall()
                    Text("예정된 수련 : \(profileData?.plannedClass ?? 0)")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                }
            }
        }
    }
    
    // MARK: - Promotion Section
    private var promotionSection: some View {
        let lines = (profileData?.totalHour ?? "").components(separatedBy: "\n")
        
        return VStack(spacing: 4) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                Text(line)
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(index == 0 ? .DarkBlack : .black)
                    .multilineTextAlignment(.center)
            }
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
                // 왼쪽 카드 - 레벨 (변경)
                levelCardContent(width: cardWidth)
                    .frame(width: cardWidth, height: 130.ratio())
                
                // 오른쪽 카드 - 카테고리 (변경)
                categoryCardContent(width: cardWidth)
                    .frame(width: cardWidth, height: 130.ratio())
            }
            .padding(.horizontal, horizontalPadding)
        }
        .frame(height: 130.ratio())
    }
    
    private func levelCardContent(width: CGFloat) -> some View {
        Button(action: onLevelInfoTap) {
            ZStack {
                GlassUI.myBig()
                
                // 기존 컨텐츠
                VStack(alignment: .leading, spacing: 8) {
                    // 헤더
                    HStack(spacing: 4) {
                        Text("요기 레벨 현황")
                            .pretendardFont(.regular, size: 10)
                            .foregroundColor(.DarkBlack)
                        
                        ZStack {
                            Circle()
                                .fill(Color.CleanWhite)
                                .frame(width: 12, height: 12)
                            
                            Text("?")
                                .pretendardFont(.regular, size: 10)
                                .foregroundColor(.Info)
                        }
                    }
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        // 메인 텍스트
                        VStack(alignment: .leading, spacing: 0) {
                            Text("몸과 마음을 채우는")
                                .pretendardFont(.bold, size: 14)
                                .foregroundColor(.DarkBlack)
                            Text("수련, 어떠셨나요?")
                                .pretendardFont(.bold, size: 14)
                                .foregroundColor(.DarkBlack)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 하단 정보
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("시작 레벨")
                                .pretendardFont(.regular, size: 10)
                                .foregroundColor(.DarkBlack)
                            
                            Text("Lv.\(profileData?.level ?? 0)")
                                .pretendardFont(.bold, size: 16)
                                .foregroundColor(.MindOrange)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                .padding(12)
            }
        }
    }
    
    private func categoryCardContent(width: CGFloat) -> some View {
        Button(action: onCategoryTap) {
            ZStack {
                GlassUI.myBig()
                
                // 기존 컨텐츠
                VStack(alignment: .leading, spacing: 8) {
                    // 헤더
                    Text("월간 카테고리 분석")
                        .pretendardFont(.regular, size: 10)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        // 메인 텍스트
                        VStack(alignment: .leading, spacing: 0) {
                            if let monthlyCategory = profileData?.monthlyCategory {
                                Text("\(monthlyCategory)에 빠지셨군요")
                                    .pretendardFont(.bold, size: 14)
                                    .foregroundColor(.DarkBlack)
                            }
                            Text("대단해예")
                                .pretendardFont(.bold, size: 14)
                                .foregroundColor(.DarkBlack)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 하단 정보
                        VStack(alignment: .trailing, spacing: 8) {
                            if let monthlyCategory = profileData?.monthlyCategory {
                                Text("\(monthlyCategory) 수련 횟수")
                                    .pretendardFont(.regular, size: 10)
                                    .foregroundColor(.DarkBlack)
                            }
                            
                            Text("\(profileData?.monthlyCategoryCount ?? 0)")
                                .pretendardFont(.bold, size: 16)
                                .foregroundColor(.MindOrange)
                                .frame(width: 136, alignment: .trailing)
                        }
                    }
                }
                .padding(12)
            }
        }
    }
}

#Preview {
    UserProfileModuleView(
        profileData: UserProfileDTO(
            nickname: "앨리스",
            profileImage: nil,
            totalClass: 10,
            plannedClass: 7,
            totalHour: "총 11시간, 기운이 아주 단단해졌어요!\n요가가 일상 속 리듬이 되어가고 있어요.",
            grade: "시작",
            level: 4,
            monthlyCategoryCount: 4,
            monthlyCategory: "릴렉스"
        ),
        onProfileEditTap: { print("프로필 편집 클릭") },
        onSettingTap: { print("설정 클릭") },
        onNotificationTap: { print("알림 클릭") },
        onLevelInfoTap: { print("레벨 카드 클릭") },
        onCategoryTap: { print("카테고리 카드 클릭") }
    )
}
