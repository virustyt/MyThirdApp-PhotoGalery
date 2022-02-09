//
//  PhotosInfoManager.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

protocol PhotosInfoManagerProtocol {
    func getAllPhotos() -> [Photo]
    func deletePhotoBy(fileName name: String)
}

class PhotosInfoManager: PhotosInfoManagerProtocol {

    private var photos = PhotosInfoDictionary()

    func deletePhotoBy(fileName name: String) {
        photos[name] = nil
    }

    func getAllPhotos() -> [Photo] {
        photos.map{ $0.value }
    }
}
