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

                                                let cell = collectionView.dequeueReusableCell(
                                                    withReuseIdentifier: PhotoGaleryCollectionViewCell.identifyer,
                                                    for: indexPath) as? PhotoGaleryCollectionViewCell

                                                self?.viewModel?.getSortedPhotos(complition: {
                                                    [weak self] result in
                                                    switch result {
                                                    case .success(let photos):
                                                        let photo = photos[indexPath.item]
                                                        cell?.setUp(from: photo, andInsets: self?.view.safeAreaInsets)
                                                    case .failure(_):
                                                        // do some stuff here
                                                    return
                                                    }
                                                })
                                                return cell
                                             })
        return difffableDataSource
    }()

    private var currentCollectionViewItem: Int?

    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpConstraints()
        refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        photoGaleryContainerView.collectionView.collectionViewLayout.invalidateLayout()
        photoGaleryContainerView.collectionView.setContentOffset(makeContentOffset(for: currentCollectionViewItem ?? 0), animated: true)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        currentCollectionViewItem = indexOfMajorCell()
        refreshData()
    }

    // MARK: - private funcs
    @objc private func refreshData(){
        photoGaleryContainerView.collectionView.refreshControl?.beginRefreshing()
        viewModel?.getSortedPhotos(complition: {
            [weak self] result in
            switch result {
            case .success(let photos):
                self?.applySnapshot(for: photos)
                self?.photoGaleryContainerView.collectionView.refreshControl?.endRefreshing()
            case .failure(_):
                // do some stuff here
                self?.photoGaleryContainerView.collectionView.refreshControl?.endRefreshing()
            }
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
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoGaleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("collectionView-",collectionView.frame.size,"screen-", UIScreen.main.bounds.size,"frame-",view.frame.size)
        return view.safeAreaLayoutGuide.layoutFrame.size

//        return UIScreen.main.bounds.size
//        return CGSize(width: UIScreen.main.bounds.size.width - 1,
//                      height: UIScreen.main.bounds.size.height - 1)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Consts.collectionViewMinLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Consts.collectionViewMinInteritemSpacing
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = makeContentOffset(for: indexOfMajorCell())
    }

    private func indexOfMajorCell() -> Int {
        let layout = photoGaleryContainerView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let itemWidth = view.frame.size.width
        let proportionalOffset = (layout?.collectionView!.contentOffset.x ?? 0) / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(dataSource.snapshot().numberOfItems - 1, index))
        return safeIndex
    }

    private func makeContentOffset(for index: Int) -> CGPoint {
        CGPoint(x: (photoGaleryContainerView.collectionView.visibleCells.first?.bounds.width ?? 0) * CGFloat(index),
                y: 0)
    }
}

