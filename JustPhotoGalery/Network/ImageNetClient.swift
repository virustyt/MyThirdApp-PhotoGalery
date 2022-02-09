//
//  ImageNetClient.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import UIKit

protocol ImageNetClientProtocol{
    func downloadImages(imageURL: URL ,
                        complition: @escaping (UIImage?, Error?) -> ()) -> URLSessionDataTask?
    func setImage(on imageView: UIImageView,
                  from imageURL: URL,
                  with placeholder: UIImage?,
                  complition: ((UIImage?, Error?)-> ())?)
}

class ImageClient {
    var cashedImages: [URL: UIImage]
    var cashedDataTasks: [URL: URLSessionDataTask]

    var urlSession: URLSession
    var responseQueue: DispatchQueue?

    static let shared = ImageClient(urlSession: URLSession.shared, responseQueue: .main)

    // MARK: - inits
    init(urlSession: URLSession, responseQueue: DispatchQueue?){
        self.urlSession = urlSession
        self.responseQueue = responseQueue

        self.cashedImages = [:]
        self.cashedDataTasks = [:]
    }
}

extension ImageClient: ImageNetClientProtocol{
    func downloadImages(imageURL: URL, complition: @escaping (UIImage?, Error?) -> ()) -> URLSessionDataTask? {
        if let cashedImage = self.cashedImages[imageURL] {
            dispatchResults(model: cashedImage, complitionHandler: complition)
            return nil
        }
        let dataTask = self.urlSession.dataTask(with: imageURL) { [weak self] data, response, error in
            guard let self = self else { return }
            if let recievedData = data,
               let recievedImage = UIImage(data: recievedData) {
                self.cashedImages[imageURL] = recievedImage
                self.dispatchResults(model: recievedImage,complitionHandler: complition)
            }
            else{
                self.dispatchResults(error: error, complitionHandler: complition)
            }
        }
        dataTask.resume()
        return dataTask
    }

    func setImage(on imageView: UIImageView, from imageURL: URL, with placeholder: UIImage?, complition: ((UIImage?, Error?)-> ())? = nil) {
        cashedDataTasks[imageURL]?.cancel()
        imageView.image = placeholder
        cashedDataTasks[imageURL] = downloadImages(imageURL: imageURL,
                                                    complition: {[weak self] image, error in
                                                        guard let self = self else {return}
                                                        self.cashedDataTasks[imageURL] = nil
                                                        if let notNilImage = image {imageView.image = notNilImage}
                                                        guard complition != nil else { return }
                                                        complition!(image, error)
                                                    })
        }

    func dispatchResults<Type>(model: Type? = nil, error: Error? = nil, complitionHandler: @escaping (Type?,Error?) -> ()){
        guard let responseQueue = self.responseQueue
        else {
            complitionHandler(model,error)
            return
        }
        responseQueue.async { complitionHandler(model,error) }
    }
}
