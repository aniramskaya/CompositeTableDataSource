//
//  RandomNumberSectionProvider.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 15.02.2023.
//

import UIKit

class RandomNumberSectionProvider: TableViewSectionProvider {
    var view: TableSectionView
    let maxItemCount: Int
    init(view: TableSectionView, maxItemCount: Int = 10) {
        self.view = view
        self.maxItemCount = maxItemCount
        attachHeaderView()
    }
    
    let cellReuseIdentifier = "SimpleTableCell"
    
    func registerCells(for tableView: UITableView) {
        tableView.register(
            UINib(nibName: "SimpleTableCell", bundle: nil),
            forCellReuseIdentifier: cellReuseIdentifier
        )
    }
    
    func viewWillAppear() {
        generate()
    }
    
    func configure(cell: UITableViewCell, for item: TableItem, at index: UInt) {
        guard let cell = cell as? SimpleTableCell else { return }
        cell.titleLabel.text = item.id
    }
    
    func generate() {
        let numberOfItems = Int.random(in: 1...maxItemCount)
        let items = (0...numberOfItems).map {
            TableItem(id: "\($0)", cellReuseIdentifier: cellReuseIdentifier)
        }.shuffled()
        view.display(with: items)
    }
    
    private func attachHeaderView() {
        view.headerView = RandomNumberSectionHeader(title: "Section header \(view.id)")
        view.headerView?.backgroundColor = .lightGray
        view.footerView = RandomNumberSectionHeader(title: "Section footer \(view.id)")
        view.footerView?.backgroundColor = .gray
    }
}
