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

// MARK: - Preview Mock Data
#if DEBUG
extension CategoryClassDTO {
    static let mockData = CategoryClassDTO(
        classId: "1",
        className: "반려견과 자연에서! 빈야사 요가",
        address: "서울 영등포구 당산동",
        images: [
            "https://via.placeholder.com/343x211/FF5520/FFFFFF?text=Image+1",
            "https://via.placeholder.com/343x211/D6F695/000000?text=Image+2",
            "https://via.placeholder.com/343x211/FFEC73/000000?text=Image+3"
        ],
        masterId: "master1",
        masterName: "명요가 원장",
        rating: 4.6,
        review: 194,
        price: 12000,
        favoriteCount: 13387,
        isFavorite: false,
        discount: 47,
        clubDiscount: 5,
        isYogheeClub: true
    )
}
#endif
