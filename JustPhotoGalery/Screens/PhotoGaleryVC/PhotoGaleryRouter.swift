//
//  PhotoGaleryRouter.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 09.02.2022.
//

import Foundation

protocol PhotoGaleryRouterProtocol {
    func showWebLinkVC(for urlAdress: String?, withTitle title: String)
}

class PhotoGaleryRouter: BaseRouter, PhotoGaleryRouterProtocol {
    func showWebLinkVC(for urlAdress: String?, withTitle title: String) {
        if let targetUrlAdress = urlAdress {
            let targetUrl = URL(string: targetUrlAdress)!
            let webKitVC = WebKitViewController(url: targetUrl, title: title)
            viewController?.navigationController?.pushViewController(webKitVC, animated: true)
        }
    }
}
