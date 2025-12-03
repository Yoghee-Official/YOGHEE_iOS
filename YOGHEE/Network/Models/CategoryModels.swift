//
//  CategoryModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/3/25.
//

import Foundation

struct CategoryClassDTO: Codable, Equatable {
    let classId: String
    let className: String
    var address: String
    let images: [String]
    let masterId: String
    let masterName: String
    let rating: Double
    let review: Int
    let price: Int
    var favoriteCount: Int
    var isFavorite: Bool
    
    //TODO: 아직 API에 없는 DATA
    var discount: Int = -7
    var clubDiscount: Int = -8
    var isYogheeClub: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case classId, className, address, images, masterId, masterName, rating, review, price, favoriteCount, isFavorite
    }
}
