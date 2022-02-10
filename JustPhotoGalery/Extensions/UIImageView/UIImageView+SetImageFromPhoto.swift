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
        ImageClient.shared.setImage(on: self, from: photosUrl, with: UIImage(named: "placeholder"))
    }
}
