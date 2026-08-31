//
//  LocationModuleView.swift
//  YOGHEE
//

import SwiftUI
import KakaoMapsSDK

/// 7a 지도 / 7b 상세 위치 모듈
struct LocationModuleView: View {
    let detail: YogaClassDetailDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionDivider

            sectionLabel("수련 장소")

            // 7a 지도
            if let lat = detail.center?.latitude,
               let lng = detail.center?.longitude,
               let name = detail.center?.name {
                KakaoMapRepresentable(
                    latitude: lat,
                    longitude: lng,
                    placeName: name
                )
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                mapPlaceholder
            }

            // 7b 상세 위치 설명 (지도 바로 아래, 별도 라벨 없음)
            if let description = detail.center?.description, !description.isEmpty {
                Text(String(description.prefix(3000)))
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 16)
    }

    private var mapPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 200)
            .overlay(
                Text("위치 정보 없음")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.gray)
            )
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.bold, size: 14)
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.DarkBlack, lineWidth: 1)
            )
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
    }
}

// MARK: - 카카오맵 UIViewControllerRepresentable

private struct KakaoMapRepresentable: UIViewControllerRepresentable {
    let latitude: Double
    let longitude: Double
    let placeName: String

    func makeUIViewController(context: Context) -> KakaoMapHostViewController {
        KakaoMapHostViewController(latitude: latitude, longitude: longitude, placeName: placeName)
    }

    func updateUIViewController(_ uiViewController: KakaoMapHostViewController, context: Context) {}
}

// MARK: - KakaoMapHostViewController

private final class KakaoMapHostViewController: UIViewController, MapControllerDelegate {
    private let latitude: Double
    private let longitude: Double
    private let placeName: String

    private var mapContainer: KMViewContainer?
    private var mapController: KMController?

    init(latitude: Double, longitude: Double, placeName: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.placeName = placeName
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
        mapController?.resetEngine()
    }

    // MARK: - MapControllerDelegate

