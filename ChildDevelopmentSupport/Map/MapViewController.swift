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
    private var locationManager: CLLocationManager!
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: saveしていないため注意
        prefecture = prefectureRepository.load()
        let filterFacilityInformation = facilityInformations.filter { facilityInformation in
            facilityInformation.address.hasPrefix(prefecture.nameWithSuffix)
        }
        filterFacilityInformation.forEach { facilityInformation in
            geocodingAddressAndAppendAnnotation(facilityInformation: facilityInformation)
        }
        mapView.addAnnotations(annotationArray)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mapView.removeAnnotations(annotationArray)
        annotationArray = []
    }


    private func geocodingAddressAndAppendAnnotation(facilityInformation: FacilityInformation){
        let lat = Double(facilityInformation.latitude)!
        let lng = Double(facilityInformation.longitude)!
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lng)
        annotation.title = "\(facilityInformation.officeName)"
        annotationArray.append(annotation)
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
