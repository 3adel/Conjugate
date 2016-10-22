//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol View {
    func showLoader()
    func hideLoader()
    func show(errorMessage: String)
    func hideErrorMessage()
}

extension View {
    func showLoader() {}
    func hideLoader() {}
    func show(errorMessage: String) {}
    func hideErrorMessage() {}
}

protocol ConjugateView: View {
    func updateUI(with viewModel: ConjugateViewModel)
}

protocol ConjugatePresnterType {
    func search(for verb: String)
    func toggleSavingVerb()
}

struct ConjugateViewModel {
    let verb: String
    let language: String
    let meaning: String
    let starSelected: Bool
    let tenseTabs: [TenseTabViewModel]
    
    var isEmpty: Bool {
        return verb == ""
    }
    
    static let empty: ConjugateViewModel = ConjugateViewModel(verb: "", language: "", meaning: "", starSelected: false, tenseTabs: [])
}

struct TenseTabViewModel {
    let name: String
    let tenses: [TenseViewModel]
    
    static let empty = TenseTabViewModel(name: "", tenses: [])
}

extension TenseTabViewModel: Equatable {}

func ==(lhs: TenseTabViewModel, rhs: TenseTabViewModel) -> Bool {
    return lhs.name == rhs.name
}

struct TenseViewModel {
    let name: String
    let forms: [FormViewModel]
}

struct FormViewModel {
    let pronoun: String
    let verb: String
    let textColor: (Float, Float, Float)
    let audioImageHidden: Bool
}

class ConjugatePresenter: ConjugatePresnterType {
    let dataStore = DataStore()
    let view: ConjugateView
    
    var viewModel = ConjugateViewModel.empty
    var verb: Verb?
    
    let searchLocale = Locale(identifier: "de_DE")
    let locale = Locale(identifier: "en_US")
    
    let storage = Storage()
    
    init(view: ConjugateView) {
        self.view = view
        storage.loadVerbs()
    }
    
    func search(for verb: String) {
        view.showLoader()
        view.hideErrorMessage()
        
        dataStore.getInfinitive(of: verb, in: searchLocale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let verb):
                strongSelf.conjugate(verb.name)
            case .failure(let error):
                strongSelf.view.hideLoader()
                strongSelf.view.show(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func conjugate(_ verb: String) {
        dataStore.conjugate(verb, in: searchLocale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let verb):
                strongSelf.translate(verb)
            case .failure(let error):
                strongSelf.view.hideLoader()
                strongSelf.view.show(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func translate(_ verb: Verb) {
        dataStore.getTranslation(of: verb, in: searchLocale, for: locale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.view.hideLoader()
            
            switch result {
            case .success(let verb):
                strongSelf.viewModel = strongSelf.makeConjugateViewModel(from: verb)
                strongSelf.view.updateUI(with: strongSelf.viewModel)
            case .failure(let error):
                strongSelf.view.show(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func toggleSavingVerb() {
        guard let verb = verb else { return }
        
        if storage.verbExists(verb) {
            storage.remove(verb: verb)
        } else {
           storage.save(verb: verb)
        }
        
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
    }
    
    func makeConjugateViewModel(from verb: Verb) -> ConjugateViewModel {
        self.verb = verb
        
        var tenseTabs = [TenseTabViewModel]()
        
        Verb.TenseGroup.allCases.forEach { tenseGroup in
            guard let tenses = verb.tenses[tenseGroup],
                !tenses.isEmpty
                else { return }
            
            var tenseViewModels = [TenseViewModel]()
            
            Tense.Name.allTenses.forEach { tenseName in
                let tensesWithThisName = tenses.filter { $0.name == tenseName }
                tensesWithThisName.forEach { tense in
                    var formViewModels = [FormViewModel]()
                    tense.forms.forEach { form in
                        var colorR: Float = 0
                        var colorG: Float = 0
                        var colorB: Float = 0
                        
                        if form.irregular {
                            colorR = 208/255
                            colorG = 2/255
                            colorB = 27/255
                        } else {
                            colorR = 63/255
                            colorG = colorR
                            colorB = colorR
                        }
                        
                        let color = (colorR, colorG, colorB)
                        
                        
                        let formViewModel = FormViewModel(pronoun: form.pronoun, verb: form.conjugatedVerb, textColor: color, audioImageHidden: false)
                        formViewModels.append(formViewModel)
                    }
                    let tenseViewModel = TenseViewModel(name: tense.name.text, forms: formViewModels)
                    tenseViewModels.append(tenseViewModel)
                }
            }
            
            let tenseTabViewModel = TenseTabViewModel(name: tenseGroup.rawValue.capitalized, tenses: tenseViewModels)
            tenseTabs.append(tenseTabViewModel)
        }
        
        var meaningText = ""
        
        verb.translations?.forEach { translation in
            if verb.translations?.index(of: translation)! != 0 {
                meaningText += ", "
            }
            meaningText += translation
        }
        
        let verbIsSaved = storage.loadVerbs().filter { $0 == verb }.isEmpty
        
        let viewModel = ConjugateViewModel(verb: verb.name, language: locale.languageCode!.uppercased(), meaning: meaningText, starSelected: !verbIsSaved, tenseTabs: tenseTabs)
        return viewModel
    }
}
