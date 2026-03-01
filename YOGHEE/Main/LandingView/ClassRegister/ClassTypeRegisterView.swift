//
//  ClassTypeRegisterView.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/11/26.
//

import SwiftUI

// MARK: - Class Type Data
struct ClassTypeData: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let example: String
    let recommendation: String
    let backgroundColor: Color
}

struct ClassTypeRegisterView: View {
    @StateObject private var container = ClassRegisterContainer()
    
    private let classTypes: [ClassTypeData] = [
        ClassTypeData(
            id: "oneDay",
            title: "하루 수련 (원데이)",
            subtitle: "하루 동안 완결되는 체험형 수련",
            example: "예 : 초보자 체험, 테마 워크숍, 여행자 대상 수련 등",
            recommendation: "다양한 요기니와 만나고 싶다면 추천해요",
            backgroundColor: .red
        ),
        ClassTypeData(
            id: "regular",
            title: "정규 수련 (요가원)",
            subtitle: "일정 기간 반복되는 성장형 수련",
            example: "예 : 주 2회 4주 과정, 아침 루틴 요가",
            recommendation: "깊이있는 호흡을 공유하고 싶다면 추천해요",
            backgroundColor: .orange
        ),
        ClassTypeData(
            id: "season",
            title: "시즌 수련",
            subtitle: "이때가 아니면 불가능! 지금만 가능한 시즌 수련",
            example: "예 : 일주일만에 완성하는 머리서기",
            recommendation: "빠른 시간안에 결과를 만들고 싶다면 추천해요",
            backgroundColor: .yellow
        ),
        ClassTypeData(
            id: "workshop",
            title: "워크숍",
            subtitle: "다같이 참여할 수 있는 워크숍",
            example: "예 : 4주 20시간 핸즈-온 워크숍, 지도자 과정(TTC)",
            recommendation: "심도있는 수련을 나누고 싶다면 추천해요",
            backgroundColor: .green
        )
    ]
    
    var body: some View {
        VStack(spacing: 28.ratio()) {
            // 타이틀
            Text("4가지 타입의\n수련을 준비했어요.")
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
                .multilineTextAlignment(.center)
                .padding(.top, 40.ratio())
            
            // 스와이프 카드
            ClassTypeCardsView(classTypes: classTypes, container: container)
            
            // 설명 텍스트
            Text("수련 방식은 한가지만 선택 가능합니다.\n다른 운영 방식으로 등록 하시려면 새 수련으로 추가해주세요.\n수련은 1개월씩 등록할 수 있습니다.")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
        .customNavigationBar(title: "운영 방식 선택")
    }
}

// MARK: - Class Type Cards View
struct ClassTypeCardsView: View {
    let classTypes: [ClassTypeData]
    @ObservedObject var container: ClassRegisterContainer
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.ratio()) {
                    ForEach(classTypes) { classType in
                        if classType.id == "oneDay" {
                            NavigationLink {
                                OnedayClassExplanationRegisterView(container: container)
                                    .onAppear {
                                        container.handleIntent(.selectClassType(classType.id))
                                    }
                            } label: {
                                ClassTypeCardView(classType: classType)
                                    .frame(width: geometry.size.width - 48.ratio())
                            }
                            .buttonStyle(.plain)
                        } else {
                            // TODO: 나머지 타입들 화면 구현 후 NavigationLink 추가
                            ClassTypeCardView(classType: classType)
                                .frame(width: geometry.size.width - 48.ratio())
                                .onTapGesture {
                                    container.handleIntent(.selectClassType(classType.id))
                                    print("\(classType.title) - 준비 중입니다.")
                                }
                        }
                    }
                }
                .padding(.horizontal, 20.ratio())
            }
        }
        .frame(height: 409.ratio())
    }
}

// MARK: - Class Type Card View
struct ClassTypeCardView: View {
    let classType: ClassTypeData
    
    var body: some View {
        ZStack {
            // 외곽 border
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.CleanWhite, lineWidth: 1)
                .frame(width: 327.ratio(), height: 409.ratio())
            
            // 내부 컨텐츠
            ZStack(alignment: .bottom) {
                // 배경 이미지 영역 (그라데이션 포함)
                ZStack {
                    classType.backgroundColor
                    
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0), location: 0.59924),
                            .init(color: Color.black.opacity(0.7), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(width: 311.ratio(), height: 393.ratio())
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 0) {
                // 상단 추천 태그
                HStack(spacing: 4.ratio()) {
                    Circle()
                        .fill(Color.MindOrange)
                        .frame(width: 8.ratio(), height: 8.ratio())
                    
                    Text(classType.recommendation)
                        .pretendardFont(.medium, size: 10)
                        .foregroundColor(.DarkBlack)
                }
                .padding(.horizontal, 8.ratio())
                .padding(.vertical, 4.ratio())
                .background(Color.white.opacity(0.8))
                .cornerRadius(31)
                .padding(.top, 12.ratio())
                .padding(.leading, 12.ratio())
                
                Spacer()
                
                // 하단 정보
                VStack(alignment: .leading, spacing: 4.ratio()) {
                    Text(classType.title)
                        .pretendardFont(.bold, size: 20)
                        .foregroundColor(.CleanWhite)
                    
                    Text(classType.subtitle)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.CleanWhite)
                        .lineSpacing(4)
                    
                    Text(classType.example)
                        .pretendardFont(.medium, size: 10)
                        .foregroundColor(.CleanWhite)
                        .lineSpacing(5)
                        .padding(.top, 4.ratio())
                }
                .padding(.leading, 20.ratio())
                .padding(.bottom, 83.ratio())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // 수련 개설하기 버튼 (NavigationLink로 감싸져 있어 자동 작동)
            ZStack {
                GlassUI.classRegisterButton()
                
                Text("수련 개설하기")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.CleanWhite)
            }
            .padding(.bottom, 16.ratio())
            }
            .frame(width: 311.ratio(), height: 393.ratio())
        }
        .frame(width: 327.ratio(), height: 409.ratio())
    }
}

#Preview {
    NavigationStack {
        ClassTypeRegisterView()
    }
}
