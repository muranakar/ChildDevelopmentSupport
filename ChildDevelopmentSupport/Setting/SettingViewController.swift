//
//  SettingViewController.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/12.
//

import UIKit

class SettingViewController: UIViewController {
    let pickerViewItems = JapanesePrefecture.all.map { prefecture in
        prefecture.nameWithSuffix
    }
    let prefectureRepository = PrefectureRepository()

    @IBOutlet weak var prefecturePickerView: UIPickerView!

    func configurePicekerView() {
    }
}

extension SettingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerViewItems[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let prefecture = JapanesePrefecture.all.filter { $0.nameWithSuffix == pickerViewItems[row] }.first!
        prefectureRepository.save(prefecture: prefecture)
    }
}

extension SettingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerViewItems.count
    }
}
