import Foundation
import Alamofire

extension APIService {
    
    /// SSO 로그인 콜백 처리
    /// - Parameters:
    ///   - code: SSO 인가코드
    ///   - ssoType: SSO 타입 (k: 카카오, g: 구글, a: 애플)
    /// - Returns: JWT 토큰이 포함된 응답
    func ssoLogin(code: String, ssoType: SSOType) async throws -> SSOLoginResponse {
        let parameters: Parameters = [
            "code": code,
            "sso": ssoType.rawValue
        ]
        
        return try await get(endPoint: "/auth/sso/callback", parameters: parameters)
    }
}
