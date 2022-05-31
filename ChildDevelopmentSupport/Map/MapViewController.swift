//
//  MapViewController.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/12.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMobileAds

class MapViewController: UIViewController {

    @IBOutlet weak private var prefectureLabel: UILabel!
    @IBOutlet weak private var mapView: MKMapView!
    @IBOutlet weak private var facilityInformationNameLabel: UILabel!
    @IBOutlet weak private var facilityInformationTelLabel: UILabel!
    @IBOutlet weak private var facilityInformationFaxLabel: UILabel!
    //　広告
    @IBOutlet weak private var bannerView: GADBannerView!  // 追加したUIViewを接続

    private var locationManager: CLLocationManager!
    private var prefecture: JapanesePrefecture = .osaka
    private let prefectureRepository = PrefectureRepository()
    private var facilityInformations: [FacilityInformation] = []
    private var annotationArray: [MKPointAnnotation] = []
    private var selectedFacilityInformation: FacilityInformation?

    private let pickerView = UIPickerView()


    override func viewDidLoad() {
        super.viewDidLoad()
        facilityInformations = UseCaseCsvConversion.convertFacilityInformationFromCsv()
        setupLococationManager()
        configurePrefectureLabel()
        configureViewInitialLabel()
        configureAdBannar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 都道府県情報が保存されていれば、その情報を適応
        // 保存されていない場合は、東京の情報を適応
        if let loadedPrefecture = prefectureRepository.load() {
            prefecture = loadedPrefecture
        } else {
            prefecture = .tokyo
        }
        filterFacilityInformationAndAddAnnotations(prefecture: prefecture)
    }

