//
//  ClassDetailView.swift
//  YOGHEE
//

import SwiftUI

struct ClassDetailView: View {
    let classId: String

    @StateObject private var container = ClassDetailContainer()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if container.state.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = container.state.errorMessage {
                VStack(spacing: 16) {
                    Text("오류가 발생했습니다")
                        .pretendardFont(.semiBold, size: 17)
                    Text(error)
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.gray)
                    Button("다시 시도") {
                        container.handleIntent(.load(classId: classId))
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = container.state.detail {
                ScrollView {
                    Text(detail.name)
                        .pretendardFont(.semiBold, size: 20)
                        .padding()
                }
            }
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: container.state.detail?.name ?? "")
        .task {
            container.handleIntent(.load(classId: classId))
        }
    }
}
