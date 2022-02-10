//
//  PhotosInfoManager.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

protocol PhotosInfoManagerProtocol {
    func getAllPhotos(completion: ((Result<PhotosInfoDictionary, Error>) -> ())?)
    func deletePhotoBy(fileName name: String)
}

extension PhotosInfoManagerProtocol {
    func getAllPhotos() {
        getAllPhotos(completion: nil)
    }
}

class PhotosInfoManager: PhotosInfoManagerProtocol {

    static var shared = PhotosInfoManager()

    var networkManager: PhotoNetClientProtocol = PhotoNetClient.shared

    private var photos = PhotosInfoDictionary()
    private var downloadPhotosDataTask: URLSessionDataTask?
    private var photosAreUpToDate = false
    private var complitionsToExecute = [((Result<PhotosInfoDictionary, Error>) -> ())]()

    func deletePhotoBy(fileName name: String) {
        photos[name] = nil
    }

    func getAllPhotos(completion: ((Result<PhotosInfoDictionary, Error>) -> ())? = nil){
        if downloadPhotosDataTask == nil {

            photosAreUpToDate = false

            if completion != nil {
                complitionsToExecute.append(completion!)
            }
            
            downloadPhotosDataTask = networkManager.getAllPhotos(complition: { [weak self] photosDictionary, error in
                self?.photos = photosDictionary ?? [:]
                self?.photosAreUpToDate = true
                if error != nil {
                    self?.complitionsToExecute.forEach{ $0(.failure(error!)) }
                } else if photosDictionary != nil {
                    self?.complitionsToExecute.forEach{ $0(.success(photosDictionary!)) }
                }
                self?.downloadPhotosDataTask = nil
            })
        } else if downloadPhotosDataTask != nil, photosAreUpToDate == false {
            if completion != nil {
                complitionsToExecute.append(completion!)
            }
        } else if downloadPhotosDataTask != nil, photosAreUpToDate == true {
            completion?(.success(photos))
        } 
    }
}


