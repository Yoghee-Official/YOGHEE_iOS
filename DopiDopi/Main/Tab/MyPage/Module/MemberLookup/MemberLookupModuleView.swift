//
//  MemberLookupModuleView.swift
//  YOGHEE
//
//  지도자 마이페이지(TMP_MO_1) "4a 회원 조회" 모듈 (피그마 node-id 697-25645, 방어 화면 3-12979)
//  - 예약한 회원 프로필 최대 2개 랜덤 노출 (서버에서 무작위 선정)
//  - 예약된 회원이 없을 경우 프로필, + 버튼 미노출
//  - 더보기 클릭 시 회원 조회(SM_MO_1) 페이지 노출
//

import SwiftUI

struct MemberLookupModuleView: View {
    /// 예약한 회원 중 무작위 최대 2명 (GET /api/my/leader > memberPreviews)
    let previews: [LeaderMemberPreviewDTO]
    let onMoreTap: () -> Void

    private let profileSize: CGFloat = 44

    var body: some View {
        HStack(spacing: 8.ratio()) {
            if !previews.isEmpty {
                profileStack
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("요기니 둘러보기")
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .lineLimit(1)

                Text("호흡을 나눌 요기니를 만나보세요!")
                    .pretendardFont(.medium, size: 10)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button(action: onMoreTap) {
                Text("더보기")
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .frame(width: 56, height: 44)
                    .background(Color.FlowBlue)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16.ratio())
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, minHeight: 74)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color.CleanWhite.opacity(0), location: 0.16),
                    .init(color: Self.flowBlueLight.opacity(0.3), location: 0.86)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.CleanWhite, lineWidth: 1)
        )
        .padding(.horizontal, 16.ratio())
        .debugViewName()
    }

    // MARK: - 회원 프로필 (최대 2개, 12pt 겹침) + 버튼

    private var profileStack: some View {
        HStack(spacing: -12) {
            ForEach(previews.prefix(2)) { member in
                profileImage(urlString: member.profileImage)
            }
            plusCircle
        }
    }

    private func profileImage(urlString: String?) -> some View {
        AsyncImage(url: URL(string: urlString ?? "")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            // 프로필 이미지가 없을 경우 요기 로고 노출 (지도자 프로필 모듈과 동일)
            Image("HeaderLogo")
                .resizable()
                .scaledToFit()
                .padding(6)
                .background(Color.SandBeige)
        }
        .frame(width: profileSize, height: profileSize)
        .clipShape(Circle())
    }

    private var plusCircle: some View {
        Image(systemName: "plus")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.DarkBlack)
            .frame(width: profileSize, height: profileSize)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: Color.CleanWhite.opacity(0), location: 0.22),
                        .init(color: Color.CleanWhite.opacity(0.3), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .background(.ultraThinMaterial)
            )
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.CleanWhite, lineWidth: 1)
            )
    }

    /// 피그마 FlowBlueLight (#E2EFFF)
    private static let flowBlueLight = Color(red: 226 / 255, green: 239 / 255, blue: 1)
}

#Preview {
    VStack(spacing: 20) {
        MemberLookupModuleView(
            previews: [
                LeaderMemberPreviewDTO(userUuid: "1", nickname: "요기니1", profileImage: nil),
                LeaderMemberPreviewDTO(userUuid: "2", nickname: "요기니2", profileImage: nil)
            ],
            onMoreTap: {}
        )
        // 예약된 회원이 없을 경우 (방어 화면)
        MemberLookupModuleView(previews: [], onMoreTap: {})
    }
    .padding(.vertical, 20)
    .background(Color.SandBeige)
}
