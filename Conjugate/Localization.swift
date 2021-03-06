//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

// MARK: - Localize

public func LocalizedString(_ key: String, in language: Language? = nil, languageType: LanguageType? = nil, args: String...) -> String {
    let prefix = "mobile.ios.conjugate"
    
    var finalKey = key
    if !key.contains(prefix) {
        finalKey = prefix+"."+key
    }
    
    let str: String
    
    if let languageType = languageType {
        str = AppDependencyManager.shared.languageConfig.localizedString(withKey: finalKey, languageType: languageType)
    } else if let language = language {
        str = AppDependencyManager.shared.languageConfig.localizedString(withKey: finalKey, in: language)
    } else {
        str = NSLocalizedString(finalKey, comment: "")
    }
    return replacePlaceholders(str, args: args)
}

public func LocalizedUppercaseString(_ string:String, args: String...) -> String {
    let str = LocalizedString(string).uppercased(with: Locale.current)
    return replacePlaceholders(str, args: args)
}

public func replacePlaceholders(_ placeholderString: String, args: [String]) -> String {
    var str = placeholderString
    var finalStr = str
    let openingToken:Character = "<"
    let closingToken:Character = ">"
    for arg in args {
        guard let openingIndex = str.characters.index(of: openingToken) as String.Index?,
            let closingIndex = str.characters.index(of: closingToken) as String.Index? else { return placeholderString }
        
        let range = openingIndex ..< str.index(after: closingIndex)
        let replacedString = str.substring(with: range)
        finalStr = finalStr.replacingOccurrences(of: replacedString, with: arg, options: [], range: nil)
        str = str.replacingCharacters(in: range, with: "")
    }
    return finalStr
}

