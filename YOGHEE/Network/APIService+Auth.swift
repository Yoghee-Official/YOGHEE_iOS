import Foundation
import Alamofire

extension APIService {
    /// SSO 로그인 콜백 처리
    /// - Parameters:
    ///   - token: SSO 인가코드
    ///   - ssoType: SSO 타입 (k: 카카오, g: 구글, a: 애플)
    /// - Returns: JWT 토큰이 포함된 응답
    func ssoLogin(token: String, ssoType: SSOType) async throws -> SSOLoginResponse {
        let parameters: Parameters = [
            "token": token,
            "sso": ssoType.rawValue
        ]
        
        return try await get(endPoint: "/auth/sso/callback", parameters: parameters)
    }
    
    /// 토큰 갱신 (자동 로그인 유지)
        /// - Parameters:
        ///   - accessToken: 현재 accessToken
        ///   - refreshToken: 현재 refreshToken
        /// - Returns: 새로운 토큰이 포함된 응답
        func refreshLoginToken(accessToken: String, refreshToken: String) async throws -> SSOLoginResponse {
            let parameters: Parameters = [
                "accessToken": accessToken,
                "refreshToken": refreshToken
            ]
            
            return try await post(endPoint: "/auth/refresh", parameters: parameters)
        }
}
