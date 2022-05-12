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

        
        // csvファイルの変換
        let csvStart = Date()
        let csvFacilityInformations = CSVConversion.convertFacilityInformationFromCsv()
        let csvElapsed = Date().timeIntervalSince(csvStart)
        print("csvファイル→共通型　所要時間：",csvElapsed)


        // jsonファイルの変換
        let json1Start = Date()
        let jsonDecodableFacilityInformations = DecoderFacilityInformation.loadDecodableFacilityInformation()
        let json1Elapsed = Date().timeIntervalSince(json1Start)
        print("jsonファイル→共通型(decodableに準拠している)　所要時間：",json1Elapsed)


        let json2Start = Date()
        let json2FacilityInformations = DecoderFacilityInformation.loadFacilityInformation()
        let json2Elapsed = Date().timeIntervalSince(json2Start)
        print("jsonファイル→共通型(decodableに準拠していない)　所要時間：",json2Elapsed)
    }
}
