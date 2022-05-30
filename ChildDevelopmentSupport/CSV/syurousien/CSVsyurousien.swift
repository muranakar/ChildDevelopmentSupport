//
//  CSVsyurousien.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/20.
//

import Foundation

struct CSVConversionSyurousien {
    static func convertFacilityInformationFromCsv() -> [FacilityInformation] {
        var csvLineOneDimensional: [String] = []
        var csvLineTwoDimensional: [[String]] = []
        var pediatricWelfareServices: [FacilityInformation] = []
        guard let path = Bundle.main.path(
            forResource: "syurousien",
            ofType: "csv"
        ) else {
            print("csvファイルがないよ")
            return []
        }
        let csvString = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        csvLineOneDimensional = csvString.components(separatedBy: .newlines)
        print(csvLineOneDimensional[2])
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
