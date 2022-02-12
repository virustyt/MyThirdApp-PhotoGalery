//
//  UIImageView+SetImageFromPhoto.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit

extension UIImageView {

    func setImageFromBGSoftDataStoreBy(photosName name: String?) {
        guard let photosName = name,
              let photosUrl = URL(string: "https://dev.bgsoft.biz/task/\(photosName).jpg")
        else {
            self.image = UIImage(named: "placeholder")
            return
        }
        let hash = photosName.hashValue
        tag = hash

        image = UIImage(named: "placeholder")
        ImageClient.shared.getImage(from: photosUrl, complition: {
            [weak self] image, error in

            guard self?.tag == hash
            else { return }

            if let recievedImage = image {
                self?.contentMode = .scaleAspectFill
                self?.image = recievedImage
            } else if let _ = error {
                self?.contentMode = .scaleAspectFit
                self?.image = UIImage(named: "imageNotFound2")
            }
        })
    }
}
