//
//  WebViewViewController.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/14.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    @IBOutlet weak private var webView: WKWebView!
    private var facilityInformation: FacilityInformation
    required init?(coder: NSCoder, facilityInformation: FacilityInformation) {
        self.facilityInformation = facilityInformation
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.allowsBackForwardNavigationGestures = true
        serchOfficeURLOrCorporateURLOrGoogle()
    }

    @IBAction private func goBackWebView(_ sender: Any) {
        webView.goBack()
    }
    @IBAction private func goForwardWebView(_ sender: Any) {
        webView.goForward()
    }
    @IBAction private func serchGoogle(_ sender: Any) {
        serchGoogleByOfficeName()
    }

    private func serchOfficeURLOrCorporateURLOrGoogle() {
        let url: URL?
        if facilityInformation.officeURL != "" {
            let urlString = facilityInformation.officeURL
            let encodingString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            url = URL(string: encodingString!)
            print(facilityInformation.officeURL)
        } else if facilityInformation.corporateURL != "" {
            url = URL(string: facilityInformation.corporateURL)
            print(facilityInformation.corporateURL)
        } else {
            let urlString = "https://www.google.co.jp/search?q=\(facilityInformation.officeName)"
            let encodingString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            url = URL(string: encodingString!)
            print("https://www.google.co.jp/search?q=\(facilityInformation.officeName)")
        }
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
    }

    private func serchGoogleByOfficeName() {
        let url: URL?
        let urlString = "https://www.google.co.jp/search?q=\(facilityInformation.officeName)"
        let encodingString = urlString.addingPercentEncoding(
            withAllowedCharacters: NSCharacterSet.urlQueryAllowed
        )
        url = URL(string: encodingString!)
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
    }
}
