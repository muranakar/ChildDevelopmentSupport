//
//  SearchTableViewCell.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/30.
//

import UIKit

class OfficeNameTableViewCell: UITableViewCell {
    @IBOutlet weak private var label: UILabel!
    func configure(string: String) {
        label.text = string
    }
}
