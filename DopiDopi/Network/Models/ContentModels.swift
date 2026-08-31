//
//  ContentModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 4/23/26.
//

import Foundation

struct FeedResponse: Codable {
    let code: Int
    let status: String
    let data: FeedDTO
}

struct FeedDTO: Codable {
    let weekLabel: String
    let items: [FeedItemDTO]
}

struct FeedItemDTO: Codable, Equatable {
    let title: String?
    let description: String?
    let imageUrl: String
}
