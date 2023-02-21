//
//  CompositeTableVC.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 05.02.2023.
//

import UIKit

class CompositeTableVC: UITableViewController {
    private var searchController: UISearchController?
    var dataSource: CompositeTableDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = CompositeTableDataSource(tableView: tableView)
        self.dataSource?.setSectionProviders([
            RandomNumberSectionProvider(id: "first"),
            RandomNumberSectionProvider(id: "second"),
            GallerySectionProvider(id: "gallery")
        ])
        
        attachNavBarButtons()
        title = "Шоппинг"
        navigationItem.largeTitleDisplayMode = .always
        embedSearchbar()
    }
    
    private func attachNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Height",
            style: .plain,
            target: self,
            action: #selector(toggleFirstCellHeight)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "list-search"),
            style: .plain,
            target: self,
            action: #selector(refresh)
        )
    }
    
    var searchbar: UISearchBar?
    private func embedSearchbar() {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Найти"
        searchbar.delegate = self
        navigationItem.titleView = searchbar
        self.searchbar = searchbar
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource?.viewWillAppear()
    }
    
    @objc func refresh() {
        dataSource?.sectionProviders.forEach {
            ($0 as? RandomNumberSectionProvider)?.generate()
        }
    }
    
    @objc func toggleFirstCellHeight() {
        guard let sectionProviders = dataSource?.sectionProviders else { return }
        for provider in sectionProviders where provider is GallerySectionProvider {
            (provider as! GallerySectionProvider).toggleFirstCellHeight()
        }
    }
    
    @objc func cancelSearch() {
        searchbar?.resignFirstResponder()
    }

    
    var searchResultsVC: ShoppingSearchVC?
    var tableContentOffset: CGPoint = .zero
    private func attachSearchResultsVC() {
        tableContentOffset = tableView.contentOffset
        let searchResultsVC = ShoppingSearchVC()
        searchResultsVC.modalTransitionStyle = .crossDissolve
        searchResultsVC.modalPresentationStyle = .overCurrentContext
        present(searchResultsVC, animated: true)
        transitionCoordinator?.animate(alongsideTransition: { context in
            self.navigationItem.largeTitleDisplayMode = .never
        })
        self.searchResultsVC = searchResultsVC
    }
    
    private func detachSearchResultsVC() {
        guard let searchResultsVC else { return }
        searchResultsVC.dismiss(animated: true)
        self.tableView.contentOffset = self.tableContentOffset
        transitionCoordinator?.animate(alongsideTransition: { context in
            self.navigationItem.largeTitleDisplayMode = .always
        })
    }
}


extension CompositeTableVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSearch))
        attachSearchResultsVC()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        attachNavBarButtons()
        detachSearchResultsVC()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
