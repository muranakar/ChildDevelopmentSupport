//
//  CoporateNameTableViewCell.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/31.
//

import UIKit

class CorporateNameTableViewCell: UITableViewCell {
    @IBOutlet weak private var label: UILabel!
    func configure(string: String) {
        label.text = string
    }
}
