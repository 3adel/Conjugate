//
//  OptionController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 10/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class ActionController {
    unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showActions(withTitles titles: [String], actions: [()->()]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for (index, title) in titles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: { _ in
                actions[index]()
            })
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.viewController.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}