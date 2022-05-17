//
//  CSVConversion.swift
//  CoreLocationSample
//
//  Created by 村中令 on 2022/05/05.
//

import Foundation

struct CSVConversion {
    static func convertFacilityInformationFromCsv() -> [FacilityInformation] {
        var csvLineOneDimensional: [String] = []
        var csvLineTwoDimensional: [[String]] = []
        var pediatricWelfareServices: [FacilityInformation] = []
        guard let path = Bundle.main.path(
            forResource: "ChildDevelopmentSupport",
            ofType: "csv"
        ) else {
            print("csvファイルがないよ")
            return []
        }
        let csvString = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        csvLineOneDimensional = csvString.components(separatedBy: "\r\n")
        // 一次元配列のString型を、二次元配列のString型へ変換
        csvLineOneDimensional.forEach { string in
            var array: [String] = []
            array = string.components(separatedBy: ",")
            guard array.count == 29 else { return }
            csvLineTwoDimensional.append(array)
        }
        // 二次元配列のString型を、共通型に変換
        csvLineTwoDimensional.forEach { array in
            let pediatricWelfareService = FacilityInformation(
                corporateName: array[3],
                corporateKana: array[4],
                corporateURL: array[10],
                corporateTelephoneNumber: array[8],
                corporateFax: array[9],
                officeName: array[12],
                officeNameKana: array[13],
                officeURL: array[19],
                officeTelephoneNumber: array[17],
                officeFax: array[18],
                address: array[15] + array[16],
                latitude: array[20],
                longitude: array[21])
            pediatricWelfareServices.append(pediatricWelfareService)
        }
        return pediatricWelfareServices
    }
}
