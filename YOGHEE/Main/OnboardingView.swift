//
//  OnboardingView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/3/25.
//

import SwiftUI

// MARK: - 온보딩 페이지 데이터 모델
struct OnboardingPage: Identifiable {
    let id: Int
    let image: String
    let title: String
    let description: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
}

// MARK: - 온보딩 메인 뷰
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    // 온보딩 페이지 데이터
    private let pages = [
        OnboardingPage(
            id: 0,
            image: "OnboardingImageFirst",
            title: "지도자 자격 인증",
            description: "반가워요, 지도자님!\n\n요기에 오신 걸 진심으로 환영합니다.\n\n클래스 등록을 위해 먼저 지도자 자격증 인증이 필요해요.\n인증이 완료되면 수업 등록이 바로 가능해집니다.",
            imageWidth: 198,
            imageHeight: 255
        ),
        OnboardingPage(
            id: 1,
            image: "OnboardingImageSecond",
            title: "기본 정보 입력",
            description: "어떤 요가를 가르치고 계신가요?\n\n요가명 이름 또는 클래스명을 입력하고,\n수련 내용과 운영 설비(편의시설 / 장구수리)를 선택해주세요.\n\n이 정보는 각 클래스의 기본 프로필이 됩니다.",
            imageWidth: 187,
            imageHeight: 275
        ),
        OnboardingPage(
            id: 2,
            image: "OnboardingImageThird",
            title: "공간 및 수련 정보 등록",
            description: "어디에서 공간을 소개해주세요.\n\n수업이 열리는 장소, 회차 가능한 인원,\n제공되는 명상(매트, 물, 이크라 등)을 입력할 수 있어요.\n\n시간을 함께 올리면 공간의 분위기가 더 잘 전달됩니다.",
            imageWidth: 294,
            imageHeight: 206
        ),
        OnboardingPage(
            id: 3,
            image: "OnboardingImageForth",
            title: "상세 소개 & 금액 설정",
            description: "이제 마지막 단계에요.\n\n클래스 소개글을 작성하고 금액을 설정해주세요.\n편하다, 저렴가, 할인 여부도 함께 선택할 수 있습니다.\n\n이 내용이 실제 상세페이지에 노출됩니다.",
            imageWidth: 214,
            imageHeight: 157
        )
    ]
    
    var body: some View {
        ZStack {
            Color.SandBeige
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                    .padding(.top, 22)
                
                Spacer()
                    .frame(height: 51)
                
                ZStack(alignment: .top) {
                    pageCarousel
                    
                    // 1d: 인디케이터 (고정, 오버레이)
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 284) // 이미지 영역(275) + 간격(9)
                        
                        pageIndicator
                    }
                }
                
                Spacer()
                
                nextButton
                    .padding(.bottom, 32)
                
                skipButton
                    .padding(.bottom, 32)
                    .hidden(currentPage == pages.count - 1)
            }
        }
    }
    
    // MARK: - 상단 네비게이션 바
    private var navigationBar: some View {
        HStack {
            // 1a: 뒤로가기 버튼
            Button {
                dismiss()
            } label: {
                Image("BackArrow")
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            // 1b: 문의하기 버튼
            Button {
                // 문의하기 페이지로 이동
            } label: {
                Text("문의하기")
                    .font(.custom("Pretendard-Bold", size: 10))
                    .foregroundColor(Color(hex: "B3B3B3"))
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .frame(height: 24)
        .overlay(
            Text("클래스 등록 안내")
                .font(.custom("Pretendard-Bold", size: 20))
                .foregroundColor(.black)
        )
    }
    
    // MARK: - 페이지 캐러셀 (이미지 + 콘텐츠 함께 스크롤)
    private var pageCarousel: some View {
        TabView(selection: $currentPage) {
            ForEach(pages) { page in
                VStack(spacing: 0) {
                    // 이미지 영역 (height: 275)
                    ZStack {
                        Color.clear
                            .frame(width: 375, height: 275)
                        
                        Image(page.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: page.imageWidth, maxHeight: page.imageHeight)
                    }
                    
                    // 인디케이터 공간 (9px + 인디케이터 높이 + 59px)
                    Spacer()
                        .frame(height: 80)
                    
                    // 1e: 콘텐츠 섹션 (타이틀 + 설명)
                    VStack(spacing: 24) {
                        // 타이틀
                        Text(page.title)
                            .font(.custom("Pretendard-Bold", size: 20))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        // 설명 텍스트
                        Text(page.description)
                            .font(.custom("Pretendard-Medium", size: 12))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(6)
                            .truncationMode(.tail)
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 16)
                }
                .tag(page.id)
            }
        }
        #if os(iOS)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        #endif
    }
    
    // MARK: - 페이지 인디케이터 (고정)
    private var pageIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<pages.count, id: \.self) { index in
                if index == currentPage {
                    Image("StarRatingFull")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                } else {
                    Circle()
                        .fill(Color(hex: "D9D9D9"))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
    // MARK: - 다음 버튼
    private var nextButton: some View {
        Button {
            if currentPage == pages.count - 1 {
                dismiss()
            } else {
                withAnimation {
                    currentPage += 1
                }
            }
        } label: {
            Text(currentPage == pages.count - 1 ? "등록하러 가기" : "다음")
                .font(.custom("Pretendard-SemiBold", size: 15))
                .foregroundColor(.white)
                .frame(width: 208, height: 48)
                .background(Color(hex: "5D4634"))
                .cornerRadius(30)
        }
    }
    
    // MARK: - 건너뛰기 버튼
    private var skipButton: some View {
        Button {
            dismiss()
        } label: {
            Text("건너뛰기")
                .font(.custom("Pretendard-Bold", size: 10))
                .foregroundColor(.Info)
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
