//
//  SettingViewController.swift
//  ChildDevelopmentSupport
//
//  Created by 村中令 on 2022/05/12.
//

import UIKit

class SettingViewController: UIViewController {
    let pickerViewItemsOfPrefecture = JapanesePrefecture.all.map { prefecture in
        prefecture.nameWithSuffix
    }
    let prefectureRepository = PrefectureRepository()

    @IBOutlet weak private var prefecturePickerView: UIPickerView!

    override func viewDidLayoutSubviews() {
        selectRowPrefecturePickerView()
    }
    @IBAction private func configureCoreLocation(_ sender: Any) {
        configureLocationInformation()
    }

    @IBAction private func jumpToTwitter(_ sender: Any) {
        jumpToTwitterInformation()
    }

    private func selectRowPrefecturePickerView() {
        guard let loadedPrefecture = prefectureRepository.load() else { return }
        let prefectureRow = pickerViewItemsOfPrefecture.firstIndex(of: loadedPrefecture.nameWithSuffix)
        guard let prefectureRow = prefectureRow else { return }
        prefecturePickerView.selectRow(prefectureRow, inComponent: 0, animated: true)
    }

    private func configureLocationInformation() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }

    private func jumpToTwitterInformation() {
        let url = NSURL(string: "https://twitter.com/iOS76923384")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}

extension SettingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerViewItemsOfPrefecture[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let prefecture = JapanesePrefecture.all.filter { $0.nameWithSuffix == pickerViewItemsOfPrefecture[row] }.first!
        prefectureRepository.save(prefecture: prefecture)
    }
}

extension SettingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerViewItemsOfPrefecture.count
    }
}
