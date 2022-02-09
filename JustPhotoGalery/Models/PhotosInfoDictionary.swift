//
//  PhotosInfo.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

typealias PhotosInfoDictionary = [String: Photo]

struct Photo: Codable {
    let photoURL, userURL: String?
    let userName: String?
    let colors: [String]?

    enum CodingKeys: String, CodingKey {
        case photoURL
        case userURL
        case userName
        case colors
    }
}


