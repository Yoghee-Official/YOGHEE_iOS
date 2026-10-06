//
//  ExploreTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI
import KakaoMapsSDK

struct ExploreTabView: View {
    let onBackTapped: () -> Void
    @StateObject private var container = ExploreTabContainer()
    @StateObject private var locationManager = ExploreLocationManager()
    /// 검색바 입력 텍스트 — 검색 후에도 유지
    @State private var inputKeyword: String = ""
    @State private var showsFilterLayer = false
    @State private var navigationPath: [String] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                ExploreMapRepresentable(
                    initialCoordinate: .seoulCityHall,
                    initialZoomLevel: ExploreTabState.defaultZoomLevel,
                    classes: container.state.classes,
                    selectedClassId: container.state.selectedClassId,
                    cameraCommand: container.state.cameraCommand,
                    onCameraIdle: { bbox, isUserGesture in
                        container.handleIntent(.mapCameraIdle(bbox: bbox, isUserGesture: isUserGesture))
                    },
                    onCameraCommandFinished: { bbox in
                        container.handleIntent(.cameraCommandFinished(bbox: bbox))
                    },
                    onPinTapped: { classId in
                        container.handleIntent(.selectClass(id: classId))
                    }
                )
                .ignoresSafeArea()

                topControls
            }
            .overlay(alignment: .bottom) {
                bottomControls
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { classId in
                ClassDetailView(classId: classId)
            }
        }
        .fullScreenCover(isPresented: $showsFilterLayer) {
            ExploreFilterLayerView(
                filter: container.state.filter,
                onClose: {
                    // 닫기: 선택된 필터 전체 삭제 후 종료
                    showsFilterLayer = false
                    container.handleIntent(.applyFilter(ExploreSearchFilter()))
                },
                onApply: { filter in
                    showsFilterLayer = false
                    container.handleIntent(.applyFilter(filter))
                }
            )
        }
        .onAppear {
            locationManager.requestAuthorizationIfNeeded()
            resolveLocationIfPossible()
        }
        .onChange(of: locationManager.authorizationStatus) { _, _ in
            resolveLocationIfPossible()
        }
        .onChange(of: locationManager.currentCoordinate) { _, _ in
            resolveLocationIfPossible()
        }
    }

    // MARK: - 상단 (검색바 / 필터 / 현위치)

    private var topControls: some View {
        VStack(alignment: .trailing, spacing: 14) {
            ExploreSearchBar(
                keyword: $inputKeyword,
                placeholder: container.state.classType.placeholder,
                onBack: onBackTapped,
                onSearch: {
                    let trimmed = inputKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }   // 미입력 시 반응 없음
                    dismissKeyboard()
                    container.handleIntent(.submitKeyword(trimmed))
                }
            )
            .padding(.horizontal, 16)

            filterChipsRow

            // 3c 현위치 — 위치 허용하지 않았을 경우 미노출
            if locationManager.isAuthorized {
                ExploreGpsButton {
                    if let coordinate = locationManager.currentCoordinate {
                        container.handleIntent(.moveToCurrentLocation(coordinate: coordinate))
                    }
                    locationManager.refreshLocation()
                }
                .padding(.trailing, 31)
                .padding(.top, 10)
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 2a~2d 필터 칩

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ExploreFilterChip(
                    title: "필터",
                    iconName: container.state.filter.hasValidValue ? "CouponIcon" : "CouponIconBlack",
                    isSelected: container.state.filter.hasValidValue
                ) {
                    showsFilterLayer = true
                }

                ExploreFilterChip(
                    title: "하루수련 보기",
                    isSelected: container.state.classType == .oneDay
                ) {
                    container.handleIntent(.selectClassType(.oneDay))
                }

                ExploreFilterChip(
                    title: "정규수련(요가원) 모아보기",
                    isSelected: container.state.classType == .regular
                ) {
                    container.handleIntent(.selectClassType(.regular))
                }

                ExploreFilterChip(
                    title: "오늘 예약",
                    isSelected: container.state.isTodayAvailable
                ) {
                    container.handleIntent(.toggleTodayAvailable)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - 하단 (재검색 / 수업 유닛 / 토스트)

    private var bottomControls: some View {
        VStack(spacing: 12) {
            if let message = container.state.toastMessage {
                ExploreToastView(message: message)
                    .transition(.opacity)
                    .task(id: message) {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        container.handleIntent(.dismissToast)
                    }
            }

            if container.state.showsResearchButton {
                ExploreResearchButton {
                    container.handleIntent(.researchCurrentArea)
                }
            }

            if let selected = container.state.selectedClass {
                ExploreClassCardView(
                    item: selected,
                    classType: container.state.resultClassType,
                    address: container.state.selectedClassAddress,
                    onTap: { navigationPath.append(selected.classId) },
                    onFavoriteToggle: {
                        container.handleIntent(.toggleFavorite(classId: selected.classId))
                    }
                )
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom, 40)
        .animation(.easeInOut(duration: 0.2), value: container.state.selectedClassId)
        .animation(.easeInOut(duration: 0.2), value: container.state.toastMessage)
        .animation(.easeInOut(duration: 0.2), value: container.state.showsResearchButton)
    }

    // MARK: - 위치

    /// 권한 확정 시 1회 — 허용이면 현재 위치, 미허용이면 서울시청 중심으로 최초 검색
    private func resolveLocationIfPossible() {
        guard locationManager.isAuthorizationDetermined else { return }
        if locationManager.isAuthorized {
            guard let coordinate = locationManager.currentCoordinate else { return }
            container.handleIntent(.locationResolved(coordinate: coordinate))
        } else {
            container.handleIntent(.locationResolved(coordinate: nil))
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - 1a~1c 검색바

struct ExploreSearchBar: View {
    @Binding var keyword: String
    let placeholder: String
    let onBack: () -> Void
    let onSearch: () -> Void

    @FocusState private var isFocused: Bool

    private var hasKeyword: Bool {
        !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 0) {
            // 1a 뒤로가기
            Button(action: onBack) {
                Image("BackArrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 32, height: 40)
            }

            Rectangle()
                .fill(Color.Background)
                .frame(width: 1, height: 32)
                .padding(.leading, 6)

            // 1b 검색바 — 선택 시 placeholder 지워지며 키보드 노출
            ZStack(alignment: .leading) {
                if keyword.isEmpty && !isFocused {
                    Text(placeholder)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .lineLimit(1)
                }
                TextField("", text: $keyword)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit { onSearch() }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .padding(.trailing, 8)

            // 1c 검색 — 입력 시 "확인" + #D6F695
            Button(action: onSearch) {
                Text(hasKeyword ? "확인" : "검색")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(searchButtonBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.9))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
    }

    @ViewBuilder
    private var searchButtonBackground: some View {
        if hasKeyword {
            Color.NatureGreen
        } else {
            // #buttonbackground
            RadialGradient(
                stops: [
                    .init(color: Color(red: 1.0, green: 0.925, blue: 0.451), location: 0.486),
                    .init(color: Color(red: 1.0, green: 0.945, blue: 0.600), location: 0.743),
                    .init(color: Color(red: 1.0, green: 0.965, blue: 0.745), location: 1.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 20
            )
        }
    }
}

// MARK: - 필터 칩 (3:28050 비활성 / 3:28209 활성)

struct ExploreFilterChip: View {
    let title: String
    var iconName: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(isSelected ? .MindOrange : .DarkBlack)
                if let iconName {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.MindOrange : Color.Background, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 3c 현위치 버튼

struct ExploreGpsButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image("Gps")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(4)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

// MARK: - 3d 해당 위치 재검색 (27:14434)

struct ExploreResearchButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                    .foregroundColor(.DarkBlack)
                Text("해당 위치 재검색")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
            .padding(8)
            .background(Color.white.opacity(0.9))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - 검색 결과 없음 토스트

struct ExploreToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.75))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
    }
}

// MARK: - 전체화면 카카오맵 Representable

private struct ExploreMapRepresentable: UIViewControllerRepresentable {
    let initialCoordinate: MapCoordinate
    let initialZoomLevel: Int
    let classes: [ClassMapMarkerDTO]
    let selectedClassId: String?
    let cameraCommand: ExploreCameraCommand?
    let onCameraIdle: (MapBoundingBox, Bool) -> Void
    let onCameraCommandFinished: (MapBoundingBox) -> Void
    let onPinTapped: (String) -> Void          // 탭된 classId 전달

    func makeUIViewController(context: Context) -> ExploreMapViewController {
        ExploreMapViewController(
            initialCoordinate: initialCoordinate,
            initialZoomLevel: initialZoomLevel,
            onCameraIdle: onCameraIdle,
            onCameraCommandFinished: onCameraCommandFinished,
            onPinTapped: onPinTapped
        )
    }

    func updateUIViewController(_ uiViewController: ExploreMapViewController, context: Context) {
        // 검색 결과 또는 선택 상태가 바뀔 때 핀 갱신
        uiViewController.updatePois(classes, selectedId: selectedClassId)
        uiViewController.apply(cameraCommand)
    }
}

// MARK: - ExploreMapViewController

final class ExploreMapViewController: UIViewController, MapControllerDelegate {
    private var mapContainer: KMViewContainer?
    private var mapController: KMController?
    private let onCameraIdle: (MapBoundingBox, Bool) -> Void
    private let onCameraCommandFinished: (MapBoundingBox) -> Void
    private let onPinTapped: (String) -> Void

    /// 지도 뷰 참조 — addViewSucceeded 이후 설정, resetEngine 시 nil
    private weak var kakaoMapView: KakaoMap?

    /// 변경 감지용 — 같은 값이면 핀 재렌더 생략
    private var currentClasses: [ClassMapMarkerDTO] = []
    private var currentSelectedId: String?

    /// 마지막으로 처리한 카메라 명령 id / 지도 준비 전 대기 명령
    private var lastCameraCommandId: UUID?
    private var pendingCameraCommand: ExploreCameraCommand?

    private let pinLayerID = "centerPins"

    private let initialCoordinate: MapCoordinate
    private let initialZoomLevel: Int

    init(initialCoordinate: MapCoordinate,
         initialZoomLevel: Int,
         onCameraIdle: @escaping (MapBoundingBox, Bool) -> Void,
         onCameraCommandFinished: @escaping (MapBoundingBox) -> Void,
         onPinTapped: @escaping (String) -> Void) {
        self.initialCoordinate = initialCoordinate
        self.initialZoomLevel = initialZoomLevel
        self.onCameraIdle = onCameraIdle
        self.onCameraCommandFinished = onCameraCommandFinished
        self.onPinTapped = onPinTapped
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        let container = KMViewContainer()
        mapContainer = container
        view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let controller = KMController(viewContainer: mapContainer!)
        controller.delegate = self
        mapController = controller
        controller.prepareEngine()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 엔진이 해제된 상태라면 다시 준비 후 활성화 (prepare → addViews → addViewSucceeded 재실행)
        if mapController?.isEnginePrepared == false {
            mapController?.prepareEngine()
        }
        mapController?.activateEngine()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 수련 상세 push 시에도 호출되므로 reset이 아닌 pause — 복귀 시 지도·핀·카메라 상태 유지
        mapController?.pauseEngine()
    }

    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
    }

    // MARK: - MapControllerDelegate

    func addViews() {
        let mapviewInfo = MapviewInfo(
            viewName: "exploreMapView",
            viewInfoName: "map",
            defaultPosition: MapPoint(longitude: initialCoordinate.longitude, latitude: initialCoordinate.latitude),
            defaultLevel: initialZoomLevel
        )
        mapController?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let mapView = mapController?.getView("exploreMapView") as? KakaoMap else { return }
        kakaoMapView = mapView
        mapView.eventDelegate = self
        setupLabelLayer(mapView)
        // updatePois가 먼저 호출된 경우 지도 준비 후 즉시 렌더
        if !currentClasses.isEmpty {
            refreshPoisOnMap(mapView)
        }
        if let bbox = boundingBox(from: mapView) {
            onCameraIdle(bbox, false)
        }
        // 지도 준비 전에 들어온 카메라 명령 처리
        if let pending = pendingCameraCommand {
            pendingCameraCommand = nil
            move(mapView, with: pending)
        }
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {}

    func containerDidResized(_ size: CGSize) {
        guard let mapView = mapController?.getView("exploreMapView") as? KakaoMap else { return }
        mapView.viewRect = CGRect(origin: .zero, size: size)
    }

    // MARK: - POI 레이어 초기화

    private func setupLabelLayer(_ mapView: KakaoMap) {
        let manager = mapView.getLabelManager()
        let options = LabelLayerOptions(
            layerID: pinLayerID,
            competitionType: .none,
            competitionUnit: .symbolFirst,
            orderType: .rank,
            zOrder: 10000
        )
        manager.addLabelLayer(option: options)
    }

    // MARK: - 카메라 이동 (SwiftUI updateUIViewController 에서 호출)

    func apply(_ command: ExploreCameraCommand?) {
        guard let command, command.id != lastCameraCommandId else { return }
        lastCameraCommandId = command.id
        guard let mapView = kakaoMapView else {
            pendingCameraCommand = command
            return
        }
        move(mapView, with: command)
    }

    private func move(_ mapView: KakaoMap, with command: ExploreCameraCommand) {
        let target = MapPoint(longitude: command.coordinate.longitude, latitude: command.coordinate.latitude)
        let update = CameraUpdate.make(target: target, zoomLevel: command.zoomLevel, mapView: mapView)
        mapView.moveCamera(update) { [weak self, weak mapView] in
            guard let self, let mapView, let bbox = self.boundingBox(from: mapView) else { return }
            DispatchQueue.main.async {
                self.onCameraCommandFinished(bbox)
            }
        }
    }

    // MARK: - POI 업데이트 (SwiftUI updateUIViewController 에서 호출)

    func updatePois(_ classes: [ClassMapMarkerDTO], selectedId: String?) {
        guard classes != currentClasses || selectedId != currentSelectedId else { return }
        currentClasses = classes
        currentSelectedId = selectedId
        guard let mapView = kakaoMapView else { return }
        refreshPoisOnMap(mapView)
    }

    private func refreshPoisOnMap(_ mapView: KakaoMap) {
        let manager = mapView.getLabelManager()
        guard let layer = manager.getLabelLayer(layerID: pinLayerID) else { return }

        layer.clearAllItems()

        // 응답은 최근 등록순(sort=recent) — 앞쪽 수련일수록 상단 노출, 선택 핀은 최상단
        let count = currentClasses.count
        for (index, dto) in currentClasses.enumerated() {
            let isSelected = dto.classId == currentSelectedId
            let image    = makePinImage(name: dto.name, isSelected: isSelected)
            let styleID  = "pin_\(dto.classId)_\(isSelected ? "s" : "n")"

            let iconStyle = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0))
            let perLevel  = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
            let style     = PoiStyle(styleID: styleID, styles: [perLevel])
            manager.addPoiStyle(style)

            let poiOptions = PoiOptions(styleID: styleID)
            poiOptions.rank = isSelected ? count + 1 : count - index
            poiOptions.clickable = true

            let point = MapPoint(longitude: dto.longitude, latitude: dto.latitude)
            let poi = layer.addPoi(option: poiOptions, at: point)
            poi?.userObject = dto.classId as AnyObject
            poi?.show()
        }
    }

    // MARK: - 핀 이미지 렌더링

    private func makePinImage(name: String, isSelected: Bool) -> UIImage {
        let mindOrange = UIColor(red: 1.0,       green: 85/255.0,  blue: 32/255.0,  alpha: 1.0) // #FF5520
        let sandBeige  = UIColor(red: 252/255.0, green: 250/255.0, blue: 244/255.0, alpha: 1.0) // #FCFAF4
        let textColor: UIColor = isSelected ? mindOrange : .black

        let font   = UIFont(name: "Pretendard-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        let hPad: CGFloat   = 8    // 좌우 패딩
        let vPad: CGFloat   = 6    // 상하 패딩
        let tailH: CGFloat  = 6    // 꼬리 높이
        let tailW: CGFloat  = 10   // 꼬리 너비
        let inset: CGFloat  = 4    // 그림자 여백 (상/좌/우)

        let textAttrs: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = (name as NSString).size(withAttributes: textAttrs)

        let bubbleW  = ceil(textSize.width) + hPad * 2
        let bubbleH  = ceil(textSize.height) + vPad * 2
        let cornerR  = bubbleH / 2  // 완전한 필 형태

        // 캔버스: 상/좌/우만 inset, 하단은 꼬리 끝 = 앵커(0.5, 1.0)
        let canvasW  = bubbleW + inset * 2
        let canvasH  = bubbleH + tailH + inset

        let bx = inset              // 버블 x 시작
        let by = inset              // 버블 y 시작
        let bubbleRect  = CGRect(x: bx, y: by, width: bubbleW, height: bubbleH)
        let tailCX      = bx + bubbleW / 2  // 꼬리 중심 x
        let leftCenter  = CGPoint(x: bubbleRect.minX + cornerR, y: bubbleRect.minY + cornerR)
        let rightCenter = CGPoint(x: bubbleRect.maxX - cornerR, y: bubbleRect.minY + cornerR)

        // scale = 1.0 고정: KakaoMaps가 UIImage.scale을 무시하고 픽셀을 포인트로 처리하므로
        // 기본 Retina 배율(2x/3x)로 렌더하면 지도에서 실제보다 2~3배 크게 보임
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasW, height: canvasH), format: format)
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext

            if isSelected {
                // ─── 선택 상태 ───
                // 1. 꼬리: 오렌지 솔리드 fill (그림자 포함)
                //    버블보다 먼저 그려서 버블이 위에 덮어씌워짐
                let tailPath = UIBezierPath()
                tailPath.move(to: CGPoint(x: tailCX - tailW / 2, y: bubbleRect.maxY))
                tailPath.addLine(to: CGPoint(x: tailCX + tailW / 2, y: bubbleRect.maxY))
                tailPath.addLine(to: CGPoint(x: tailCX,             y: bubbleRect.maxY + tailH))
                tailPath.close()

                cgCtx.setShadow(offset: CGSize(width: 0, height: 2), blur: 2,
                                color: UIColor.black.withAlphaComponent(0.15).cgColor)
                mindOrange.setFill()
                tailPath.fill()
                cgCtx.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)

                // 2. 버블: 베이지 fill + 오렌지 테두리 (그림자 없음 — 꼬리에서 처리)
                let bubblePath = UIBezierPath(roundedRect: bubbleRect, cornerRadius: cornerR)
                sandBeige.setFill()
                bubblePath.fill()
                mindOrange.setStroke()
                bubblePath.lineWidth = 1.0
                bubblePath.stroke()

            } else {
                // ─── 미선택 상태 ───
                // 버블 + 꼬리를 단일 경로로 구성
                let path = UIBezierPath()
                path.move(to: CGPoint(x: leftCenter.x,          y: bubbleRect.minY))
                path.addLine(to: CGPoint(x: rightCenter.x,      y: bubbleRect.minY))
                path.addArc(withCenter: rightCenter, radius: cornerR,
                            startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
                path.addLine(to: CGPoint(x: tailCX + tailW / 2, y: bubbleRect.maxY))
                path.addLine(to: CGPoint(x: tailCX,             y: bubbleRect.maxY + tailH))
                path.addLine(to: CGPoint(x: tailCX - tailW / 2, y: bubbleRect.maxY))
                path.addLine(to: CGPoint(x: leftCenter.x,       y: bubbleRect.maxY))
                path.addArc(withCenter: leftCenter, radius: cornerR,
                            startAngle: .pi / 2, endAngle: -.pi / 2, clockwise: true)
                path.close()

                // 아주 약한 그림자 — 핀 형태만 구분될 정도
                cgCtx.setShadow(offset: CGSize(width: 0, height: 1), blur: 1,
                                color: UIColor.black.withAlphaComponent(0.05).cgColor)
                sandBeige.setFill()
                path.fill()
                cgCtx.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)
            }

            // ─── 텍스트 (공통) ───
            let textRect = CGRect(
                x: bubbleRect.minX + hPad,
                y: bubbleRect.minY + (bubbleH - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            (name as NSString).draw(in: textRect, withAttributes: [
                .font: font,
                .foregroundColor: textColor
            ])
        }
    }


    // MARK: - BoundingBox 계산

    private func boundingBox(from mapView: KakaoMap) -> MapBoundingBox? {
        let size = mapView.viewRect.size
        let sw = mapView.getPosition(CGPoint(x: 0, y: size.height))
        let ne = mapView.getPosition(CGPoint(x: size.width, y: 0))

        return MapBoundingBox(
            swLat: sw.wgsCoord.latitude,
            swLng: sw.wgsCoord.longitude,
            neLat: ne.wgsCoord.latitude,
            neLng: ne.wgsCoord.longitude
        )
    }
}

// MARK: - KakaoMapEventDelegate

extension ExploreMapViewController: KakaoMapEventDelegate {
    func cameraDidStopped(kakaoMap: KakaoMap, by: MoveBy) {
        guard let bbox = boundingBox(from: kakaoMap) else { return }
        // 사용자 스크롤/줌인-아웃 여부 — 3d 재검색 버튼 노출 판단
        let isUserGesture = by != .notUserAction
        DispatchQueue.main.async { [weak self] in
            self?.onCameraIdle(bbox, isUserGesture)
        }
    }

    func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
        guard layerID == pinLayerID else { return }
        let manager = kakaoMap.getLabelManager()
        guard let layer   = manager.getLabelLayer(layerID: layerID),
              let poi     = layer.getPoi(poiID: poiID),
              let classId = poi.userObject as? String else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onPinTapped(classId)
        }
    }
}

#Preview {
    ExploreTabView(onBackTapped: {})
}

#Preview("SearchBar") {
    ExploreSearchBar(keyword: .constant(""), placeholder: ExploreClassType.oneDay.placeholder, onBack: {}, onSearch: {})
        .padding()
}
