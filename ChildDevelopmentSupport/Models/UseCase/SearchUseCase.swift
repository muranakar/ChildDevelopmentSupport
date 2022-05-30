//
//  SearchUseCase.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/30.
//

import Foundation

struct UseCaseSearch {
    static func filteredSearchFacilityInformation(
        filterSearch: FilterSearch,
        string: String
    ) -> [FacilityInformation] {
        let allFacilityInformation = UseCaseCsvConversion.convertFacilityInformationFromCsv()
        var filterFacilityInformation: [FacilityInformation]
        switch filterSearch {
        case .officeNameAndOfficeNameKana:
            filterFacilityInformation = allFacilityInformation
                .filter { $0.corporateName.contains(string) || $0.corporateKana.contains(string) }
        case .corporateNameAndCoporateKana:
            filterFacilityInformation = allFacilityInformation
                .filter { $0.officeName.contains(string) || $0.officeNameKana.contains(string) }
        case .address:
            filterFacilityInformation = allFacilityInformation
                .filter { $0.address.contains(string) }
        }
        return filterFacilityInformation
    }
}

enum FilterSearch {
    init(string: String) {
        switch string {
        case "事業所名":
            self = .officeNameAndOfficeNameKana
        case "会社名":
            self = .corporateNameAndCoporateKana
        case "住所":
            self = .address
        default:
            fatalError("FilterSearchに値が設定されていません。")
        }
    }
    case officeNameAndOfficeNameKana
    case corporateNameAndCoporateKana
    case address
}
