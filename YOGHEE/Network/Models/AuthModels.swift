import Foundation

enum SSOType: String, CaseIterable {
    case kakao = "k"
    case google = "g"
    case apple = "a"
    
    var displayName: String {
        switch self {
        case .kakao: return "카카오"
        case .google: return "구글"
        case .apple: return "애플"
        }
    }
}

struct SSOLoginResponse: Codable {
    let code: Int?
    let status: String?
    let data: String?
//    enum CodingKeys: String, CodingKey {
//        case token = "token"
//        case message = "message"
//    }
}

// 에러 응답 모델
struct AuthErrorResponse: Codable {
    let error: String?
    let message: String?
}

// MARK: - 일반 로그인
struct LoginRequest: Codable {
    let userId: String
    let password: String
}

struct LoginResponse: Codable {
    let code: Int
    let status: String
    let data: LoginDataDTO
}

struct LoginDataDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: Int
    let refreshTokenExpiresIn: Int
}
