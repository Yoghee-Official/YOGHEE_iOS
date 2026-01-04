import Foundation
import Alamofire

// MARK: - API Error
enum APIError: Error {
    case unauthorized
    case tokenExpired
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .unauthorized:
            return "로그인이 필요합니다"
        case .tokenExpired:
            return "토큰이 만료되었습니다"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "데이터 오류: \(error.localizedDescription)"
        case .invalidResponse:
            return "잘못된 응답입니다"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://www.yoghee.xyz"
    
    private init() {}
    
    // MARK: - Debug Logging
    private func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
    
    // MARK: - Token Access (AuthManager에서 관리)
    // 토큰은 AuthManager에서 관리하므로, 여기서는 읽기만 가능
    func getAccessToken() async -> String? {
        return await AuthManager.shared.accessToken
    }
    
    // MARK: - Endpoints
    private enum Endpoint {
        case login
        case main(type: String)
        case categoryClasses(categoryId: String, type: String)
        case categoryDetail(categoryId: String)
        case notifications
        case myPage
        
        var path: String {
            switch self {
            case .login:
                return "/auth/login"
            case .main:
                return "/api/main/"
            case .categoryClasses(let categoryId, _):
                return "/api/class/category/\(categoryId)"
            case .categoryDetail(let id):
                return "/api/category/\(id)/"
            case .notifications:
                return "/api/notifications/"
            case .myPage:
                return "/api/my/"
            }
        }
        
        var parameters: Parameters? {
            switch self {
            case .main(let type):
                return ["type": type]
            case .categoryClasses(_, let type):
                return ["type": type]
            case .login, .categoryDetail, .notifications, .myPage:
                return nil
            }
        }
    }
    
    // MARK: - API Methods
    
    /// 로그인
//    func login(userId: String, password: String) async throws -> LoginResponse {
//        let endpoint = Endpoint.login
//        let parameters: Parameters = [
//            "userId": userId,
//            "password": password
//        ]
//        
//        let response: LoginResponse = try await post(endPoint: endpoint.path, parameters: parameters)
//        
//        // AuthManager에 토큰 저장
//        await MainActor.run {
//            AuthManager.shared.accessToken = response.data.accessToken
//            AuthManager.shared.refreshToken = response.data.refreshToken
//        }
//        
//        return response
//    }
    
    /// 메인 데이터 조회
    func getMainData(type: String) async throws -> MainResponse {
        let endpoint = Endpoint.main(type: type)
        return try await get(endPoint: endpoint.path, parameters: endpoint.parameters)
    }
    
    /// 카테고리별 클래스 조회
    func getCategoryClasses(categoryId: String, type: String) async throws -> CategoryClassResponse {
        let endpoint = Endpoint.categoryClasses(categoryId: categoryId, type: type)
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
    
    /// 마이페이지 데이터 조회
    func getMyPageData() async throws -> MyPageResponse {
        let endpoint = Endpoint.myPage
        
        // AuthManager에서 토큰 가져오기
        guard let token = await getAccessToken() else {
            throw APIError.unauthorized
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        return try await get(endPoint: endpoint.path, parameters: endpoint.parameters, headers: headers)
    }
    
    // MARK: - Internal Methods
    
    // MARK: - Internal Methods
    
    /// 공통 요청 처리 메서드
    private func request<T: Codable>(
        method: HTTPMethod,
        endPoint: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        let url = baseURL + endPoint
        
        log("🌐 API 호출 시작 (\(method.rawValue))")
        log("URL: \(url)")
        log("Parameters: \(parameters ?? [:])")
        log("Headers: \(headers ?? [:])")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate()
                .responseData { [weak self] response in
                    self?.log("📡 API 응답 받음")
                    self?.log("Status Code: \(response.response?.statusCode ?? 0)")
                    self?.log("Response Data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")")
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            let decodedValue = try JSONDecoder().decode(T.self, from: data)
                            self?.log("✅ 디코딩 성공")
                            continuation.resume(returning: decodedValue)
                        } catch {
                            self?.log("❌ 디코딩 실패: \(error)")
                            continuation.resume(throwing: APIError.decodingError(error))
                        }
                    case .failure(let error):
                        self?.log("❌ 네트워크 에러: \(error)")
                        continuation.resume(throwing: APIError.networkError(error))
                    }
                }
        }
    }
    
    /// GET 요청을 위한 기본 메서드 (Extension에서도 사용 가능)
    func get<T: Codable>(endPoint: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) async throws -> T {
        return try await request(method: .get, endPoint: endPoint, parameters: parameters, headers: headers)
    }
    
    /// POST 요청을 위한 기본 메서드
    func post<T: Codable>(endPoint: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) async throws -> T {
        return try await request(method: .post, endPoint: endPoint, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
}

