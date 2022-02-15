//
//  PhotoGaleryViewController.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit

fileprivate extension Consts {
    static let collectionViewMinLineSpacing: CGFloat = 0
    static let collectionViewMinInteritemSpacing: CGFloat = 0
    static let collectionViewItemSize: CGSize = UIScreen.main.bounds.size

    static var inactiveTimeBeforeScroll: Double = 5
    static var inactiveTimeBetweenScroll: Double = 5
}

class PhotoGaleryViewController: BaseViewController{

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Photo>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Photo>

    private enum Section: String, CaseIterable {
        case main
    }

    var viewModel: PhotoGaleryViewModelProtocol?
    var router: PhotoGaleryRouterProtocol?

    private lazy var photoGaleryContainerView = PhotoGaleryContainerView(collectionViewDelegate: self,
                                                                         collectionCiewDataSource: self)

    private var lastVisibleCellsIndexPath: IndexPath?
    private var collectionViewCellSize: CGSize {
        view.frame.size
    }

    private var timer: Timer?

    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpConstraints()
        refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        lastVisibleCellsIndexPath = targetIndexPath()
        photoGaleryContainerView.collectionView.collectionViewLayout.invalidateLayout()
        refreshData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpCollectionViewForCourusel()
    }

    override func viewDidLayoutSubviews() {
        if let indexPath = lastVisibleCellsIndexPath {
            photoGaleryContainerView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        timer?.invalidate()
        super.viewWillDisappear(animated)
    }

    // MARK: - private funcs
    @objc private func refreshData(){
        let photosCollectionView = photoGaleryContainerView.collectionView

        photoGaleryContainerView.activityIndicator.startAnimating()
        viewModel?.getSortedPhotos(complition: {
            [weak self] result in
            switch result {
            case .success(_):
                photosCollectionView.reloadData()
                self?.startNewTimer()
            case .failure(_):
                break
            }
            self?.photoGaleryContainerView.activityIndicator.stopAnimating()
        })
    }

    private func startNewTimer() {
        let timer = Timer(fire: .init(timeIntervalSinceNow: Consts.inactiveTimeBeforeScroll),
                          interval: Consts.inactiveTimeBetweenScroll,
                          repeats: true) {
            [weak self] timer in

            let indexPath = self?.lastVisibleCellsIndexPath ?? IndexPath(item: self?.viewModel?.bufferPhotosCount ?? 0, section: 0)
            let newIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            self?.lastVisibleCellsIndexPath = newIndexPath
            self?.photoGaleryContainerView.collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        }

        timer.tolerance = 0.1
        RunLoop.current.add(timer, forMode: .common)

        self.timer?.invalidate()
        self.timer = timer
    }

    private func setUpConstraints() {
        view.addSubview(photoGaleryContainerView)

        photoGaleryContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoGaleryContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            photoGaleryContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoGaleryContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoGaleryContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpCollectionViewForCourusel() {
        let photosCollectionView = photoGaleryContainerView.collectionView
        photosCollectionView.contentOffset.x = CGFloat((viewModel?.bufferPhotosCount ?? 0)) * collectionViewCellSize.width
    }

    private func makeCell(from photo: Photo, for collectionView: UICollectionView, withIndexPath indexPath: IndexPath ) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoGaleryCollectionViewCell.identifyer,
            for: indexPath) as? PhotoGaleryCollectionViewCell

        let photo = viewModel?.sortedPhotos?[indexPath.item]
        let authorUrl = photo?.photosInfo?.userURL
        let photosDescriptionUrl = photo?.photosInfo?.photoURL

        cell?.setUp(from: photo,
                    photoInsets: view.safeAreaInsets,
                    authorsLinkOnTapClouser: { [weak self] in self?.router?.showWebLinkVC(for: authorUrl,
                                                                                          withTitle: "photos author")},
                    photosLinkOnTapClouser: { [weak self] in self?.router?.showWebLinkVC(for: photosDescriptionUrl,
                                                                                         withTitle: "photos details")})
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoGaleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionViewCellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Consts.collectionViewMinLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Consts.collectionViewMinInteritemSpacing
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard velocity.x == .zero else {
            return
        }
        photoGaleryContainerView.collectionView.scrollToItem(at: targetIndexPath(), at: .centeredHorizontally, animated: true)
        startNewTimer()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        photoGaleryContainerView.collectionView.scrollToItem(at: targetIndexPath(), at: .centeredHorizontally, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        changeCellsBehaviour()
        returnToCenter()
    }

    private func targetIndexPath() -> IndexPath {
        let photosCollectionView = photoGaleryContainerView.collectionView

        let itemWidth = collectionViewCellSize.width
        let proportionalOffset = photosCollectionView.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(photosCollectionView.numberOfItems(inSection: 0) - 1, index))
        return IndexPath(item: safeIndex, section: 0)
    }

    private func makeContentOffset(for index: Int) -> CGPoint {
        CGPoint(x: collectionViewCellSize.width * CGFloat(index),
                y: 0)
    }

    private func changeCellsBehaviour() {
        let visibleRectsCenterXOffset = photoGaleryContainerView.collectionView.contentOffset.x
            + ( photoGaleryContainerView.collectionView.frame.size.width / 2 )

        for visibleCell in photoGaleryContainerView.collectionView.visibleCells {
            guard let cell = visibleCell as? PhotoGaleryCollectionViewCell
            else {return}

            let offsetX = visibleRectsCenterXOffset - cell.frame.midX
            let positiveOffsetX = abs(offsetX)

            if positiveOffsetX < photoGaleryContainerView.collectionView.bounds.width {
                let offsetPercentage = positiveOffsetX  / photoGaleryContainerView.collectionView.bounds.width
                cell.moveContent(by: offsetPercentage, direction: offsetX >= 0 ? .right : .left)
            }
        }
    }

    private func returnToCenter() {
        let photosCollectionView = photoGaleryContainerView.collectionView

        let carouselRightBorder = photosCollectionView.contentSize.width - (collectionViewCellSize.width * 3)
        let carouselLeftBorder = collectionViewCellSize.width * 3

        if photosCollectionView.contentOffset.x > carouselRightBorder {
            photosCollectionView.contentOffset.x = carouselLeftBorder
        }
        if photosCollectionView.contentOffset.x < carouselLeftBorder {
            photosCollectionView.contentOffset.x = carouselRightBorder
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoGaleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.sortedPhotos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoGaleryCollectionViewCell.identifyer,
            for: indexPath) as? PhotoGaleryCollectionViewCell
        else { return UICollectionViewCell() }

        let photo = viewModel?.sortedPhotos?[indexPath.item]
        let authorUrl = photo?.photosInfo?.userURL
        let photosDescriptionUrl = photo?.photosInfo?.photoURL

        cell.setUp(from: photo,
                    photoInsets: view.safeAreaInsets,
                    authorsLinkOnTapClouser: { [weak self] in self?.router?.showWebLinkVC(for: authorUrl,
                                                                                          withTitle: "photos author")},
                    photosLinkOnTapClouser: { [weak self] in self?.router?.showWebLinkVC(for: photosDescriptionUrl,
                                                                                         withTitle: "photos details")})
        return cell
    }
}

