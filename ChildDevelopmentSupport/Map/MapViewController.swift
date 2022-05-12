//
//  MapViewController.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/12.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let start = Date()
        var facilityInformations = CSVConversion.convertFacilityInformationFromCsv()
        let elapsed = Date().timeIntervalSince(start)
        print(elapsed)
        

    }
}
