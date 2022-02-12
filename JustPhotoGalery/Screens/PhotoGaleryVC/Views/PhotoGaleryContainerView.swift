//
//  PhotoGaleryContainerView.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit

class PhotoGaleryContainerView: UIView {

    private var layout: UICollectionViewFlowLayout?

    // MARK: - inits
    init(collectionViewDelegate: UICollectionViewDelegate? = nil, collectionCiewDataSource: UICollectionViewDataSource? = nil) {
        super.init(frame: .zero)
        setUpConstraints()
        collectionView.delegate = collectionViewDelegate
        collectionView.dataSource = collectionCiewDataSource
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var collectionView: UICollectionView = {
        layout = UICollectionViewFlowLayout()
        layout?.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout!)
        collectionView.register(PhotoGaleryCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoGaleryCollectionViewCell.identifyer)

        collectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)

        return collectionView
    }()

    private func setUpConstraints() {
        addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}


