//
//  PhotoGaleryViewModel.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

protocol PhotoGaleryViewModelProtocol {
    var errorPhoto: Photo { get }
    var sortedPhotos: [Photo]? { get }
    func getSortedPhotos(complition: @escaping (Result<[Photo], Error>) -> ())
}

class PhotoGaleryViewModel: PhotoGaleryViewModelProtocol {

    var manager: PhotosInfoManagerProtocol?

    private(set) var sortedPhotos: [Photo]?

    let errorPhoto = Photo(name: "error",
                           photosInfo: PhotosInfo(photoURL: nil,
                                                  userURL: nil,
                                                  userName: "hidden in the fog",
                                                  colors: nil))

    func getSortedPhotos(complition: @escaping (Result<[Photo], Error>) -> ()) {
        if sortedPhotos == nil {
            manager?
                .getAllPhotos(completion: {
                [weak self] result in
                switch result {
                case .success(let photosDictionary):
                    self?.sortedPhotos = photosDictionary
                        .map{ Photo(name: $0.key, photosInfo: $0.value) }
                        .sorted(by: {
                            ($0.photosInfo?.userName ?? "").getLowercasedWords()  < ($1.photosInfo?.userName ?? "").getLowercasedWords()
                        })
                    complition(.success(self?.sortedPhotos ?? []))
                case .failure(let error):
                    complition(.failure(error))
                }
            })
        } else {
            complition(.success(sortedPhotos ?? []))
        }
    }
}
