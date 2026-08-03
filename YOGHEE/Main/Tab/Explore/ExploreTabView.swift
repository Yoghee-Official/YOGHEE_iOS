//
//  ExploreTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI
import KakaoMapsSDK

struct ExploreTabView: View {
    @StateObject private var container = ExploreTabContainer()

    var body: some View {
        ZStack(alignment: .top) {
            ExploreMapRepresentable { bbox in
                container.handleIntent(.searchClasses(bbox: bbox))
            }
            .ignoresSafeArea()

            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 8) {
                    ExploreBackButton()
                    ExploreSearchBar()
                }

                ExploreGpsButton()
            }
            .padding(.horizontal, 16)
            .padding(.top, 17)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - 뒤로가기 버튼 (2899:22072)

struct ExploreBackButton: View {
    var body: some View {
        Button {
            // TODO: 기능 확인 후 개발 필요
            print("뒤로가기 버튼 탭 - TODO: 기능 확인 후 개발 필요")
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
    var body: some View {
        HStack(spacing: 0) {
            Text("검색어를 입력하세요.")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.Info)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)

            Button {
                // TODO: 기능 확인 후 개발 필요
                print("검색 버튼 탭 - TODO: 기능 확인 후 개발 필요")
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

    func makeUIViewController(context: Context) -> ExploreMapViewController {
        ExploreMapViewController(onBoundingBoxChange: onBoundingBoxChange)
    }

    func updateUIViewController(_ uiViewController: ExploreMapViewController, context: Context) {}
}

// MARK: - ExploreMapViewController

final class ExploreMapViewController: UIViewController, MapControllerDelegate {
    private var mapContainer: KMViewContainer?
    private var mapController: KMController?
    private var debounceWork: DispatchWorkItem?
    private let onBoundingBoxChange: (MapBoundingBox) -> Void

    private let defaultLatitude:  Double = 37.5666805
    private let defaultLongitude: Double = 126.9784147
    private let defaultZoomLevel: Int    = 9

    init(onBoundingBoxChange: @escaping (MapBoundingBox) -> Void) {
        self.onBoundingBoxChange = onBoundingBoxChange
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
            viewName: "exploreMapView",
            viewInfoName: "map",
            defaultPosition: MapPoint(longitude: defaultLongitude, latitude: defaultLatitude),
            defaultLevel: defaultZoomLevel
        )
        mapController?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let mapView = mapController?.getView("exploreMapView") as? KakaoMap else { return }
        mapView.eventDelegate = self
        triggerSearchAfterDelay(mapView: mapView)
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {}

    func containerDidResized(_ size: CGSize) {
        guard let mapView = mapController?.getView("exploreMapView") as? KakaoMap else { return }
        mapView.viewRect = CGRect(origin: .zero, size: size)
    }

    // MARK: - 디바운스 검색

    private func triggerSearchAfterDelay(mapView: KakaoMap) {
        debounceWork?.cancel()
        let work = DispatchWorkItem { [weak self, weak mapView] in
            guard let self, let mapView else { return }
            if let bbox = self.boundingBox(from: mapView) {
                self.onBoundingBoxChange(bbox)
            }
        }
        debounceWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
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

// MARK: - KakaoMapEventDelegate (지도 카메라 멈춤 감지)

extension ExploreMapViewController: KakaoMapEventDelegate {
    func cameraDidStopped(kakaoMap: KakaoMap, by: MoveBy) {
        triggerSearchAfterDelay(mapView: kakaoMap)
    }
}

#Preview {
    ExploreTabView()
}
