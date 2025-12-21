//
//  UserProfileModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/16/25.
//

import SwiftUI

// TODO: [API 연동] 실제 데이터 모델로 교체
struct UserProfileData {
    let userName: String
    let profileImageUrl: String?
    let totalHours: Int
    let upcomingClasses: Int
    let currentLevel: Int
    let timeToNextLevel: String
    let topCategory: String
    let categoryCount: Int
}

struct UserProfileModuleView: View {
    let profileData: UserProfileData
    let onProfileEditTap: () -> Void
    let onSettingTap: () -> Void
    let onNotificationTap: () -> Void
    let onLevelInfoTap: () -> Void
    let onCategoryTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            // 배경
            Color.GheeYellow
                .frame(width: 375, height: 426)
            
            VStack(spacing: 0) {
                // 상단 영역 (프로필 + 설정/알림)
                ZStack(alignment: .topTrailing) {
                    // 프로필 이미지
                    profileImageSection
                        .padding(.top, 0)
                    
                    // 우측 상단 버튼들
                    topRightButtons
                        .padding(.top, 0)
                        .padding(.trailing, 26)
                }
                .frame(height: 86)
                
                // 메인 컨텐츠
                VStack(spacing: 28) {
                    // 인사말 + 통계
                    greetingSection
                    
                    // 프로모션 메시지
                    promotionSection
                    
                    // 카드 영역
                    cardsSection
                }
                .padding(.top, 16)
            }
            .frame(width: 375)
        }
    }
    
    // MARK: - Profile Image Section
    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            // 프로필 이미지
            AsyncImage(url: URL(string: profileData.profileImageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image("HeaderLogo")
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 86, height: 86)
            .clipShape(Circle())
            
            // + 버튼
            Button(action: onProfileEditTap) {
                ZStack {
                    Circle()
                        .fill(Color.DarkBlack)
                        .frame(width: 22, height: 22)
                    
                    Text("+")
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.CleanWhite)
                        .tracking(-0.408)
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
            // 인사말
            VStack(spacing: 0) {
                Text("반가워요 !")
                    .pretendardFont(.bold, size: 20)
                    .foregroundColor(.DarkBlack)
                Text("요기니 \(profileData.userName)님")
                    .pretendardFont(.bold, size: 20)
                    .foregroundColor(.DarkBlack)
            }
            
            // 통계
            HStack(spacing: 10) {
                statisticBox(label: "누적 수련", value: "\(profileData.totalHours)")
                statisticBox(label: "예정된 수련", value: "\(profileData.upcomingClasses)")
            }
        }
    }
    
    private func statisticBox(label: String, value: String) -> some View {
        HStack(spacing: 0) {
            Text("\(label) : \(value)")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.NatureGreen)
        .cornerRadius(5)
    }
    
    // MARK: - Promotion Section
    private var promotionSection: some View {
        VStack(spacing: 8) {
            Text("총 \(profileData.totalHours)시간, 첫 시작은 언제나 설레죠!")
                .pretendardFont(.bold, size: 12)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
                .multilineTextAlignment(.center)
            
            Text("지금 바로 첫 수련을 떠나볼까요?")
                .pretendardFont(.bold, size: 12)
                .foregroundColor(.black)
                .tracking(-0.408)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Cards Section
    private var cardsSection: some View {
        HStack(spacing: 12) {
            // 왼쪽 카드 - 레벨
            levelCard
            
            // 오른쪽 카드 - 카테고리
            categoryCard
        }
        .padding(.horizontal, 26)
    }
    
    private var levelCard: some View {
        Button(action: onLevelInfoTap) {
            VStack(alignment: .leading, spacing: 8) {
                // 헤더
                HStack(spacing: 4) {
                    Text("요기 레벨 현황")
                        .pretendardFont(.regular, size: 10)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                    
                    ZStack {
                        Circle()
                            .fill(Color.CleanWhite)
                            .frame(width: 12, height: 12)
                        
                        Text("?")
                            .pretendardFont(.regular, size: 10)
                            .foregroundColor(.Info)
                            .tracking(-0.408)
                    }
                }
                
                VStack(alignment: .trailing, spacing: 8) {
                    // 메인 텍스트
                    VStack(alignment: .leading, spacing: 0) {
                        Text("몸과 마음을 채우는")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                        Text("수련, 어떠셨나요?")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 하단 정보
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("시작 레벨")
                            .pretendardFont(.regular, size: 10)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                        
                        Text("Lv.\(profileData.currentLevel)")
                            .pretendardFont(.bold, size: 20)
                            .foregroundColor(.MindOrange)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .frame(width: 156, height: 130)
            .padding(12)
            .background(Color.CleanWhite.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.CleanWhite, lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
    
    private var categoryCard: some View {
        Button(action: onCategoryTap) {
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
                        Text("\(profileData.topCategory)에 빠지셨군요")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                        Text("대단해예")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 하단 정보
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("\(profileData.topCategory) 수련 횟수")
                            .pretendardFont(.regular, size: 10)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                        
                        Text("\(profileData.categoryCount) times")
                            .pretendardFont(.bold, size: 20)
                            .foregroundColor(.MindOrange)
                            .frame(width: 136, alignment: .trailing)
                    }
                }
            }
            .frame(width: 156, height: 130)
            .padding(12)
            .background(Color.CleanWhite.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.CleanWhite, lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
}

#Preview {
    UserProfileModuleView(
        profileData: UserProfileData(
            userName: "앨리스",
            profileImageUrl: nil,
            totalHours: 203,
            upcomingClasses: 6,
            currentLevel: 5,
            timeToNextLevel: "55분",
            topCategory: "하타",
            categoryCount: 25
        ),
        onProfileEditTap: { print("프로필 편집 클릭") },
        onSettingTap: { print("설정 클릭") },
        onNotificationTap: { print("알림 클릭") },
        onLevelInfoTap: { print("레벨 카드 클릭") },
        onCategoryTap: { print("카테고리 카드 클릭") }
    )
}

