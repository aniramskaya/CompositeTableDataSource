//
//  ShoppingSearchVC.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 16.02.2023.
//

import UIKit

class ShoppingSearchVC: UITableViewController {
    private var items = ["Search result first", "Search result second", "Search result third"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    static let cellIdentifier = "CellIdentifier"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier) ??
        UITableViewCell(style: .default, reuseIdentifier: Self.cellIdentifier)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

extension ShoppingSearchVC: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        
    }

    @available(iOS 16.0, *)
    func updateSearchResults(for: UISearchController, selecting: UISearchSuggestion) {
        
    }
}