    func addViews() {
        let mapviewInfo = MapviewInfo(
            viewName: "mapView",
            viewInfoName: "map",
            defaultPosition: MapPoint(longitude: longitude, latitude: latitude),
            defaultLevel: 13
        )
        mapController?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let mapView = mapController?.getView("mapView") as? KakaoMap else { return }
        addPlaceMarker(to: mapView)
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {}

    func containerDidResized(_ size: CGSize) {
        guard let mapView = mapController?.getView("mapView") as? KakaoMap else { return }
        mapView.viewRect = CGRect(origin: .zero, size: size)
    }

    // MARK: - 마커

    private func addPlaceMarker(to mapView: KakaoMap) {
        let manager = mapView.getLabelManager()
        let layerOption = LabelLayerOptions(
            layerID: "placeLayer",
            competitionType: .none,
            competitionUnit: .poi,
            orderType: .rank,
            zOrder: 10001
        )
        guard let layer = manager.addLabelLayer(option: layerOption) else { return }

        let balloonImage = makeBalloonImage(text: placeName) ?? UIImage()
        let iconStyle = PoiIconStyle(symbol: balloonImage, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let poiStyle = PoiStyle(styleID: "placeMarkerStyle", styles: [
            PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
        ])
        manager.addPoiStyle(poiStyle)

        let poi = layer.addPoi(
            option: PoiOptions(styleID: "placeMarkerStyle"),
            at: MapPoint(longitude: longitude, latitude: latitude)
        )
        poi?.show()
    }

    // 피그마 스펙 (node: 3549:11362 YogaName/RouteOnly)
    // - Pill: sand-beige 배경 + mind-orange 1px 테두리 + p-8 + rounded-28 + 고정높이 30pt
    // - 꼬리: 8×8 정사각형 45° 회전 다이아몬드, pill 하단에 6pt 겹침 (mb-[-6px])
    // - 전체 drop-shadow: offset(0,2) blur(2) rgba(0,0,0,0.15)
    // - KakaoMapsSDK는 UIImage.scale을 무시하고 raw 픽셀을 point로 렌더링하므로
    //   format.scale=1.0 + CTM scale로 Retina 품질을 유지하면서 정확한 포인트 크기를 보장한다.
    private func makeBalloonImage(text: String) -> UIImage? {
        let hPadding:       CGFloat = 8
        let pillHeight:     CGFloat = 30    // 피그마 고정값 (폰트 메트릭 편차 방지)
        let cornerRadius:   CGFloat = 28
        let borderWidth:    CGFloat = 1
        let diamondSize:    CGFloat = 8     // 8×8 정사각형 → 45° 회전 시 대각선 ≈ 11.31pt
        let diamondOverlap: CGFloat = 6     // pill과 겹치는 양 (mb-[-6px])
        let shadowOffset                    = CGSize(width: 0, height: 2)
        let shadowBlur:     CGFloat         = 2
        let shadowColor                     = UIColor.black.withAlphaComponent(0.15)

        let mindOrange = UIColor(red: 1.0,   green: 0.333, blue: 0.125, alpha: 1.0)  // #ff5520
        let sandBeige  = UIColor(red: 0.988, green: 0.980, blue: 0.957, alpha: 1.0)  // #fcfaf4

        let font = UIFont(name: Font.PretendardWeight.medium.name, size: 12)
                ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        let textAttr: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: mindOrange,
            .kern: -0.408,
        ]

        let textSize  = (text as NSString).size(withAttributes: textAttr)
        let pillWidth = ceil(textSize.width + hPadding * 2)

        let halfDiag   = diamondSize * sqrt(2.0) / 2.0  // ≈ 5.66pt
        let tailH      = halfDiag * 2 - diamondOverlap  // ≈ 5.31pt  (pill 아래로 나오는 꼬리 높이)
        let shapeWidth = max(pillWidth, halfDiag * 2)

        // 그림자 번짐 공간: 좌우·상단에만 추가
        // 하단 패딩 없음 → 꼬리 끝 = 이미지 바닥 → anchorPoint(0.5, 1.0)이 맵 좌표에 정확히 닿음
        let padH:   CGFloat = shadowBlur
        let padTop: CGFloat = shadowBlur

        let canvasW = padH + shapeWidth + padH
        let canvasH = padTop + pillHeight + tailH

        let s = UIScreen.main.scale
        let format = UIGraphicsImageRendererFormat()
        format.scale  = 1.0
        format.opaque = false

        return UIGraphicsImageRenderer(
            size: CGSize(width: canvasW * s, height: canvasH * s),
            format: format
        ).image { ctx in
            let cg = ctx.cgContext
            cg.scaleBy(x: s, y: s)

            let cx = padH + shapeWidth / 2

            // drop-shadow를 전체 컴포넌트 외곽에 한 번만 적용 (투명도 레이어로 묶음)
            cg.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor.cgColor)
            cg.beginTransparencyLayer(auxiliaryInfo: nil)

            // 1. 다이아몬드 꼬리 (8×8 정사각형 45° 회전, pill 하단에 overlap만큼 겹침)
            let diamondCenterY = padTop + pillHeight - diamondOverlap + halfDiag
            cg.saveGState()
            cg.translateBy(x: cx, y: diamondCenterY)
            cg.rotate(by: .pi / 4)
            mindOrange.setFill()
            UIBezierPath(rect: CGRect(x: -diamondSize / 2, y: -diamondSize / 2,
                                      width: diamondSize,  height: diamondSize)).fill()
            cg.restoreGState()

            // 2. Pill 배경 (다이아몬드 위에 겹쳐 경계 정리)
            let pillX = padH + (shapeWidth - pillWidth) / 2
            let insetRect = CGRect(
                x: pillX + borderWidth / 2,
                y: padTop + borderWidth / 2,
                width:  pillWidth  - borderWidth,
                height: pillHeight - borderWidth
            )
            let pillPath = UIBezierPath(roundedRect: insetRect, cornerRadius: cornerRadius)
            sandBeige.setFill()
            pillPath.fill()

            // 3. Pill 테두리
            mindOrange.setStroke()
            pillPath.lineWidth = borderWidth
            pillPath.stroke()

            // 4. 텍스트
            let textRect = CGRect(
                x: cx - textSize.width / 2,
                y: padTop + (pillHeight - textSize.height) / 2,
                width:  textSize.width,
                height: textSize.height
            )
            NSAttributedString(string: text, attributes: textAttr).draw(in: textRect)

            cg.endTransparencyLayer()
        }
    }
}
