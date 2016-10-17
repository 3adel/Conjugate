//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class ConjugateViewController: UIViewController {
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var verbLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    
    let tabbedMenuSegue = "tabbedMenuSegue"
    let tabbedContentSegue = "tabbedContentSegue"
    
    var presenter: ConjugatePresnterType!
    
    var searchTimer: Timer?
    var tabbedMenuViewController: TabbedMenuViewController?
    var tabbedContentViewController: TabbedContentViewController?
    
    var viewModel = ConjugateViewModel.empty
    
    var tabTableViewDatasources = [TenseTableViewDataSource]()
    var tabTableViews = [UITableView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
        
        tabbedContentViewController?.menuController = tabbedMenuViewController
        tabbedMenuViewController?.contentController = tabbedContentViewController
    }
    
    override func setupUI() {
        super.setupUI()
        
        navigationController?.isNavigationBarHidden = true
        
        searchView.layer.cornerRadius = 4
        searchView.layer.borderWidth = 1
        
        searchField.delegate = self
        
        let grayColor: CGFloat = 230/255.0
        searchView.layer.borderColor = UIColor(red: grayColor, green: grayColor, blue: grayColor, alpha: 1.0).cgColor
    }
    
    func search() {
        let text = searchField.text ?? ""
        presenter.search(for: text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tabbedMenuSegue {
            guard let
                menuViewController = segue.destination as? TabbedMenuViewController
                else { return }
            setup(tabbedMenuViewController: menuViewController)
        } else if segue.identifier == tabbedContentSegue {
            guard let
                tabContentViewController = segue.destination as? TabbedContentViewController
                else { return }
            setup(tabbedContentViewController: tabContentViewController)
        }
    }
    
    func setup(tabbedMenuViewController: TabbedMenuViewController) {
        
        let textColorRGB: CGFloat = 117/255
        let textColor = UIColor(red: textColorRGB, green: textColorRGB, blue: textColorRGB, alpha: 1)
        let selectedColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        
        let theme = TabbedMenuTheme(textColor: textColor, selectedColor: selectedColor)
        
        tabbedMenuViewController.setTheme(theme)
        
        self.tabbedMenuViewController = tabbedMenuViewController
    }
    
    func setup(tabbedContentViewController: TabbedContentViewController) {
        
        self.tabbedContentViewController = tabbedContentViewController
    }
    
    private func setupPresenter() {
        presenter = ConjugatePresenter(view: self)
    }
}

extension ConjugateViewController: ConjugateView {
    func updateUI(with viewModel: ConjugateViewModel) {
        verbLabel.text = viewModel.verb
        languageLabel.text = viewModel.language + " - "
        meaningLabel.text = viewModel.meaning
        updateTabs(with: viewModel)
    }
    
    func updateTabs(with viewModel: ConjugateViewModel) {
        var tabs: [TabbedMenuViewController.Tab] = []
        
        tabTableViews.removeAll()
        tabTableViewDatasources.removeAll()
        
        viewModel.tenseTabs.forEach { tenseViewModel in
            let tableView = UITableView(frame: CGRect.zero, style: .grouped)
//            tableView.separatorStyle = .none
            tableView.allowsMultipleSelection = false
            tableView.allowsSelection = true
            
            let dataSource = TenseTableViewDataSource(tableView: tableView)
            
            dataSource.viewModel = tenseViewModel
            
            tabTableViews.append(tableView)
            tabTableViewDatasources.append(dataSource)
            
            let tab = TabbedMenuViewController.Tab(title: tenseViewModel.name, view: tableView)
            tabs.append(tab)
        }
        
        tabbedMenuViewController?.tabs = tabs
        tabbedContentViewController?.views = tabTableViews
    }
}

extension ConjugateViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchTimer?.invalidate()
        searchTimer = nil
        
        searchTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(search), userInfo: nil, repeats: false)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        view.endEditing(true)
        return true
    }
}

