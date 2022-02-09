//
//  UIImageView+SetImageFromPhoto.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit

class UIImageView_SetImageFromPhoto: UIImageView {

    func setImage(from photo: Photo?) {
        guard let photosUrlAdress = photo?.photoURL,
              let photosUrl = URL(string: photosUrlAdress)
        else {
            self.image = UIImage(named: "placeholder")
            return
        }
        ImageClient.shared.setImage(on: self, from: photosUrl, with: UIImage(named: "placeholder"))
    }
}
