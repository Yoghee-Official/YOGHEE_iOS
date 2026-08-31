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
    @State private var keyword: String = ""
    /// 지도가 제공하는 현재 bbox — 검색 버튼 탭 시에만 사용 (지도 이동으로는 검색 미실행)
    @State private var currentBbox: MapBoundingBox? = nil
    /// 키보드 표시 여부 — NotificationCenter로 감지, 바텀시트 숨김 여부 결정
    @State private var isKeyboardVisible: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            ExploreMapRepresentable(
                onBoundingBoxChange: { bbox in currentBbox = bbox },
                onPinTapped: { classId in
                    container.handleIntent(.selectClass(id: classId))
                },
                classes: container.state.classes,
                selectedClassId: container.state.selectedClassId
            )
            .ignoresSafeArea()

            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 8) {
                    ExploreBackButton(onTap: onBackTapped)
                    ExploreSearchBar(
                        keyword: $keyword,
                        onSearch: {
                            dismissKeyboard()
                            guard let bbox = currentBbox else { return }
                            container.handleIntent(
                                .searchClasses(bbox: bbox, keyword: keyword.isEmpty ? nil : keyword)
                            )
                        }
                    )
                }

                ExploreGpsButton()
            }
            .padding(.horizontal, 16)
            .padding(.top, 17)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .bottom) {
            ExploreBottomSheetView(
                classes: container.state.classes,
                isKeyboardVisible: isKeyboardVisible
            )
        }
        // 키보드 표시/숨김 감지 → 바텀시트 z축 제어
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - 뒤로가기 버튼 (2899:22072)

struct ExploreBackButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Image("BackArrow")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .frame(width: 48, height: 48)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - 검색바 (2899:22052)

struct ExploreSearchBar: View {
    @Binding var keyword: String
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            TextField("검색어를 입력하세요.", text: $keyword)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .submitLabel(.search)
                .onSubmit { onSearch() }  // 키보드 검색 버튼 탭 시

            Button {
                onSearch()
            } label: {
                Text("검색")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.929, blue: 0.451),
                                Color(red: 1.0, green: 0.945, blue: 0.600),
                                Color(red: 1.0, green: 0.965, blue: 0.745)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .clipShape(Circle())
            }
            .padding(.trailing, 4)
        }
        .frame(height: 48)
        .background(Color.white.opacity(0.9))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
    }
}

// MARK: - GPS 버튼 (2899:22074)

struct ExploreGpsButton: View {
    var body: some View {
        Button {
            // TODO: 기능 확인 후 개발 필요
            print("GPS 버튼 탭 - TODO: 기능 확인 후 개발 필요")
        } label: {
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

// MARK: - 전체화면 카카오맵 Representable

private struct ExploreMapRepresentable: UIViewControllerRepresentable {
    let onBoundingBoxChange: (MapBoundingBox) -> Void
    let onPinTapped: (String) -> Void          // 탭된 classId 전달
    let classes: [ClassMapSearchDTO]
    let selectedClassId: String?

    func makeUIViewController(context: Context) -> ExploreMapViewController {
        ExploreMapViewController(
            onBoundingBoxChange: onBoundingBoxChange,
            onPinTapped: onPinTapped
        )
    }

    func updateUIViewController(_ uiViewController: ExploreMapViewController, context: Context) {
        // 검색 결과 또는 선택 상태가 바뀔 때 핀 갱신
        uiViewController.updatePois(classes, selectedId: selectedClassId)
    }
}

// MARK: - ExploreMapViewController

final class ExploreMapViewController: UIViewController, MapControllerDelegate {
    private var mapContainer: KMViewContainer?
    private var mapController: KMController?
    private let onBoundingBoxChange: (MapBoundingBox) -> Void
    private let onPinTapped: (String) -> Void

    /// 지도 뷰 참조 — addViewSucceeded 이후 설정, resetEngine 시 nil
    private weak var kakaoMapView: KakaoMap?

    /// 변경 감지용 — 같은 값이면 핀 재렌더 생략
    private var currentClasses: [ClassMapSearchDTO] = []
    private var currentSelectedId: String?

    private let pinLayerID = "centerPins"

    private let defaultLatitude:  Double = 37.5666805
    private let defaultLongitude: Double = 126.9784147
    private let defaultZoomLevel: Int    = 9

    init(onBoundingBoxChange: @escaping (MapBoundingBox) -> Void,
         onPinTapped: @escaping (String) -> Void) {
        self.onBoundingBoxChange = onBoundingBoxChange
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
        mapController?.activateEngine()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        kakaoMapView = nil
        mapController?.resetEngine()
    }

    // MARK: - MapControllerDelegate

    func addViews() {
        let mapviewInfo = MapviewInfo(
            viewName: "exploreMapView",
            viewInfoName: "map",
            defaultPosition: MapPoint(longitude: defaultLongitude, latitude: defaultLatitude),
            defaultLevel: defaultZoomLevel
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
            onBoundingBoxChange(bbox)
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

    // MARK: - POI 업데이트 (SwiftUI updateUIViewController 에서 호출)

    func updatePois(_ classes: [ClassMapSearchDTO], selectedId: String?) {
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

        for dto in currentClasses {
            let isSelected = dto.classId == currentSelectedId
            let image    = makePinImage(name: dto.centerName, isSelected: isSelected)
            let styleID  = "pin_\(dto.classId)_\(isSelected ? "s" : "n")"

            let iconStyle = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0))
            let perLevel  = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
            let style     = PoiStyle(styleID: styleID, styles: [perLevel])
            manager.addPoiStyle(style)

            let poiOptions = PoiOptions(styleID: styleID)
            poiOptions.rank = isSelected ? 1 : 0   // 선택된 핀이 위에 렌더
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
        if let bbox = boundingBox(from: kakaoMap) {
            onBoundingBoxChange(bbox)
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
    ExploreSearchBar(keyword: .constant(""), onSearch: {})
        .padding()
}
