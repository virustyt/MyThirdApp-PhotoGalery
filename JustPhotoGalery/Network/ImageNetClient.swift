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
    func getImage(from imageURL: URL,
                  complition: ((UIImage?, Error?)-> ())?)
}

class ImageClient {
    var cashedDataTasks: [URL: URLSessionDataTask]

    var urlSession: URLSession
    var responseQueue: DispatchQueue?
    private var cache: URLCache? {
        urlSession.configuration.urlCache
    }

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
                self.dispatchResults(model: recievedImage,complitionHandler: complition)
            }
            else{
                self.dispatchResults(error: error, complitionHandler: complition)
            }
        }
        dataTask.resume()
        return dataTask
    }

    func getImage(from imageURL: URL, complition: ((UIImage?, Error?)-> ())? = nil) {
        cashedDataTasks[imageURL]?.cancel()
        cashedDataTasks[imageURL] = downloadImages(imageURL: imageURL,
                                                    complition: {[weak self] image, error in
                                                        guard let self = self else {return}

                                                        self.cashedDataTasks[imageURL] = nil

                                                        guard complition != nil else { return }
                                                        complition!(image, error)
                                                    })
        }

    func dispatchResults<Type>(model: Type? = nil, error: Error? = nil, complitionHandler: @escaping (Type?,Error?) -> ()){
        guard let responseQueue = responseQueue
        else {
            complitionHandler(model,error)
            return
        }
        responseQueue.async { complitionHandler(model,error) }
    }
}
