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
    static var containerViewTopInset: CGFloat = 30

    static var containerStackViewLeadingInset: CGFloat = 30
    static var containerStackViewTrailingInset: CGFloat = 30
    static var containerStackViewBottomInset: CGFloat = 30

    static var linksStackSpacing: CGFloat = 50
    static var finalStackSpacing: CGFloat = 50

    static var labelsShadowRadius: CGFloat = 2
    static var labelsSadowOpacity: Float = 1
    static var labelsSadowOffset: CGSize = .init(width: 2.5, height: 2.5)
    static var cornerRadius: CGFloat = 20

    static var authorLabelFontSize: CGFloat = 25
    static var authorButtonFontSize: CGFloat = 15
    static var photoButtonFontSize: CGFloat = 15

    static var photoImageViewMovingSpeed: CGFloat = 5
    static var labelsMovingSpeed: CGFloat = 500
    static var minCellScale: CGFloat = 0.9
    static var minCelAlphaBlending: CGFloat = 0.7
}

class PhotoGaleryCollectionViewCell: UICollectionViewCell {

    enum Direction {
        case left, right, none
    }

    static let identifyer: String = String.init(describing: self)

    private var haveShadows = false
    private var lastSettedPhotoName: String?

    private var authorLinkTappedClouser: (() -> ())?
    private var photosLinkTappedClouser: (() -> ())?

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
        let linksStack = UIStackView(arrangedSubviews: [authorsInfoButton, photosInfoButton])
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
        label.font = UIFont(name: "Montserrat-MediumItalic", size: Consts.authorLabelFontSize)
        label.textColor = .white
        label.numberOfLines = 0
        setDropShadow(for: label.layer)
        return label
    }()

    private lazy var authorsInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-MediumItalic", size: Consts.authorButtonFontSize)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .clear
        setDropShadow(for: button.titleLabel!.layer)

        button.addTarget(self, action: #selector(PhotoGaleryCollectionViewCell.authorLinkTapped), for: .touchUpInside)

        return button
    }()

    private lazy var photosInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-MediumItalic", size: Consts.photoButtonFontSize)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .clear
        setDropShadow(for: button.titleLabel!.layer)

        button.addTarget(self, action: #selector(PhotoGaleryCollectionViewCell.photoLinkTapped), for: .touchUpInside)

        return button
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

    private lazy var containerStackviewLeadingConstraint = containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                                                                       constant: Consts.containerStackViewLeadingInset)
    private lazy var containerStackviewTraiingConstraint = containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                                                                        constant: -Consts.containerStackViewTrailingInset)
    private lazy var containerStackviewBottomConstraint =  containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                                                                       constant: -Consts.containerStackViewBottomInset)

    private lazy var photoImageViewLeadingConstraint =  photoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
    private lazy var photoImageViewTrailingConstraint =  photoImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

    // MARK: - inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - public funcs
    func setUp(from photo: Photo?,
               photoInsets safeAreaInsets: UIEdgeInsets?,
               authorsLinkOnTapClouser: @escaping () -> (),
               photosLinkOnTapClouser: @escaping () -> ()) {
        if lastSettedPhotoName != photo?.name || lastSettedPhotoName == nil {
            lastSettedPhotoName = photo?.name

            photoImageView.image = nil
            authorNameLabel.text = nil
            photosInfoButton.setTitle(nil, for: .normal)
            authorsInfoButton.setTitle(nil, for: .normal)

            photoImageView.setImageFromBGSoftDataStoreBy(photosName: photo?.name)

            setContentViewConstraintConstants(from: safeAreaInsets)

            authorLinkTappedClouser = authorsLinkOnTapClouser
            photosLinkTappedClouser = photosLinkOnTapClouser

            guard let authorName = photo?.photosInfo?.userName
            else {
                authorNameLabel.text = "author is a mystery"
                return
            }

            authorNameLabel.text = authorName
            authorsInfoButton.setTitle("about author", for: .normal)
            photosInfoButton.setTitle("about photo", for: .normal)
        }
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
            photoImageViewLeadingConstraint,
            photoImageViewTrailingConstraint,
            photoImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            containerStackviewLeadingConstraint,
            containerStackviewTraiingConstraint,
            containerStackviewBottomConstraint
        ])
    }

    private func setDropShadow(for layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = Consts.labelsShadowRadius
        layer.shadowOpacity = Consts.labelsSadowOpacity
        layer.shadowOffset = Consts.labelsSadowOffset
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.masksToBounds = false
    }

    private func setContentViewConstraintConstants(from insets: UIEdgeInsets?) {
        if let recievedInsets = insets {
            containerViewTopConstraint.constant = recievedInsets.top > 0 ? recievedInsets.top : Consts.containerViewTopInset
            if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
                containerViewTrailingConstraint.constant = recievedInsets.right > 0 ? -recievedInsets.right : -Consts.containerViewTrailingInset
                containerViewLeadingConstraint.constant = recievedInsets.left > 0 ? recievedInsets.left : Consts.containerViewLeadingInset
            } else {
                containerViewTrailingConstraint.constant = recievedInsets.right > 0 ? recievedInsets.right : Consts.containerViewTrailingInset
                containerViewLeadingConstraint.constant = recievedInsets.left > 0 ? -recievedInsets.left : -Consts.containerViewLeadingInset
            }
            layoutIfNeeded()
        }
    }

    func moveContent(by offsetPercentage: CGFloat, direction: Direction) {
        let rangeMin: CGFloat = 0
        let rangeMax: CGFloat = 1
        let acceptableRange = rangeMin...rangeMax
        let minCellScale: CGFloat = acceptableRange.contains(Consts.minCellScale) ? Consts.minCellScale : 1
        let minAlphaBlending: CGFloat = acceptableRange.contains(Consts.minCelAlphaBlending) ? Consts.minCelAlphaBlending : 1

        transform = .identity

        var scaleX = 1 - offsetPercentage * (1 - minCellScale)

        if scaleX < minCellScale {
            scaleX = minCellScale
        }

        transform = transform.scaledBy(x: scaleX, y: scaleX)
        let cellAlpha = 1 - offsetPercentage * (1 - minAlphaBlending)
        alpha = cellAlpha

        let containerStackViewCurrentStepPrecentage = 1 - scaleX
        let currentLabelsStepSize = Consts.labelsMovingSpeed * containerStackViewCurrentStepPrecentage
        let currentLabelStep = direction == .left ? -currentLabelsStepSize : currentLabelsStepSize

        containerStackviewLeadingConstraint.constant = Consts.containerStackViewLeadingInset + currentLabelStep
        containerStackviewTraiingConstraint.constant = -(Consts.containerStackViewTrailingInset - currentLabelStep)

        let currentPhotoStep = direction == .left ? -offsetPercentage / 5 : offsetPercentage / 5
        photoImageView.layer.contentsRect = CGRect(x: -currentPhotoStep,
                                                   y: 0,
                                                   width: 1 - currentPhotoStep,
                                                   height: 1)
        containerView.layoutIfNeeded()
    }

    @objc private func authorLinkTapped() {
        authorLinkTappedClouser?()
    }

    @objc private func photoLinkTapped() {
       photosLinkTappedClouser?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !haveShadows, containerView.bounds != .zero, photoImageView.bounds != .zero{

            photoImageView.layer.cornerRadius = Consts.cornerRadius
            containerView.layer.cornerRadius = Consts.cornerRadius
            setDropShadow(for: containerView.layer)

            haveShadows = true
        }
    }
}
