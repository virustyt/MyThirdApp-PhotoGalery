//
//  ImageNetClient.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit

protocol ImageNetClientProtocol{
    func downloadImages(imageURL: URL, complition: @escaping (UIImage?, Error?) -> ()) -> URLSessionDataTask?
    func getResizedImage(for imageView: UIImageView, from imageURL: URL, withPlaceholder placeholder: UIImage, complition: @escaping (UIImage?, Error?)-> ())
}

class ImageClient {
    var cashedDataTasks: [URL: URLSessionDataTask]

    var urlSession: URLSession
    var responseQueue: DispatchQueue?
    private var cache: URLCache? {
        urlSession.configuration.urlCache
    }

    private var resizedImages = [URL: UIImage]()

    private static var sharedInstanceCache: URLCache = {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("DownloadCache")
        let cache = URLCache(memoryCapacity: 200_000_000, diskCapacity: 600_000_000, directory: diskCacheURL)
        return cache
    }()

    static let shared: ImageClient = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = sharedInstanceCache
        let session = URLSession(configuration: configuration)
        let imageClient = ImageClient(urlSession: session, responseQueue: .main)
        return imageClient
    }()

    // MARK: - inits
    init(urlSession: URLSession, responseQueue: DispatchQueue?){
        self.urlSession = urlSession
        self.responseQueue = responseQueue
        self.cashedDataTasks = [:]
    }
}

extension ImageClient: ImageNetClientProtocol{

    func downloadImages(imageURL: URL, complition: @escaping (UIImage?, Error?) -> ()) -> URLSessionDataTask? {
        let imageRequest = URLRequest(url: imageURL)

        if let cashedResponse = cache?.cachedResponse(for: imageRequest) {
            dispatchResults(model: UIImage(data: cashedResponse.data), complitionHandler: complition)
            return nil
        }

        let dataTask = self.urlSession.dataTask(with: imageURL) { [weak self] data, response, error in
            guard let self = self else { return }
            if let recievedResponse = response,
               let recievedData = data,
               let recievedImage = UIImage(data: recievedData) {
                self.cache?.storeCachedResponse(CachedURLResponse(response: recievedResponse, data: recievedData), for: imageRequest)
                complition(recievedImage,nil)
            }
            else{
                complition(nil,error)
            }
        }
        dataTask.resume()
        return dataTask
    }

    func getResizedImage(for imageView: UIImageView, from imageURL: URL, withPlaceholder placeholder: UIImage, complition: @escaping (UIImage?, Error?)-> ()) {
        cashedDataTasks[imageURL]?.cancel()

        if let cashedImage = resizedImages[imageURL] {
            dispatchResults(model: cashedImage, complitionHandler: complition)
            return
        }

        imageView.image = placeholder
        cashedDataTasks[imageURL] = downloadImages(imageURL: imageURL,
                                                   complition: { [weak self] image, error in
                                                    guard let self = self else {return}

                                                    self.cashedDataTasks[imageURL] = nil

                                                    if let recievedImage = image {
                                                        let resizedImage = self.resize(image: recievedImage, for: imageView.frame.size)
                                                        self.resizedImages[imageURL] = resizedImage
                                                        self.dispatchResults(model: resizedImage,complitionHandler: complition)
//                                                        self.dispatchResults(model: recievedImage,complitionHandler: complition)
                                                    } else {
                                                        self.dispatchResults(error: error, complitionHandler: complition)
                                                    }
                                                   })
    }

    func dispatchResults<Type>(model: Type? = nil, error: Error? = nil, complitionHandler: @escaping (Type?,Error?) -> ()) {
        guard let responseQueue = responseQueue
        else {
            complitionHandler(model,error)
            return
        }
        responseQueue.async { complitionHandler(model,error) }
    }

//    private func makeRectWithRightRatio(from imageSize: CGSize, for imageViewSize: CGSize) -> CGRect {
//        // calculate new, bigger, imageSize for image rotation purposes
//        let newImageSize = imageSize.width > imageSize.height ?
//            CGSize(width: imageSize.width * (imageSize.width / imageSize.height),
//                   height: imageSize.width) :
//            CGSize(width: imageSize.height,
//                   height: imageSize.height * (imageSize.height / imageSize.width))
//
//        let viewToImageWidthRatio = newImageSize.width / imageViewSize.width
//        let viewToImageHeighthRatio = newImageSize.height / imageViewSize.height
//
//        let minRatio = min(viewToImageWidthRatio, viewToImageHeighthRatio)
//
//        let rectWidth = newImageSize.width / minRatio
//        let rectHeight = newImageSize.height / minRatio
//
//        let pointThatShowsMiddleOfThePicture = viewToImageWidthRatio > viewToImageHeighthRatio ?
//            CGPoint(x: -((rectWidth - imageViewSize.width) / 2), y: 0) :
//            CGPoint(x: 0, y: -((rectHeight - imageViewSize.height) / 2))
//
//        let rect = CGRect(origin: pointThatShowsMiddleOfThePicture,
//                          size: CGSize(width: rectWidth, height: rectHeight))
//        return rect
//    }

    private func makeRectWithRightRatio(from imageSize: CGSize, for imageViewSize: CGSize) -> CGRect {
        // calculate new, bigger, imageSize for image rotation purposes
        let newImageViewSize = imageViewSize.width > imageViewSize.height ?
            CGSize(width: imageViewSize.width * (imageViewSize.width / imageViewSize.height),
                   height: imageViewSize.width) :
            CGSize(width: imageViewSize.height,
                   height: imageViewSize.height * (imageViewSize.height / imageViewSize.width))

        let viewToImageWidthRatio = imageSize.width / newImageViewSize.width
        let viewToImageHeighthRatio = imageSize.height / newImageViewSize.height

        let minRatio = min(viewToImageWidthRatio, viewToImageHeighthRatio)

        let rectWidth = imageSize.width / minRatio
        let rectHeight = imageSize.height / minRatio

        let pointThatShowsMiddleOfThePicture = viewToImageWidthRatio > viewToImageHeighthRatio ?
            CGPoint(x: -((rectWidth - newImageViewSize.width) / 2), y: 0) :
            CGPoint(x: 0, y: -((rectHeight - newImageViewSize.height) / 2))

        let rect = CGRect(origin: pointThatShowsMiddleOfThePicture,
                          size: CGSize(width: rectWidth, height: rectHeight))
        return rect
    }


//    private func resize(image: UIImage, for imageViewSize: CGSize) -> UIImage {
//        let rect = self.makeRectWithRightRatio(from: image.size, for: imageViewSize)
//        let renderer = UIGraphicsImageRenderer(size: imageViewSize)
//        let resizedImage = renderer.image { (context) in
//            image.draw(in: rect)
//        }
//        return resizedImage
//    }

    private func resize(image: UIImage, for imageViewSize: CGSize) -> UIImage {
        let rect = self.makeRectWithRightRatio(from: image.size, for: imageViewSize)

        let newImageViewSize = imageViewSize.width > imageViewSize.height ?
            CGSize(width: imageViewSize.width * (imageViewSize.width / imageViewSize.height),
                   height: imageViewSize.width) :
            CGSize(width: imageViewSize.height,
                   height: imageViewSize.height * (imageViewSize.height / imageViewSize.width))

        let renderer = UIGraphicsImageRenderer(size: newImageViewSize)
//        let renderer = UIGraphicsImageRenderer(size: imageViewSize)
        let resizedImage = renderer.image { (context) in
            image.draw(in: rect)
        }
        return resizedImage
    }
}
