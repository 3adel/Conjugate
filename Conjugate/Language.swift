//
//  Language.swift
//  Conjugate
//
//  Created by Halil Gursoy on 02/04/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation

public enum Language: String {
    case
    german,
    english,
    spanish,
    french,
    mandarin,
    hindi,
    portuguese,
    arabic,
    bengali,
    russian,
    punjabi,
    japanese,
    telugu,
    malay,
    korean,
    tamil,
    marathi,
    turkish,
    vietnamese,
    urdu,
    italian,
    persian,
    swahili,
    dutch,
    swedish
    
    static var localeIdentifiers: [Language: String] {
        get {
            return [
                .german: "de_DE",
                .english: "en_GB",
                .spanish: "es_ES",
                .french: "fr_FR",
                .mandarin: "zh_Hans_CN",
                .hindi: "hi_IN",
                .portuguese: "pt_PT",
                .arabic: "ar_SA",
                .bengali: "bn_BD",
                .russian: "ru_RU",
                .punjabi: "pa_Arab_PK",
                .japanese: "ja_JP",
                .telugu: "te_IN",
                .malay: "ms_MY",
                .korean: "ko_KR",
                .tamil: "ta_LK",
                .marathi: "mr_IN",
                .turkish: "tr_TR",
                .vietnamese: "vi_VN",
                .urdu: "ur_PK",
                .italian: "it_IT",
                .persian: "fa_IR",
                .swahili: "sw_TZ",
                .dutch: "nl_NL",
                .swedish: "sv_SE"
            ]
        }
    }
    
    init?(localeIdentifier: String) {
        guard let locale = Language.localeIdentifiers.filter ({ $0.value == localeIdentifier }).first
            else { return nil }
        
        self = locale.key
    }
    
    init?(languageCode: String) {
        guard let locale = Language.localeIdentifiers.filter({ keyValue in
            let didFindLanguage = (keyValue.value.components(separatedBy: "_").first ?? "") == languageCode
            return didFindLanguage
        }).first
            else { return nil }
        
        self = locale.key
    }
    
    static func makeLanguage(withLocaleIdentifier localeIdentifier: String) -> Language? {
        return Language(localeIdentifier: localeIdentifier)
    }
    
    var name: String {
        get {
            return rawValue.capitalized
        }
    }
    
    var localeIdentifier: String {
        get {
            return Language.localeIdentifiers[self]!
        }
    }
    
    var languageCode: String {
        get {
            switch self {
            case .mandarin:
                return "cmn"
            case .punjabi:
                return "pa"
            default:
                return self.locale.languageCode!
            }
        }
    }
    
    //Special case for Mandarin
    var displayLanguageCode: String {
        get {
            switch self {
            case .mandarin:
                return "zh"
            default:
                return self.languageCode
            }
        }
    }
    
    //Special case for Mandarin
    var minWordCharacterCount: Int {
        get {
            switch self {
            case .mandarin:
                return 1
            default:
                return 2
            }
        }
    }
    
    var isoCode: String {
        get {
            switch(self) {
            case .english:
                return "eng"
            case .german:
                return "deu"
            case .spanish:
                return "spa"
            case .french:
                return "fra"
            case .italian:
                return "ita"
            case .portuguese:
                return "por"
            case .dutch:
                return "nld"
            case .swedish:
                return "swe"
            default:
                return ""
            }
        }
    }
    
    var countryCode: String {
        get {
            return self.locale.regionCode!
        }
    }
    
    var locale: Locale {
        get {
            return Locale(identifier: localeIdentifier)
        }
    }
    
    var flagImageName: String {
        get {
            return countryCode.lowercased() + "_flag"
        }
    }
    
    var tenseGroups: [TenseGroup] {
        switch self {
        case .german:
            return [
                .indicative,
                .imperative,
                .subjunctive
            ]
        case .english:
            return [
                .indicative,
                .imperative,
                .subjunctive,
                .conditional,
                .progressiveIndicative,
                .progressiveConditional
            ]
        case .dutch:
            return [
                .indicative,
                .conditional,
                .imperative
            ]
        default:
            return [
                .indicative,
                .imperative,
                .conditional,
                .subjunctive
            ]
        }
    }
    
    var tintColor: (CGFloat, CGFloat, CGFloat) {
        switch self {
        case .german:
            return (245, 166, 35)
        case .english:
            return (0, 36, 125)
        case .spanish:
            return (204, 30, 26)
        case .italian:
            return (0, 146, 70)
        case .portuguese:
            return (0, 102, 0)
        case .dutch:
            return (174, 28, 40)
        case .swedish:
            return (254, 203, 0)
        default:
            return (0, 35, 149)
        }
    }
}
