//
//  PhotoNetClient.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

protocol PhotoNetClientProtocol {
    func getAllPhotos(complition: @escaping (PhotosInfoDictionary?, Error?) -> ()) -> URLSessionDataTask?
}

class PhotoNetClient: PhotoNetClientProtocol {
    private enum RequestError: Error{
        case noBaseURLExistsForSpaceXObject(object:Photo)
    }

    private let baseUrls: URL
    private let urlSession: URLSession
    private var resopnseQueue: DispatchQueue? = nil

    static let shared = PhotoNetClient(baseUrls: URL(string: "http://dev.bgsoft.biz/")!,
                                       urlSession: URLSession.shared,
                                       responseQueue: .main)

    // MARK: - inits
    init(baseUrls: URL, urlSession: URLSession = URLSession.shared, responseQueue: DispatchQueue?){
        self.baseUrls = baseUrls
        self.urlSession = urlSession
        self.resopnseQueue = responseQueue
    }

    // MARK: - public funcs
    func getAllPhotos(complition: @escaping (PhotosInfoDictionary?, Error?) -> ()) -> URLSessionDataTask? {
        guard let url = URL(string: "task/", relativeTo: baseUrls) else { return nil}

        let dataTask = urlSession.dataTask(with: url) {[weak self] data, response, error in
            guard let self = self else {return}
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode,
                  let recievedData = data
            else {
                self.dispatchResults(error: error, complitionHandler: complition )
                return
            }
            do {
                let photos = try JSONDecoder().decode(PhotosInfoDictionary.self, from: recievedData)
                self.dispatchResults(model: photos, complitionHandler: complition)
            } catch {
                self.dispatchResults(error: error, complitionHandler: complition)
            }
        }
        dataTask.resume()
        return dataTask
    }

    // MARK: - private funcs
    func dispatchResults<Type>(model: Type? = nil, error: Error? = nil, complitionHandler: @escaping (Type?,Error?) -> ()){
        guard let responseQueue = self.resopnseQueue
        else {
            complitionHandler(model,error)
            return
        }
        responseQueue.async { complitionHandler(model,error) }
    }
}
