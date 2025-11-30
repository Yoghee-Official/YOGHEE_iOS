import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://www.yoghee.xyz"
    
    private init() {}
    
    // MARK: - Endpoints
    private enum Endpoint {
        case main(type: String)
        case categoryDetail(categoryId: String)
        case notifications
        
        var path: String {
            switch self {
            case .main:
                return "/api/main/"
            case .categoryDetail(let id):
                return "/api/category/\(id)/"
            case .notifications:
                return "/api/notifications/"
            }
        }
        
        var parameters: Parameters? {
            switch self {
            case .main(let type):
                return ["type": type]
            case .categoryDetail, .notifications:
                return nil
            }
        }
    }
    
    // MARK: - API Methods
    
    /// 메인 데이터 조회
    func getMainData(type: String) async throws -> MainResponse {
        let endpoint = Endpoint.main(type: type)
        return try await get(endPoint: endpoint.path, parameters: endpoint.parameters)
    }
    
    /// 카테고리 상세 조회 (추후 개발 예정)
    func getCategoryDetail(categoryId: String) async throws -> MainResponse {
        let endpoint = Endpoint.categoryDetail(categoryId: categoryId)
        return try await get(endPoint: endpoint.path, parameters: endpoint.parameters)
    }
    
    /// 알림 목록 조회 (추후 개발 예정)
    func getNotifications() async throws -> MainResponse {
        let endpoint = Endpoint.notifications
        return try await get(endPoint: endpoint.path, parameters: endpoint.parameters)
    }
    
    // MARK: - Internal Methods
    
    /// GET 요청을 위한 기본 메서드 (Extension에서도 사용 가능)
    func get<T: Codable>(endPoint: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) async throws -> T {
        let url = baseURL + endPoint
        
        print("🌐 API 호출 시작")
        print("URL: \(url)")
        print("Parameters: \(parameters ?? [:])")
        print("Headers: \(headers ?? [:])")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get, parameters: parameters, headers: headers)
                .validate()
                .responseData { response in
                    print("📡 API 응답 받음")
                    print("Status Code: \(response.response?.statusCode ?? 0)")
                    print("Response Data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")")
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            let decodedValue = try JSONDecoder().decode(T.self, from: data)
                            print("✅ 디코딩 성공: \(decodedValue)")
                            continuation.resume(returning: decodedValue)
                        } catch {
                            print("❌ 디코딩 실패: \(error)")
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        print("❌ 네트워크 에러: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
