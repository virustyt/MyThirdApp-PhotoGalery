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
    private var photoGaleryLayoutAttributes = [IndexPath: PhotoGaleryCellLayoutAttributes]()

    override func prepare() {
        super.prepare()
        if photoGaleryLayoutAttributes.count == 0 {
            
        }
        print("prepare")
    }

//    private var cache = [IndexPath: UICollectionViewLayoutAttributes]()

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var attributes: [UICollectionViewLayoutAttributes] = []

        guard let originAttributes = super.layoutAttributesForElements(in: rect)
        else { return nil }

        for object in  originAttributes {
            attributes.append(object.copy() as! UICollectionViewLayoutAttributes)
        }

//        guard let attributes = super.layoutAttributesForElements(in: rect)
//        else { return nil }
//
//        var result = [PhotoGaleryCellLayoutAttributes]()

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

//                if let customAttribute = photoGaleryLayoutAttributes[attribute.indexPath] {
//                    let g = PhotoGaleryCellLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
//                    g.distanceToCollectionViewCenter = 0
//
//                    customAttribute.transform = attribute.transform.scaledBy(x: scaleX, y: scaleX)
//
//                    let cellAlpha = 1 - offsetPercentage * (1 - minAlphaBlending)
//                    customAttribute.alpha = cellAlpha
//
//                    customAttribute.distanceToCollectionViewCenter = 0
//
//                    result.append(customAttribute)
//                }

                attribute.transform = attribute.transform.scaledBy(x: scaleX, y: scaleX)

                let cellAlpha = 1 - offsetPercentage * (1 - minAlphaBlending)
                attribute.alpha = cellAlpha
            }
        }
//        return result
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
}
