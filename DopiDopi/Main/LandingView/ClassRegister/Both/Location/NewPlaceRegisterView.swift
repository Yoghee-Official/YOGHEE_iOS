//
//  NewPlaceRegisterView.swift
//  YOGHEE
//
//  신규 장소 등록 화면 (AP_MO_2, Figma 3104-15819)
//  editingCenterId를 넘기면 장소 수정 화면 (AP_MO_3, Figma 3104-15671)으로 동작
//

import SwiftUI

struct NewPlaceRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    /// nil이면 화면을 직접 dismiss (푸시로 진입한 경우)
    var onDismiss: (() -> Void)? = nil
    /// 수정할 요가원 ID. 있으면 상세 조회로 필드를 채우고 PUT으로 저장
    var editingCenterId: String? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var countryRegion: String = "대한민국"
    @State private var sido: String = ""
    @State private var sigungu: String = ""
    @State private var roadAddress: String = ""
    @State private var zonecode: String = ""
    @State private var detailAddress: String = ""
    @State private var placeName: String = ""
    @State private var detailDescription: String = ""
    @State private var selectedAmenityIds: Set<String> = []
    @State private var selectedFacilityIds: Set<String> = []
    
    @State private var kakaoRoadAddress: String = ""
    @State private var kakaoJibunAddress: String = ""
    @State private var showPostcodeSheet = false
    @State private var isRegistering = false
    @State private var registerError: String?
    @State private var isLoadingDetail = false
    @State private var didLoadDetail = false
    
    private var isEditMode: Bool { editingCenterId != nil }
    
    private let detailDescriptionMaxLength = 3000
    
    /// 필수: 주소(광역시/도·시/구·도로명/지번·우편번호), 수련 장소명
    private var canRegister: Bool {
        !sido.isEmpty && !sigungu.isEmpty && !roadAddress.isEmpty && !zonecode.isEmpty && !placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    locationSection
                    placeNameSection
                    detailDescriptionSection
                    providedItemsSection
                    amenitiesSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            
            registerButton
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: isEditMode ? "장소 수정" : "신규 장소 등록")
        .overlay {
            if isLoadingDetail {
                ProgressView()
            }
        }
        .onAppear {
            if container.state.amenities == nil {
                container.loadCodeList()
            }
            loadCenterDetailIfNeeded()
        }
        .sheet(isPresented: $showPostcodeSheet) {
            KakaoPostcodeWebView(
                onAddressSelected: { result in
                    applyKakaoResult(result)
                    showPostcodeSheet = false
                },
                onDismiss: { showPostcodeSheet = false }
            )
        }
    }
    
    private func applyKakaoResult(_ result: KakaoPostcodeResult) {
        zonecode = result.zonecode
        roadAddress = result.address
        kakaoRoadAddress = result.roadAddress
        kakaoJibunAddress = result.jibunAddress
        if let s = result.sido, !s.isEmpty { sido = s }
        if let s = result.sigungu, !s.isEmpty { sigungu = s }
    }
    
    /// 수정 모드: 상세 조회 결과로 주소·장소명·설명·물품/편의시설 선택값을 채움 (최초 1회)
    private func loadCenterDetailIfNeeded() {
        guard let centerId = editingCenterId, !didLoadDetail else { return }
        didLoadDetail = true
        isLoadingDetail = true
        Task {
            do {
                let detail = try await APIService.shared.getCenterDetail(centerId: centerId)
                await MainActor.run {
                    applyCenterDetail(detail)
                    isLoadingDetail = false
                }
            } catch {
                await MainActor.run {
                    isLoadingDetail = false
                    registerError = error.localizedDescription
                }
            }
        }
    }
    
    private func applyCenterDetail(_ detail: CenterDetailDto) {
        sido = detail.sido ?? ""
        sigungu = detail.sigungu ?? ""
        kakaoRoadAddress = detail.roadAddress ?? ""
        kakaoJibunAddress = detail.jibunAddress ?? ""
        roadAddress = kakaoRoadAddress.isEmpty ? kakaoJibunAddress : kakaoRoadAddress
        zonecode = detail.zonecode ?? ""
        detailAddress = detail.detailAddress ?? ""
        placeName = detail.name ?? ""
        detailDescription = String((detail.description ?? "").prefix(detailDescriptionMaxLength))
        // amenityCodes는 물품·편의시설이 한 목록으로 내려오므로 코드표 기준으로 나눠 담음
        let codes = Set(detail.amenityCodes ?? [])
        let amenityIds = Set(container.state.amenities?.amenity.map(\.id) ?? [])
        let facilityIds = Set(container.state.amenities?.facility.map(\.id) ?? [])
        selectedAmenityIds = codes.intersection(amenityIds)
        selectedFacilityIds = codes.intersection(facilityIds)
    }
    
    // MARK: - 2a: 수련 위치
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            ClassRegisterSectionHeader(
                title: "수련 위치",
                subtitle: "요기니들이 찾아올 수 있도록 수련 위치를 등록 해주세요."
            )
            VStack(spacing: 12.ratio()) {
                Menu {
                    Button("대한민국") { countryRegion = "대한민국" }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4.ratio()) {
                            (Text("국가 / 지역 ").foregroundColor(.DarkBlack) + Text("*").foregroundColor(.MindOrange))
                                .pretendardFont(.regular, size: 10)
                            Text(countryRegion)
                                .pretendardFont(.regular, size: 14)
                                .foregroundColor(.DarkBlack)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.DarkBlack)
                    }
                    .classRegisterOutlinedFieldStyle()
                }
                .buttonStyle(.plain)
                addressFieldRow(label: "광역시 / 도", value: sido)
                addressFieldRow(label: "시 / 구", value: sigungu)
                addressFieldRow(label: "도로명 주소 /지번", value: roadAddress)
                TextField("상세 주소", text: $detailAddress)
                    .pretendardFont(.regular, size: 14)
                    .foregroundColor(.DarkBlack)
                    .classRegisterOutlinedFieldStyle()
                addressFieldRow(label: "우편번호", value: zonecode)
            }
        }
        .padding(.bottom, 32.ratio())
    }
    
    private func addressFieldRow(label: String, value: String) -> some View {
        Button(action: { showPostcodeSheet = true }) {
            VStack(alignment: .leading, spacing: 4.ratio()) {
                (Text(label).foregroundColor(.DarkBlack) + Text(" *").foregroundColor(.MindOrange))
                    .pretendardFont(.regular, size: 10)
                Text(value.isEmpty ? " " : value)
                    .pretendardFont(.regular, size: 14)
                    .foregroundColor(value.isEmpty ? .Info : .DarkBlack)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .classRegisterOutlinedFieldStyle()
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 2b: 수련 장소명
    private var placeNameSection: some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            ClassRegisterSectionHeader(
                title: "수련 장소명",
                subtitle: "요기 지도에 주소록을 저장할 수 있어요! 다음 검색부터 수련 장소명만 입력해보세요."
            )
            TextField("수련 장소명", text: $placeName)
                .pretendardFont(.regular, size: 14)
                .foregroundColor(.DarkBlack)
                .classRegisterOutlinedFieldStyle()
        }
        .padding(.bottom, 32.ratio())
    }
    
    // MARK: - 2c: 수련원 상세 위치 설명 (피그마 3104-16007: "내용"·글자수 고정, 본문에 플레이스홀더 "-")
    private var detailDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            ClassRegisterSectionHeader(title: "수련원 상세 위치 설명")
            VStack(alignment: .leading, spacing: 12.ratio()) {
                Text("내용")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { detailDescription },
                        set: { detailDescription = String($0.prefix(detailDescriptionMaxLength)) }
                    ))
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 4.ratio())
                    .padding(.vertical, 0)
                    .frame(minHeight: 80.ratio())
                    if detailDescription.isEmpty {
                        Text("-")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .padding(.horizontal, 8.ratio())
                            .padding(.vertical, 8.ratio())
                            .allowsHitTesting(false)
                    }
                }
                Text("\(detailDescription.count) / \(detailDescriptionMaxLength)")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
            }
            .padding(20.ratio())
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
        }
        .padding(.bottom, 32.ratio())
    }
    
    // MARK: - 2d: 수련원에서 제공하는 물품 (amenities.amenity)
    private var providedItemsSection: some View {
        chipSection(
            title: "수련원에서 제공하는 물품",
            subtitle: "복수 선택 가능",
            list: container.state.amenities?.amenity,
            selectedIds: $selectedAmenityIds,
            showLoading: container.state.isLoadingCodeList
        )
    }
    
    // MARK: - 2e: 수련원 편의시설 (amenities.facility)
    private var amenitiesSection: some View {
        chipSection(
            title: "수련원 편의시설",
            subtitle: "복수 선택 가능",
            list: container.state.amenities?.facility,
            selectedIds: $selectedFacilityIds,
            showLoading: false
        )
    }
    
    private func chipSection(
        title: String,
        subtitle: String,
        list: [CodeInfoDTO]?,
        selectedIds: Binding<Set<String>>,
        showLoading: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            ClassRegisterSectionHeader(title: title, subtitle: subtitle)
            if let list = list {
                chipFlow(items: list, selectedIds: selectedIds)
            } else if showLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16.ratio())
            }
        }
        .padding(.bottom, 32.ratio())
    }
    
    private func chipFlow(items: [CodeInfoDTO], selectedIds: Binding<Set<String>>) -> some View {
        FlowLayout(spacing: 8.ratio()) {
            ForEach(items) { item in
                SelectionChipView(
                    title: item.name,
                    isSelected: selectedIds.wrappedValue.contains(item.id),
                    onTap: {
                        if selectedIds.wrappedValue.contains(item.id) {
                            selectedIds.wrappedValue.remove(item.id)
                        } else {
                            selectedIds.wrappedValue.insert(item.id)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - 3a: 등록 버튼
    private var registerButton: some View {
        VStack(spacing: 0) {
            if let error = registerError {
                Text(error)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.MindOrange)
                    .padding(.horizontal, 16.ratio())
                    .padding(.bottom, 8.ratio())
            }
            Button(action: performRegister) {
                Text(submitButtonTitle)
                    .pretendardFont(.semiBold, size: 15)
                    .foregroundColor(canRegister && !isRegistering ? .DarkBlack : .Info)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48.ratio())
                    .background(canRegister && !isRegistering ? Color.GheeYellow : Color.Background)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(!canRegister || isRegistering)
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 24.ratio())
        }
        .background(Color.SandBeige)
    }
    
    private var submitButtonTitle: String {
        if isEditMode {
            return isRegistering ? "수정 중..." : "수정 완료"
        }
        return isRegistering ? "등록 중..." : "등록"
    }
    
    private func close() {
        if let onDismiss {
            onDismiss()
        } else {
            dismiss()
        }
    }
    
    private func performRegister() {
        guard canRegister, !isRegistering else { return }
        registerError = nil
        isRegistering = true
        let editingCenterId = editingCenterId
        let newCenterBody = makeNewCenterDto()
        let updateBody = makeUpdateCenterDto()
        Task {
            do {
                if let centerId = editingCenterId {
                    try await APIService.shared.updateCenter(centerId: centerId, body: updateBody)
                } else {
                    _ = try await APIService.shared.registerCenter(body: newCenterBody)
                }
                await MainActor.run {
                    isRegistering = false
                    container.loadCenterList()
                    close()
                }
            } catch {
                await MainActor.run {
                    isRegistering = false
                    registerError = error.localizedDescription
                }
            }
        }
    }
    
    /// 도로명/지번은 둘 중 하나만 있어도 되므로, 카카오 값이 없으면 화면 주소로 채움
    private func resolvedAddresses() -> (road: String?, jibun: String?) {
        let road = kakaoRoadAddress.nilIfEmpty
        let jibun = kakaoJibunAddress.nilIfEmpty
        if road == nil && jibun == nil {
            return (roadAddress.nilIfEmpty, nil)
        }
        return (road, jibun)
    }
    
    /// 수정은 화면의 최종값 전체를 보냄. 상세 주소·설명을 비우면 빈 문자열로 보내 서버에서 삭제되게 함
    private func makeUpdateCenterDto() -> UpdateCenterRequestDto {
        let addresses = resolvedAddresses()
        return UpdateCenterRequestDto(
            name: placeName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: detailDescription,
            roadAddress: addresses.road,
            jibunAddress: addresses.jibun,
            detailAddress: detailAddress,
            amenityCodes: Array(selectedAmenityIds.union(selectedFacilityIds))
        )
    }
    
    private func makeNewCenterDto() -> NewCenterDto {
        let fullAddr = [roadAddress, detailAddress].filter { !$0.isEmpty }.joined(separator: " ")
        let allAmenityIds = selectedAmenityIds.union(selectedFacilityIds)
        let (road, jibun) = resolvedAddresses()
        return NewCenterDto(
            name: placeName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: detailDescription.nilIfEmpty,
            thumbnail: nil,
            masterId: nil,
            depth1: sido.nilIfEmpty,
            depth2: sigungu.nilIfEmpty,
            depth3: nil,
            roadAddress: road,
            jibunAddress: jibun,
            zonecode: zonecode.nilIfEmpty,
            addressDetail: detailAddress.nilIfEmpty,
            fullAddress: fullAddr.nilIfEmpty,
            // 선택된 게 없어도 nil이 아니라 빈 배열로 전송 (스웨거: "선택한 편의시설이 없으면 amenityCodes에 빈 배열을 전달합니다")
            amenityCodes: Array(allAmenityIds)
        )
    }
}

#Preview {
    NewPlaceRegisterView(container: ClassRegisterContainer(), onDismiss: {})
}
