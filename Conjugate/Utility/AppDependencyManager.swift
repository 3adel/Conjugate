//
//  AppDependencyManager.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation


class AppDependencyManager: NotificationSender {
    enum Notification: String, NotificationName {
        case conjugationLanguageDidChange
        case translationLanguageDidChange
    }
    
    enum NotificationKey: String, DictionaryKey {
        case language
    }
    
    static let shared: AppDependencyManager = AppDependencyManager(
        languageConfig: LanguageConfig(selectedConjugationLanguage: Language.german,
                                       selectedTranslationLanguage: Language.english,
                                       availableConjugationLanguages: [Language.german, Language.spanish],
                                       availableTranslationLanguages: [Language.english])
    )
    
    var languageConfig: LanguageConfig
    
    init(languageConfig: LanguageConfig) {
        self.languageConfig = languageConfig
    }
    
    func change(conjugationLanguageTo language: Language) {
        languageConfig = languageConfig.byChangingConjugationLanguage(to: language)
        
        let userInfo: [AnyHashable: Any] = [NotificationKey.language.key: language]
        send(Notification.conjugationLanguageDidChange, userInfo: userInfo)
    }
    
    func change(translationLanguageTo language: Language) {
        languageConfig = languageConfig.byChangingTranslationLanguage(to: language)
        
        let userInfo: [AnyHashable: Any] = [NotificationKey.language.key: language]
        send(Notification.translationLanguageDidChange, userInfo: userInfo)
    }
}