    override func viewDidDisappear(_ animated: Bool) {
        mapView.removeAnnotations(annotationArray)
        annotationArray = []
    }
    @IBAction private func coreLocation(_ sender: Any) {
        guard let current = locationManager.location.self else {
            // 位置情報の設定をしてください　、アラートを表示。
            // アラート後に位置情報設定画面に飛ぶ。
            present(
                UIAlertController.configureLocationSetting {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
                    }
                },
                animated: true)
            return
        }
        updateReducedMap(currentLocation: current)
    }

    @IBAction private func callTelephoneNumber(_ sender: Any) {
        guard let selectedFacilityInformation = selectedFacilityInformation else { return }
        let phoneNumber = "\(selectedFacilityInformation.officeTelephoneNumber)"
        guard let url = URL(string: "tel://" + phoneNumber) else { return }
        UIApplication.shared.open(url)
    }

    @IBAction private func copyFacilityInformation(_ sender: Any) {
        let pastboardFormatter = PasteboardFormatterFacilityInformation()
        guard let selectedFacilityInformation = selectedFacilityInformation else {
            // アノテーションが選択されていない　とアラート表示
            present(UIAlertController.checkIsSelectedAnnotation(), animated: true)
            return
        }
        UIPasteboard.general.string = pastboardFormatter.string(from: selectedFacilityInformation)
        // コピーが完了した　とアラート表示
        present(UIAlertController.copyingCompletedFacilityInformation(), animated: true)
    }

    @IBAction private func searchFacilityInformation(_ sender: Any) {
        if selectedFacilityInformation == nil {
            present(UIAlertController.checkIsSelectedAnnotation(), animated: true)
        } else {
            performSegue(withIdentifier: "webView", sender: sender)
        }
    }
    private func filterFacilityInformationAndAddAnnotations(prefecture: JapanesePrefecture) {
        // 都道府県ごとの事業所をフィルター実施。
        let filterFacilityInformation = facilityInformations.filter { facilityInformation in
            facilityInformation.address.hasPrefix(prefecture.nameWithSuffix)
        }
        // フィルターした事業所リストを、annotationに変更して、annotation配列に追加
        filterFacilityInformation.forEach { facilityInformation in
            geocodingAddressAndAppendAnnotation(facilityInformation: facilityInformation)
        }
        mapView.addAnnotations(annotationArray)
    }

    private func geocodingAddressAndAppendAnnotation(facilityInformation: FacilityInformation) {
        // 緯度経度の数値がnilの場合は、Map上に反映されないため、注意必要。
        guard let lat = Double(facilityInformation.latitude) else { return }
        guard let lng = Double(facilityInformation.longitude) else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lng)
        annotation.title = "\(facilityInformation.officeName)"
        annotation.subtitle = "\(facilityInformation.address)"
        annotationArray.append(annotation)
    }

    private func configureAdBannar() {
        // GADBannerViewのプロパティを設定
        bannerView.adUnitID = "\(GoogleAdID.bannerID)"
        bannerView.rootViewController = self

        // 広告読み込み
        bannerView.load(GADRequest())
    }

    private func configurePrefectureLabel() {
        guard let prefecture = prefectureRepository.load() else { return }
        prefectureLabel.text = "\(prefecture.nameWithSuffix)　表示中"
    }
    private func configureViewLabel() {
        facilityInformationNameLabel.text = selectedFacilityInformation?.officeName
        facilityInformationTelLabel.text = selectedFacilityInformation?.officeTelephoneNumber
        facilityInformationFaxLabel.text = selectedFacilityInformation?.officeFax
    }

    private func configureViewInitialLabel() {
        facilityInformationNameLabel.text = "未選択"
        facilityInformationTelLabel.text = ""
        facilityInformationFaxLabel.text = ""
    }
}
extension MapViewController {
    @IBSegueAction
    func makeAssessment(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> WebViewViewController? {
        WebViewViewController(coder: coder, facilityInformation: selectedFacilityInformation!)
    }

    // swiftlint:disable:next private_action
    @IBAction func backToMapViewController(segue: UIStoryboardSegue) {
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        guard let annotationTitle = annotation.title else { return }
        guard let annotationSubTitle = annotation.subtitle else { return }

        // すべてのFacilityInformationから、officeName,adressが一致する、一つのFacilityInformationを抽出
        guard let filterFacilityInformation =
                facilityInformations
            .filter({ $0.officeName == annotationTitle })
            .filter({ $0.address == annotationSubTitle })
            .first else { return }

        guard let lat = Double(filterFacilityInformation.latitude),
              let lon = Double(filterFacilityInformation.longitude) else { return }
        let location = CLLocation(latitude: lat, longitude: lon)
        updateEnlargedMap(currentLocation: location)
        selectedFacilityInformation = filterFacilityInformation
        configureViewLabel()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //        switch status {
        //        case .notDetermined, .restricted, .denied:
        //            let tokyoLocation = CLLocation(latitude: 35.6809591, longitude: 139.7673068)
        //            updateReducedMap(currentLocation: tokyoLocation)
        //        case .authorizedAlways, .authorizedWhenInUse:
        //            setupLococationManager()
        //        @unknown default:
        //         break
        //        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        updateReducedMap(currentLocation: location)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    func setupLococationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        if let loadPrefecture = prefectureRepository.load() {
            prefecture = loadPrefecture
        } else {
            // 最初の起動時は、都道府県の保存データがない場合は、東京を保存。
            prefectureRepository.save(prefecture: .tokyo)
            prefecture = .tokyo
        }
        switch locationManager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            let tokyoLocation = CLLocation(latitude: 35.6809591, longitude: 139.7673068)
            updateReducedMap(currentLocation: tokyoLocation)
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    // Mapkitで、ある一点を中心に、ズームインを行うメソッド
    private func updateEnlargedMap(currentLocation: CLLocation) {
        let horizontalRegionInMeters: Double = 2000
        let width = mapView.frame.width
        let height = mapView.frame.height
        let verticalRegionInMeters = Double(height / width * CGFloat(horizontalRegionInMeters))
        let region: MKCoordinateRegion = MKCoordinateRegion(
            center: currentLocation.coordinate,
            latitudinalMeters: verticalRegionInMeters,
            longitudinalMeters: horizontalRegionInMeters
        )
        mapView.setRegion(region, animated: true)
    }
    // Mapkitで、ある一点を中心に、ズームインを行うメソッド
    private func updateReducedMap(currentLocation: CLLocation) {
        let horizontalRegionInMeters: Double = 12500
        let width = mapView.frame.width
        let height = mapView.frame.height
        let verticalRegionInMeters = Double(height / width * CGFloat(horizontalRegionInMeters))
        let region: MKCoordinateRegion = MKCoordinateRegion(
            center: currentLocation.coordinate,
            latitudinalMeters: verticalRegionInMeters,
            longitudinalMeters: horizontalRegionInMeters
        )
        mapView.setRegion(region, animated: true)
    }
}

//extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        pickerViewItemsOfPrefecture[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let prefecture = JapanesePrefecture.all
//            .filter { $0.nameWithSuffix == pickerViewItemsOfPrefecture[row] }.first!
//        prefectureRepository.save(prefecture: prefecture)
//    }
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        pickerViewItemsOfPrefecture.count
//    }
//}
