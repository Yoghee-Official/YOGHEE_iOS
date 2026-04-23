//
//  ContentTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum ContentTabIntent {
    case loadFeed
}

// MARK: - State
struct ContentTabState: Equatable {
    var weekLabel: String = ""
    var items: [FeedItemDTO] = []
    var isLoading: Bool = false
    var isEmpty: Bool = false
    var errorMessage: String?
}

@MainActor
class ContentTabContainer: ObservableObject {
    @Published private(set) var state = ContentTabState()

    init() {
        loadFeed()
    }

    func handleIntent(_ intent: ContentTabIntent) {
        switch intent {
        case .loadFeed:
            loadFeed()
        }
    }

    private func loadFeed() {
        state.isLoading = true
        state.isEmpty = false
        state.errorMessage = nil

        Task { @MainActor in
            do {
                let response = try await APIService.shared.getFeed()
                state.weekLabel = response.data.weekLabel
                state.items = response.data.items
                state.isLoading = false
            } catch APIError.notFound {
                state.isEmpty = true
                state.isLoading = false
            } catch {
                state.errorMessage = error.localizedDescription
                state.isLoading = false
            }
        }
    }
}
