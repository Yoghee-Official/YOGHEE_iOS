//
//  InstructorClassModuleView.swift
//  YOGHEE
//

import SwiftUI

/// 4a 지도자/수련원 소개(앞/뒷면) / 4b 수련 설명 / 4c 요가 타입·수련 방식·수련 대상 모듈
struct InstructorClassModuleView: View {
    let detail: YogaClassDetailDTO

    @State private var isFlipped: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // 4a: 하루수련 → 지도자 카드 / 정규수련 → 수련원 카드
            if detail.masterInfo != nil {
                instructorCard
                    .padding(.horizontal, 16)
            } else if let center = detail.center {
                centerCard(center: center)
                    .padding(.horizontal, 16)
            }

            // 4b 수련 설명 + 4c 영역들
            VStack(alignment: .leading, spacing: 32) {
                if let description = detail.description, !description.isEmpty {
                    classDescriptionSection(description: description)
                }

                if !detail.trainingTypes.isEmpty {
                    yogaTypeSection
                }
                if !detail.categories.isEmpty {
                    practiceMethodSection
                }
                if !detail.trainingTargets.isEmpty {
                    targetAudienceSection
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 4a 지도자 카드

    private var instructorCard: some View {
        ZStack {
            instructorFront
                .opacity(isFlipped ? 0 : 1)
            instructorBack
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 303)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.5), value: isFlipped)
    }

    private var instructorFront: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 5) {
                Text(detail.masterInfo?.nickname ?? "")
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.SandBeige)
                    .lineLimit(1)

                Text(detail.masterInfo?.introduction ?? "")
                    .pretendardFont(.bold, size: 20)
                    .foregroundColor(.SandBeige)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 183, alignment: .leading)
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background { instructorImage }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomTrailing) {
            flipButton
        }
    }

    private var instructorBack: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.5)

            VStack(alignment: .leading, spacing: 12) {
                instructorBackRow(label: "대표 자격증명", value: detail.masterInfo?.certificate ?? "-", labelSpacing: 8)
                instructorBackRow(label: "총 요가 경력", value: formattedCareer, labelSpacing: 15)

                HStack(alignment: .top, spacing: 28) {
                    Text("소개말")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.SandBeige)
                        .underline()
                        .frame(width: 43, alignment: .leading)

                    Text(detail.masterInfo?.introduction ?? "")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.SandBeige)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { instructorImage.blur(radius: 20) }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomTrailing) {
            flipButton
        }
    }

    private func instructorBackRow(label: String, value: String, labelSpacing: CGFloat) -> some View {
        HStack(spacing: labelSpacing) {
            Text(label)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.SandBeige)
                .underline()
            Text(value)
                .pretendardFont(.bold, size: 12)
                .foregroundColor(.SandBeige)
                .lineLimit(1)
        }
    }

    private var instructorImage: some View {
        Group {
            let imageUrl = detail.masterInfo?.profileImage ?? detail.images.first
            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.LandBrown
                }
            } else {
                Color.LandBrown
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var formattedCareer: String {
        guard let career = detail.masterInfo?.career else { return "-" }
        return "\(career)년"
    }

    private var flipButton: some View {
        Button {
            isFlipped.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.4))
                Image(systemName: "arrow.2.squarepath")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4a 수련원 카드 (정규수련)

    private func centerCard(center: CenterInfo) -> some View {
        ZStack {
            centerFront(center: center)
                .opacity(isFlipped ? 0 : 1)
            centerBack(center: center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 303)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.5), value: isFlipped)
    }

    private func centerFront(center: CenterInfo) -> some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 5) {
                Text(center.name)
                    .pretendardFont(.bold, size: 20)
                    .foregroundColor(.SandBeige)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 183, alignment: .leading)
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background { centerImage(thumbnail: center.thumbnail) }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomTrailing) {
            flipButton
        }
    }

    private func centerBack(center: CenterInfo) -> some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.5)

            HStack(alignment: .top, spacing: 28) {
                Text("소개말")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.SandBeige)
                    .underline()
                    .frame(width: 43, alignment: .leading)

                Text(center.description ?? "")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.SandBeige)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { centerImage(thumbnail: center.thumbnail).blur(radius: 20) }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomTrailing) {
            flipButton
        }
    }

    private func centerImage(thumbnail: String?) -> some View {
        Group {
            if let urlString = thumbnail, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.LandBrown
                }
            } else {
                Color.LandBrown
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    // MARK: - 4b 수련 설명

    private func classDescriptionSection(description: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("수련 설명")
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.DarkBlack, lineWidth: 1)
                )

            Text(String(description.prefix(3000)))
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
        }
    }

    // MARK: - 4c 요가 타입 / 수련 방식 / 수련 대상

    private var yogaTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("아래 요소가 함께 녹아있습니다.")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(detail.trainingTypes, id: \.categoryId) { type in
                        YogaTypeCardView(name: type.name)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    private var practiceMethodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("수련 방식")
            chipRow(items: detail.categories.map(\.name))
        }
    }

    private var targetAudienceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("수련 대상")
            chipRow(items: detail.trainingTargets.map(\.name))
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.bold, size: 14)
            .foregroundColor(.DarkBlack)
            .underline()
            .padding(.horizontal, 12)
    }

    private func chipRow(items: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    PracticeChipView(name: item)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - 요가 타입 카드 (84x80)

private struct YogaTypeCardView: View {
    let name: String

    var body: some View {
        VStack(spacing: 8) {
            // TODO: 디자이너 자산 도착 시 placeholder → 실제 아이콘으로 교체
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 42, height: 42)

            Text(name)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(width: 84, height: 80)
        .background(Color.CleanWhite)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(Color.Background, lineWidth: 1)
        )
    }
}

// MARK: - 수련 방식 / 수련 대상 칩

private struct PracticeChipView: View {
    let name: String

    var body: some View {
        Text(name)
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.CleanWhite)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(
                RoundedRectangle(cornerRadius: 32).stroke(Color.Background, lineWidth: 1)
            )
    }
}

