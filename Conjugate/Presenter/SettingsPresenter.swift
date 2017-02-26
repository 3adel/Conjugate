//
//  SettingsPresenter.swift
//  Conjugate
//
//  Created by Halil Gursoy on 06/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

class SettingsPresenter: SettingsPresenterType {
    enum CellType: String {
        case sendFeedback
        case share
        case reportBug
        case rate
        case conjugationLanguage
        case translationLanguage
        
        var title: String {
            return LocalizedString("mobile.ios.conjugate.settings."+rawValue)
        }
        
        var imageName: String {
            return "settings_"+rawValue
        }
    }
    
    struct TableCell {
        let cellType: CellType
        let cellTitle: String
        
        init(cellType: CellType) {
            self.cellType = cellType
            self.cellTitle = cellType.title
        }
    }
    
    struct TableSection {
        let title: String
        let cells: [TableCell]
    }
    
    let languageCells: [TableCell]
    let optionCells: [TableCell]
    
    let languageSection: TableSection
    let optionSection: TableSection
    
    let sections: [TableSection]
    
    var viewModel = SettingsViewModel.empty
    var emailComposer: EmailComposer?
    
    unowned let view: SettingsView
    
    init(view: SettingsView) {
        self.view = view
        
        languageCells = [
            TableCell(cellType: .conjugationLanguage),
            TableCell(cellType: .translationLanguage)
        ]
        
        optionCells =  [
            TableCell(cellType: .reportBug),
            TableCell(cellType: .sendFeedback),
            TableCell(cellType: .share),
            TableCell(cellType: .rate)
        ]
        
        languageSection = TableSection(title: LocalizedString("mobile.ios.conjugate.settings.section.language"),
                                       cells: languageCells)
        
        optionSection = TableSection(title: "",
                                     cells: optionCells)
        
        sections = [languageSection, optionSection]
    }
    
    func getOptions() {
        viewModel = makeViewModel(languageSection: languageSection, optionSection: optionSection)
        view.render(with: viewModel)
    }
    
    func optionSelected(at section: Int, index: Int, sourceView: View, sourceRect: CGRect) {
        let option = sections[section].cells[index]
        
        switch option.cellType {
        case .reportBug:
            sendSupportEmail(subject: "konj.me iOS bug")
        case .sendFeedback:
            sendSupportEmail(subject: "konj.me iOS feedback")
        case .share:
            let shareController = ShareController(view: view)
            shareController.shareApp(sourceView: sourceView, sourceRect: sourceRect)
        case .rate:
            rateUs()
        default:
            break
        }
    }
    
    func makeViewModel(languageSection: TableSection, optionSection: TableSection) -> SettingsViewModel {
        let languageSectionViewModel = makeSettingsLanguageSectionViewModel(from: languageSection)
        let optionSectionViewModel = makeSettingsOptionSectionViewModel(from: optionSection)
        
        let sectionViewModels = [languageSectionViewModel, optionSectionViewModel]
        
        let footerURL = "http://verbix.com"
        let footerTitle = "In collaboration with " + footerURL
        
        return SettingsViewModel(sections: sectionViewModels, footerTitle: footerTitle, footerURL: footerURL)
    }
    
    func makeSettingsOptionSectionViewModel(from section: TableSection) -> TableSectionViewModel {
        let title = section.title
        let cellViewModels = section.cells.map(makeSettingsOptionViewModel)
        
        return TableSectionViewModel(title: title, cells: cellViewModels)
    }
    
    func makeSettingsLanguageSectionViewModel(from section: TableSection) -> TableSectionViewModel {
        let conjugationViewModel = SettingsLanguageViewModel(title: section.cells[0].cellTitle, languageName: "DE", languageImageName: "de_flag")
        let translationViewModel = SettingsLanguageViewModel(title: section.cells[1].cellTitle, languageName: "EN", languageImageName: "gb_flag")
        
        let cells = [conjugationViewModel, translationViewModel]
        
        return TableSectionViewModel(title: section.title, cells: cells)
    }
    
    func makeSettingsOptionViewModel(from cellData: TableCell) -> SettingsOptionViewModel {
        let title = cellData.cellTitle
        let imageName = cellData.cellType.imageName
        
        return SettingsOptionViewModel(title: title, imageName: imageName)
    }
    
    func sendSupportEmail(subject: String) {
        guard let infoDict = Bundle.main.infoDictionary,
            let versionNumber = infoDict["CFBundleShortVersionString"] as? String,
            let buildNumber = infoDict["CFBundleVersion"] as? String
            else {
                return
        }
        
        emailComposer = EmailComposer(view: view)
        emailComposer?.sendEmail(withSubject: subject, recipient: "feedback@konj.me", version: versionNumber, build: buildNumber)
    }
    
    func rateUs(){
        UIApplication.shared.openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1163600729")! as URL)
    }
}

