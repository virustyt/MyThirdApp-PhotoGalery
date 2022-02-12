//
//  WebKitViewController.swift
//  JustPhotoGalery
//
//  Created by Vladimir Oleinikov on 11.02.2022.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController {

    private lazy var webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false

        return webView
    }()

    var url: URL

    //MARK: - inits
    init(url: URL, title: String){
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
        setUpConstraints()
    }

    //MARK: - private funcs
    private func setUpConstraints(){
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        ])
    }
}
