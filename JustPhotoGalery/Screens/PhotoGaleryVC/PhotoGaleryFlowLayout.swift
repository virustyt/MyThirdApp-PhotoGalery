//
//  PhotoGaleryFlowLayout.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 13.02.2022.
//

import UIKit

class PhotoGaleryFlowLayout: UICollectionViewFlowLayout {

    var scaleRatio: CGFloat = 0.8

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
         guard let attributes = super.layoutAttributesForElements(in: rect)
         else { return nil }

                let centerX = (collectionView?.contentOffset.x ?? 0) + ( (collectionView?.frame.size.width ?? 0) / 2 )
                for attribute in attributes {

                    var offsetX = centerX - attribute.frame.midX

                    if offsetX < 0 {
                        offsetX *= -1
                    }

                    let f: CGFloat = (collectionView?.bounds.width ?? 1)
                    if offsetX < f {
                        let offsetPercentage = offsetX  / ( (collectionView?.bounds.width ?? 1) )
                        var scaleX = 1 - offsetPercentage * (1 - scaleRatio)

                        if scaleX < scaleRatio {
                            scaleX = scaleRatio
                        }

                        attribute.frame.size = CGSize(width: attribute.frame.size.width  * scaleX,
                                                      height: attribute.frame.size.height * scaleX)

                        attribute.frame.origin.y = attribute.frame.origin.y + (( attribute.frame.size.height / scaleX  - attribute.frame.height) ) / 2  
                    }
                }
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attribute = super.layoutAttributesForItem(at: indexPath)
        else { return nil }

        let centerX = (collectionView?.contentOffset.x ?? 0) + ( (collectionView?.frame.size.width ?? 0) / 2 )

        var offsetX = centerX - attribute.frame.midX
        if offsetX < 0 {
            offsetX *= -1
        }

        let f: CGFloat = (collectionView?.bounds.width ?? 1)

        if offsetX < f {

            let offsetPercentage = offsetX  / ( (collectionView?.bounds.width ?? 1) )
            var scaleX = 1 - offsetPercentage * (1 - scaleRatio)

            if scaleX < scaleRatio {
                scaleX = scaleRatio
            }

            attribute.frame.size = CGSize(width: attribute.frame.size.width  * scaleX,
                                          height: attribute.frame.size.height * scaleX)

            attribute.frame.origin.y = attribute.frame.origin.y + (( attribute.frame.size.height / scaleX  - attribute.frame.height) ) / 2
        }
        return attribute
    }
}
