//
//  PhotoGaleryViewModel.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

protocol PhotoGaleryViewModelProtocol {
    var errorPhoto: Photo { get }
    var sortedPhotos: [Photo] { get }
    var bufferPhotosCount: Int { get }
    func getSortedPhotos(complition: @escaping (Result<[Photo], Error>) -> ())
}

class PhotoGaleryViewModel: PhotoGaleryViewModelProtocol {

    var manager: PhotosInfoManagerProtocol?

    private(set) var sortedPhotos: [Photo] = []
    private(set) var bufferPhotosCount = 3

    let errorPhoto = Photo(name: "error",
                           photosInfo: PhotosInfo(photoURL: nil,
                                                  userURL: nil,
                                                  userName: "hidden in the fog",
                                                  colors: nil))

    func getSortedPhotos(complition: @escaping (Result<[Photo], Error>) -> ()) {
        if sortedPhotos.count == 0 {
            manager?
                .getAllPhotos(completion: {
                [weak self] result in
                switch result {
                case .success(let photosDictionary):
                    guard let self = self
                    else { return }

                    self.sortedPhotos = photosDictionary
                        .map{ Photo(name: $0.key, photosInfo: $0.value) }
                        .sorted(by: {
                            ($0.photosInfo?.userName ?? "").getLowercasedWords()  < ($1.photosInfo?.userName ?? "").getLowercasedWords()
                        })
                    self.duplicatePhotosFromEndAndStartPositions(by: self.bufferPhotosCount)
                    complition(.success(self.sortedPhotos) )
                case .failure(let error):
                    complition(.failure(error))
                }
            })
        } else {
            complition(.success(sortedPhotos))
        }
    }

    private func duplicatePhotosFromEndAndStartPositions(by duplicatesCount: Int) {
        let appropriateDuplsCount = duplicatesCount > sortedPhotos.count ? sortedPhotos.count : duplicatesCount

        var photosFromEnd = [Photo]()
        for index in 0..<appropriateDuplsCount {
            let repeatedPhoto = sortedPhotos[sortedPhotos.count - index - 1]
            photosFromEnd.insert(repeatedPhoto, at: 0)
        }

        var photosFromStart = [Photo]()
        for index in 0..<appropriateDuplsCount {
            let repitedPhoto = sortedPhotos[index]
            photosFromStart.append(repitedPhoto)
        }

        sortedPhotos.insert(contentsOf:photosFromEnd, at: 0)
        sortedPhotos.append(contentsOf: photosFromStart)
    }
}
