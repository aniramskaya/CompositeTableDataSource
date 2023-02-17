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
            RandomNumberSectionProvider(view: TableSectionView(id: "first")),
            RandomNumberSectionProvider(view: TableSectionView(id: "second"))
        ])
        
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
        title = "Шоппинг"
        navigationItem.largeTitleDisplayMode = .always
        setupSearchController()
    }
    
    private func setupSearchController() {
        let resultsTableController = ShoppingSearchVC(style: .plain)
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        //searchController?.delegate = self
        searchController?.searchResultsUpdater = resultsTableController
        searchController?.searchBar.autocapitalizationType = .none
        searchController?.searchBar.delegate = self // Monitor when the search button is tapped.
        
        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        /** Search presents a view controller by applying normal view controller presentation semantics.
         This means that the presentation moves up the view controller hierarchy until it finds the root
         view controller or one that defines a presentation context.
         */
        
        /** Specify that this view controller determines how the search controller is presented.
         The search controller should be presented modally and match the physical size of this view controller.
         */
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource?.viewWillAppear()
    }
    
    @objc func refresh() {
        dataSource?.sectionProviders.forEach {
            ($0 as! RandomNumberSectionProvider).generate()
        }
    }
    
    @objc func toggleFirstCellHeight() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SimpleTableCell {
            cell.toggleHeight()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}


extension CompositeTableVC: UISearchBarDelegate {
//    func position(for bar: UIBarPositioning) -> UIBarPosition {
//        return .topAttached
//    }
}
