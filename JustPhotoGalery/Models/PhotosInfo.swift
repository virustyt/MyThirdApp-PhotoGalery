//
//  PhotosInfo.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

typealias PhotosInfoDictionary = [String: PhotosInfo]

struct PhotosInfo: Codable, Hashable {
    let photoURL, userURL: String?
    let userName: String?
    let colors: [String]?

    enum CodingKeys: String, CodingKey {
        case photoURL = "photo_url"
        case userURL = "user_url"
        case userName = "user_name"
        case colors
    }
}


