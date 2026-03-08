//
//  NewPlaceRegisterView.swift
//  YOGHEE
//
//  신규 장소 등록 화면 (AP_MO_2, Figma 3104-15819)
//

import SwiftUI

struct NewPlaceRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    let onDismiss: () -> Void
    
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
        .customNavigationBar(title: "신규 장소 등록")
        .onAppear {
            if container.state.amenities == nil {
                container.loadCodeList()
            }
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
                Text(isRegistering ? "등록 중..." : "등록")
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
    
    private func performRegister() {
        guard canRegister, !isRegistering else { return }
        registerError = nil
        isRegistering = true
        let body = makeNewCenterDto()
        Task {
            do {
                _ = try await APIService.shared.registerCenter(body: body)
                await MainActor.run {
                    isRegistering = false
                    container.loadCenterList()
                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    isRegistering = false
                    registerError = error.localizedDescription
                }
            }
        }
    }
    
    /// 도로명/지번 둘 중 하나만 있어도 되므로, 카카오 값이 없으면 화면 주소로 채움
    private func makeNewCenterDto() -> NewCenterDto {
        let fullAddr = [roadAddress, detailAddress].filter { !$0.isEmpty }.joined(separator: " ")
        let allAmenityIds = selectedAmenityIds.union(selectedFacilityIds)
        var road = kakaoRoadAddress.nilIfEmpty
        var jibun = kakaoJibunAddress.nilIfEmpty
        if road == nil && jibun == nil {
            road = roadAddress.nilIfEmpty
            jibun = nil
        }
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
            amenityIds: allAmenityIds.isEmpty ? nil : Array(allAmenityIds)
        )
    }
}

#Preview {
    NewPlaceRegisterView(container: ClassRegisterContainer(), onDismiss: {})
}
