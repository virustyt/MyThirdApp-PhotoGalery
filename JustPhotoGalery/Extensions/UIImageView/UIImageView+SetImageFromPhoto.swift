//
//  UIImageView+SetImageFromPhoto.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit
import func AVFoundation.AVMakeRect

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

        ImageClient.shared.getResizedImage(for: self, from: photosUrl) {
            [weak self] resizedImage, error in

            guard let self = self,
                  self.tag == hash
            else { return }

            if let recievedImage = resizedImage {
                self.contentMode = .scaleAspectFill
                UIView.transition(with: self,
                                  duration: 1.0,
                                  options: [.curveEaseOut, .transitionCrossDissolve],
                                  animations: { self.image = recievedImage })
            } else if let _ = error {
                self.contentMode = .scaleAspectFit
                UIView.transition(with: self,
                                  duration: 1.0,
                                  options: [.curveEaseOut, .transitionCrossDissolve],
                                  animations: { self.image = UIImage(named: "imageNotFound2") })
            }
        }
    }
}
