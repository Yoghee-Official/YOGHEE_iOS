//
//  CenterManageView.swift
//  YOGHEE
//
//  지도자 마이페이지 > 세부 항목 "요가원 등록 및 관리" (AP_MO_1, Figma 3-9298)
//  수련 등록 흐름 중간의 수련 장소 선택 화면(OnedayClassLocationRegisterView)과는 별개 화면
//

import SwiftUI

struct CenterManageView: View {
    /// 요가원 목록 조회·신규 등록/수정 화면(NewPlaceRegisterView)과 상태를 공유하기 위해 사용
    @StateObject private var container = ClassRegisterContainer()

    @State private var pendingDeleteCenter: CenterBaseDTO?
    @State private var deleteErrorMessage: String?
    @State private var isDeleting = false

    /// 등록된 수련 장소는 최대 20개까지 노출, 20개면 2a(새 요가원 등록) 영역 미노출
    private let maxCenterCount = 20

    private var visibleCenters: [CenterBaseDTO] {
        Array(container.state.centers.prefix(maxCenterCount))
    }

    private var canRegisterNewCenter: Bool {
        container.state.centers.count < maxCenterCount
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 2a: 요가원 등록
                if canRegisterNewCenter {
                    registerSection
                }

                // 2b: 등록된 수련 장소 목록
                centerListSection

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16.ratio())
            .padding(.top, 10.ratio())
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: "수련 장소 등록")
        .onAppear {
            container.loadCenterList()
        }
        .overlay {
            if let center = pendingDeleteCenter {
                CenterManageAlertView(
                    message: "등록된 주소를 삭제하시겠습니까?",
                    onConfirm: { deleteCenter(center) },
                    onDismiss: { pendingDeleteCenter = nil }
                )
            } else if let message = deleteErrorMessage {
                CenterManageAlertView(
                    message: message,
                    onConfirm: { deleteErrorMessage = nil },
                    onDismiss: { deleteErrorMessage = nil }
                )
            }
        }
    }

    // MARK: - 2a: 요가원 등록
    private var registerSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            ClassRegisterSectionHeader(title: "요가원 등록")
                .padding(.horizontal, 8.ratio())

            NavigationLink {
                NewPlaceRegisterView(container: container)
            } label: {
                VStack(alignment: .leading, spacing: 8.ratio()) {
                    Text("새 요가원 등록하기")
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.MindOrange)
                    Text("등록하신 수련 장소가 없나요?\n새 요가원을 등록 해주세요.")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .multilineTextAlignment(.leading)
                }
                .tracking(-0.408)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16.ratio())
                .background(Color.CleanWhite)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.MindOrange, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 35.ratio())
    }

    // MARK: - 2b: 등록된 수련 장소 목록
    @ViewBuilder
    private var centerListSection: some View {
        if container.state.isLoadingCenters && container.state.centers.isEmpty {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, 24.ratio())
        } else if let error = container.state.centersError {
            Text(error)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.Info)
                .padding(.vertical, 16.ratio())
        } else if !visibleCenters.isEmpty {
            // 등록된 요가원이 없으면 2b 영역 전체 미노출 (피그마 3-9457)
            VStack(alignment: .leading, spacing: 16.ratio()) {
                ClassRegisterSectionHeader(title: "등록된 수련 장소 목록")
                    .padding(.horizontal, 8.ratio())

                VStack(spacing: 20.ratio()) {
                    ForEach(visibleCenters) { center in
                        CenterManageCardView(
                            center: center,
                            container: container,
                            onDeleteTap: { pendingDeleteCenter = center }
                        )
                    }
                }
            }
        }
    }

    private func deleteCenter(_ center: CenterBaseDTO) {
        guard !isDeleting else { return }
        isDeleting = true
        pendingDeleteCenter = nil
        Task {
            do {
                try await APIService.shared.deleteCenter(centerId: center.centerId)
                await MainActor.run {
                    isDeleting = false
                    container.loadCenterList()
                }
            } catch {
                await MainActor.run {
                    isDeleting = false
                    // 409: 등록된 수련이 있어 삭제 불가 등 서버 메시지를 그대로 안내
                    deleteErrorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - 주소 유닛 (등록일 · 수련장소명 · 주소 · 수련 추가 등록/주소 수정 · 삭제)
private struct CenterManageCardView: View {
    let center: CenterBaseDTO
    /// 장소 수정 화면에 넘겨 코드표·목록 갱신을 공유
    let container: ClassRegisterContainer
    let onDeleteTap: () -> Void

    /// createdAt이 일시(yyyy-MM-ddTHH:mm:ss)로 내려와도 등록 일자(yyyy-MM-dd)만 노출
    private var registeredDate: String {
        String(center.createdAt.prefix(10))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            VStack(alignment: .leading, spacing: 8.ratio()) {
                Text(registeredDate)
                    .pretendardFont(.medium, size: 10)
                    .foregroundColor(.Info)
                Text(center.name)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                Rectangle()
                    .fill(Color.Background)
                    .frame(height: 1)
                Text(center.address)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
            .tracking(-0.408)

            HStack(spacing: 13.ratio()) {
                // 수련 추가 등록 → 운영 방식 선택(OM_MO_1), 이 요가원을 수련 장소로 미리 선택
                NavigationLink {
                    ClassTypeRegisterView(preselectedCenterId: center.centerId)
                } label: {
                    actionButtonLabel(title: "수련 추가 등록", isFilled: true)
                }
                .buttonStyle(.plain)

                // 주소 수정 → 주소 자동 등록된 장소 수정 화면(AP_MO_3)
                NavigationLink {
                    NewPlaceRegisterView(container: container, editingCenterId: center.centerId)
                } label: {
                    actionButtonLabel(title: "주소 수정", isFilled: false)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16.ratio())
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onDeleteTap) {
                Image("CancelIcon")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(8.ratio())
        }
    }

    private func actionButtonLabel(title: String, isFilled: Bool) -> some View {
        Text(title)
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.DarkBlack)
            .tracking(-0.408)
            .frame(maxWidth: .infinity)
            .frame(height: 30.ratio())
            .background(isFilled ? Color.Background : Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: isFilled ? 0 : 1)
            )
    }
}

#Preview {
    NavigationStack {
        CenterManageView()
    }
}
