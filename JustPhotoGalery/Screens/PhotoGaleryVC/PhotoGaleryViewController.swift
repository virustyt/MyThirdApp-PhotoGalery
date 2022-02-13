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
}

class PhotoGaleryViewController: BaseViewController{

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Photo>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Photo>

    private enum Section: String, CaseIterable {
        case main
    }

    var viewModel: PhotoGaleryViewModelProtocol?
    var router: PhotoGaleryRouterProtocol?

    private lazy var photoGaleryContainerView = PhotoGaleryContainerView(collectionViewDelegate: self)

    private lazy var dataSource: DataSource = {
        let difffableDataSource = DataSource(collectionView: photoGaleryContainerView.collectionView,
                                             cellProvider: { [weak self]
                                                (collectionView, indexPath, photo) -> UICollectionViewCell? in

                                                self?.makeCell(from: photo, for: collectionView, withIndexPath: indexPath)
                                             })
        return difffableDataSource
    }()

    private var lastVisibleCellsIndexPath: IndexPath?

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

    override func viewDidLayoutSubviews() {
        if let indexPath = lastVisibleCellsIndexPath {
            photoGaleryContainerView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }

    // MARK: - private funcs
    @objc private func refreshData(){
        photoGaleryContainerView.collectionView.refreshControl?.beginRefreshing()
        viewModel?.getSortedPhotos(complition: {
            [weak self] result in
            switch result {
            case .success(let photos):
                self?.applySnapshot(for: photos)
            case .failure(_):
                break
            }
            self?.photoGaleryContainerView.collectionView.refreshControl?.endRefreshing()
        })
    }

    private func setUpRefreshControl(){
        let control = UIRefreshControl()
        photoGaleryContainerView.collectionView.refreshControl = control

        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        control.attributedTitle = NSAttributedString(string: "Loading...")
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

    private func applySnapshot(for newPhotos: [Photo], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(newPhotos)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
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
        Consts.collectionViewItemSize
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
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        photoGaleryContainerView.collectionView.scrollToItem(at: targetIndexPath(), at: .centeredHorizontally, animated: true)
    }

    private func targetIndexPath() -> IndexPath {
        let layout = photoGaleryContainerView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let itemWidth = Consts.collectionViewItemSize.width
        let proportionalOffset = (layout?.collectionView!.contentOffset.x ?? 0) / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(dataSource.snapshot().numberOfItems - 1, index))
        return IndexPath(item: safeIndex, section: 0)
    }

    private func makeContentOffset(for index: Int) -> CGPoint {
        CGPoint(x: Consts.collectionViewItemSize.width * CGFloat(index),
                y: 0)
    }
}

