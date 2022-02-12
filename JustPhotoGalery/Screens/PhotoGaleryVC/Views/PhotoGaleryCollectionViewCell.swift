//
//  PhotoGaleryCollectionViewCell.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit

fileprivate extension Consts {
    static var containerViewLeadingInset: CGFloat = 30
    static var containerViewTrailingInset: CGFloat = 30
    static var containerViewBottomInset: CGFloat = 30
    static var containerViewTopInset: CGFloat = 0

    static var containerStackViewLeadingInset: CGFloat = 30
    static var containerStackViewTrailingInset: CGFloat = 30
    static var containerStackViewBottomInset: CGFloat = 20

    static var linksStackSpacing: CGFloat = 50
    static var finalStackSpacing: CGFloat = 50

    static var labelsShadowRadius: CGFloat = 3
    static var labelsSadowOpacity: Float = 1
    static var labelsSadowOffset: CGSize = .init(width: 4, height: 4)
}

class PhotoGaleryCollectionViewCell: UICollectionViewCell {

    static let identifyer: String = String.init(describing: self)

    private var authorsUrlAdress: String?
    private var photosInfoUrlAdress: String?

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private var containerView = UIView()

    var imageView: UIImageView {
        photoImageView
    }

    private lazy var containerStackView: UIStackView = {
        let linksStack = UIStackView(arrangedSubviews: [authorInfoLinkLabel, photoInfoLinkLabel])
        linksStack.axis = .horizontal
        linksStack.distribution = .equalSpacing
        linksStack.spacing = Consts.linksStackSpacing
        linksStack.alignment = .center

        let finalStack = UIStackView(arrangedSubviews: [authorNameLabel, linksStack])
        finalStack.axis = .vertical
        finalStack.distribution = .equalSpacing
        finalStack.spacing = Consts.finalStackSpacing
        finalStack.alignment = .center
        return finalStack
    }()

    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-MediumItalic", size: 25)
        label.textColor = .white
        label.numberOfLines = 0
        setUpShadows(for: label.layer)
        return label
    }()

    private lazy var authorInfoLinkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-MediumItalic", size: 15)
        label.textColor = .white
        setUpShadows(for: label.layer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(authorLinkTapped))
        label.addGestureRecognizer(tapGestureRecognizer)

        return label
    }()

    private lazy var photoInfoLinkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-MediumItalic", size: 15)
        label.textColor = .white
        setUpShadows(for: label.layer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoLinkTapped))
        label.addGestureRecognizer(tapGestureRecognizer)

        return label
    }()

    // MARK: - constraints
    private lazy var containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                                                     constant: Consts.containerViewTopInset)
    private lazy var containerViewTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                                                               constant: -Consts.containerViewTrailingInset)
    private lazy var containerViewLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                                                             constant: Consts.containerViewLeadingInset)
    private lazy var containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                                                           constant: -Consts.containerViewBottomInset)

    // MARK: - inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
        backgroundColor = .gray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - public funcs
    func setUp(from photo: Photo?, andInsets safeAreaInsets: UIEdgeInsets?) {
        setContentViewConstraintConstants(from: safeAreaInsets)

        authorsUrlAdress = photo?.photosInfo?.userURL
        photosInfoUrlAdress = photo?.photosInfo?.photoURL
        photoImageView.setImageFromBGSoftDataStoreBy(photosName: photo?.name)

        guard let authorName = photo?.photosInfo?.userName
        else {
            authorNameLabel.text = "author is a mystery"
            return
        }

        authorNameLabel.text = authorName
        photoInfoLinkLabel.text = "about photo"
        authorInfoLinkLabel.text = "about author"
    }

    // MARK: - private funcs
    private func setUpConstraints() {
        contentView.addSubview(containerView)
        containerView.addSubview(photoImageView)
        containerView.addSubview(containerStackView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerViewTopConstraint,
            containerViewTrailingConstraint,
            containerViewLeadingConstraint,
            containerViewBottomConstraint,

            photoImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                        constant: Consts.containerStackViewLeadingInset),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                         constant: -Consts.containerStackViewTrailingInset),
            containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                       constant: -Consts.containerStackViewBottomInset)
        ])
    }

    private func setUpShadows(for layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = Consts.labelsShadowRadius
        layer.shadowOpacity = Consts.labelsSadowOpacity
        layer.shadowOffset = Consts.labelsSadowOffset
        layer.masksToBounds = false
    }

    func setContentViewConstraintConstants(from insets: UIEdgeInsets?) {
        if let recievedInsets = insets {
//            containerViewTopConstraint.constant = recievedInsets.top > 0 ? recievedInsets.top : 20
            if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                containerViewTrailingConstraint.constant = recievedInsets.right > 0 ? -recievedInsets.right : -20
                containerViewLeadingConstraint.constant = recievedInsets.left > 0 ? recievedInsets.left : 20
            } else {
                containerViewTrailingConstraint.constant = recievedInsets.right > 0 ? recievedInsets.right : 20
                containerViewLeadingConstraint.constant = recievedInsets.left > 0 ? -recievedInsets.left : -20
            }
            layoutIfNeeded()
        }
    }

    @objc private func authorLinkTapped() {
        
    }

    @objc private func photoLinkTapped() {
       
    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        print(containerViewTopConstraint.constant)
//    }
}
