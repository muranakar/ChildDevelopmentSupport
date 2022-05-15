//
//  MapViewController.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/12.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet weak var facilityInformationNameLabel: UILabel!
    @IBOutlet weak var facilityInformationTelLabel: UILabel!
    @IBOutlet weak var facilityInformationFaxLabel: UILabel!

    private var locationManager: CLLocationManager!
    private var currentLatitude: Double?
    private var currentLongitude: Double?
    private var currentAdministrativeArea: String?
    private var didStartUpdatingLocation = false
    private var prefecture : JapanesePrefecture = .osaka
    private let prefectureRepository = PrefectureRepository()
    private var facilityInformations: [FacilityInformation] = []
    private var annotationArray:[MKPointAnnotation] = []
    private var selectedFacilityInformation: FacilityInformation?

    override func viewDidLoad() {
        super.viewDidLoad()
        facilityInformations = CSVConversion.convertFacilityInformationFromCsv()
        setupLococationManager()
        configureViewInitialLabel()
        // 現在地にフォーカスを当てる。
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let loadPrefecture = prefectureRepository.load(){
            prefecture = loadPrefecture
        } else {
            // 最初の起動時は、都道府県の保存データがない場合は、大阪を指定している。
            prefecture = .osaka
        }
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
    
    override func viewDidDisappear(_ animated: Bool) {
        mapView.removeAnnotations(annotationArray)
        annotationArray = []
    }

    @IBAction func copyFacilityInformation(_ sender: Any) {




    }
    @IBAction func searchFacilityInformation(_ sender: Any) {
        if selectedFacilityInformation != nil {
            performSegue(withIdentifier: "webView", sender: sender)
        }
    }
    @IBAction func backToMapViewController(segue: UIStoryboardSegue) {
    }


    private func geocodingAddressAndAppendAnnotation(facilityInformation: FacilityInformation){
        let lat = Double(facilityInformation.latitude)!
        let lng = Double(facilityInformation.longitude)!
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lng)
        annotation.title = "\(facilityInformation.officeName)"
        annotationArray.append(annotation)
    }
    private func configureViewLabel(){
        facilityInformationNameLabel.text = selectedFacilityInformation?.officeName
        facilityInformationTelLabel.text = selectedFacilityInformation?.officeTelephoneNumber
        facilityInformationFaxLabel.text = selectedFacilityInformation?.officeFax
    }
    // TODO: 現在地取得後に、アノテーションを再度設定し直したい。現在地を一番最初に取得された時だけ、以下の処理を行いたい。
//    private func saveCurrentPrefectureToRepositoty(lat: Double,lon: Double) {
//        let location = CLLocation(latitude: lat, longitude: lon)
//        CLGeocoder().reverseGeocodeLocation(location) {[weak self] placemarks, error in
//            guard let placemark = placemarks?.first, error == nil else { return  }
//            guard let administrativeArea = placemark.administrativeArea else { return }
//            guard let prefecture = JapanesePrefecture.all
//                .filter({ prefecture in
//                    prefecture.nameWithSuffix == administrativeArea
//                })
//                    .first else { return }
//            self?.prefectureRepository.save(prefecture: prefecture)
//        }
//    }

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
}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        guard let title = annotation.title else { return }
        guard let filterFacilityInformation =
                facilityInformations.filter({ $0.officeName == title }).first else { return }
        selectedFacilityInformation = filterFacilityInformation
        configureViewLabel()
    }
}

extension MapViewController:  CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            if !didStartUpdatingLocation{
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        } else if status == .restricted || status == .denied {
            showPermissionAlert()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            updateMap(currentLocation: location)
            locationManager.stopUpdatingLocation()
        }
//        //　現在地の緯度経度を取得して、グローバル変数へ代入。逆ジオコーディングに用いる。
//        guard let location = manager.location else { return }
//        let lat = Double(location.coordinate.latitude)
//        let lon = Double(location.coordinate.longitude)
//        let loadPrefecture = prefectureRepository.load()
//        if loadPrefecture == nil {
//            // 最初の起動時は、都道府県の保存データがない場合は、現在地を使用する。
//            saveCurrentPrefectureToRepositoty(lat: lat, lon: lon)
//            prefecture = prefectureRepository.load()!
//        } else {
//            prefecture = loadPrefecture!
//        }
//        // 都道府県ごとの事業所をフィルター実施。
//        let filterFacilityInformation = facilityInformations.filter { facilityInformation in
//            facilityInformation.address.hasPrefix(prefecture.nameWithSuffix)
//        }
//        // フィルターした事業所リストを、annotationに変更して、annotation配列に追加
//        filterFacilityInformation.forEach { facilityInformation in
//            geocodingAddressAndAppendAnnotation(facilityInformation: facilityInformation)
//        }
//        mapView.addAnnotations(annotationArray)
        locationManager.stopUpdatingLocation()

    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    private func updateMap(currentLocation: CLLocation){
        let horizontalRegionInMeters: Double = 5000
        let width = self.mapView.frame.width
        let height = self.mapView.frame.height
        let verticalRegionInMeters = Double(height / width * CGFloat(horizontalRegionInMeters))
        let region:MKCoordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                                           latitudinalMeters: verticalRegionInMeters,
                                                           longitudinalMeters: horizontalRegionInMeters)
        mapView.setRegion(region, animated: true)
    }
    func setupLococationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }

        locationManager.requestWhenInUseAuthorization()

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }

    private func initLocation() {
        if !CLLocationManager.locationServicesEnabled() {
            print("No location service")
            return
        }

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            //ユーザーが位置情報の許可をまだしていないので、位置情報許可のダイアログを表示する
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showPermissionAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            if !didStartUpdatingLocation{
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        @unknown default:
            break
        }
    }
    // MARK: - アラート表示関係
    private func showPermissionAlert(){
        //位置情報が制限されている/拒否されている
        let alert = UIAlertController(title: "位置情報の取得", message: "設定アプリから位置情報の使用を許可して下さい。", preferredStyle: .alert)
        let goToSetting = UIAlertAction(title: "設定アプリを開く", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(goToSetting)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
