//
//  SearchViewController.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/27.
//

import UIKit
import GoogleMobileAds

class SearchViewController: UIViewController {
    @IBOutlet weak  var categorySegumentControl: UISegmentedControl!
    @IBOutlet weak var searcdBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak private var bannerView: GADBannerView!  // 追加したUIViewを接続
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdBannar()
    }
    private func configureAdBannar() {
        // GADBannerViewのプロパティを設定
        bannerView.adUnitID = "\(GoogleAdID.bannerID)"
        bannerView.rootViewController = self

        // 広告読み込み
        bannerView.load(GADRequest())
    }
}

extension SearchViewController: UISearchBarDelegate {

}

extension SearchViewController: UITableViewDelegate {


}

extension SearchViewController: UITableViewDataSource {

}
