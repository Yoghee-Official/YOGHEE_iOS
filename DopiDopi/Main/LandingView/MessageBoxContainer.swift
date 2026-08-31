//
//  MessageBoxContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/2/25.
//

import SwiftUI

// MARK: - Intent
enum MessageBoxIntent {
    case loadMessages
    case markAsRead(String)
    case deleteMessage(String)
    // TODO: 추가 Intent
}

// MARK: - State
struct MessageBoxState: Equatable {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    // TODO: 메시지 관련 상태 추가
}

@MainActor
class MessageBoxContainer: ObservableObject {
    @Published private(set) var state = MessageBoxState()
    
    init() {
        // TODO: 초기화 로직
    }
    
    func handleIntent(_ intent: MessageBoxIntent) {
        switch intent {
        case .loadMessages:
            loadMessages()
        case .markAsRead(let messageId):
            markAsRead(messageId: messageId)
        case .deleteMessage(let messageId):
            deleteMessage(messageId: messageId)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadMessages() {
        // TODO: API 호출하여 메시지 로드
    }
    
    private func markAsRead(messageId: String) {
        // TODO: 메시지 읽음 처리
    }
    
    private func deleteMessage(messageId: String) {
        // TODO: 메시지 삭제
    }
}
