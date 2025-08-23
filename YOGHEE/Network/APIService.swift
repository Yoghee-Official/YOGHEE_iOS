import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://www.yoghee.xyz"
    
    private init() {}
    
    // GET 요청을 위한 기본 메서드
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
