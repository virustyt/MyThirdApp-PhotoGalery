//
//  PhotoGaleryFlowLayout.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 13.02.2022.
//

import UIKit

class PhotoGaleryFlowLayout: UICollectionViewFlowLayout {

    var minCellScale: CGFloat = 0.9
    var minAlphaBlending: CGFloat = 0.7
    private(set) var cellsOffsetPercentages: [IndexPath: CGFloat]?

    private var cache = [IndexPath: UICollectionViewLayoutAttributes]()

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var attributes: [UICollectionViewLayoutAttributes] = []

        for object in  super.layoutAttributesForElements(in: rect)! {
            attributes.append(object.copy() as! UICollectionViewLayoutAttributes)

        }

        let centerX = (collectionView?.contentOffset.x ?? 0) + ( (collectionView?.frame.size.width ?? 0) / 2 )
        for attribute in attributes {

            var offsetX = centerX - attribute.frame.midX

            if offsetX < 0 {
                offsetX *= -1
            }

            let f: CGFloat = (collectionView?.bounds.width ?? 1)
            if offsetX < f {
                let offsetPercentage = offsetX  / ( (collectionView?.bounds.width ?? 1) )
                var scaleX = 1 - offsetPercentage * (1 - minCellScale)

                if scaleX < minCellScale {
                    scaleX = minCellScale
                }

                attribute.transform = attribute.transform.scaledBy(x: scaleX, y: scaleX)

                let cellAlpha = 1 - offsetPercentage * (1 - minAlphaBlending)
                attribute.alpha = cellAlpha

                cellsOffsetPercentages?[attribute.indexPath] = offsetPercentage
            }
        }
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
}
