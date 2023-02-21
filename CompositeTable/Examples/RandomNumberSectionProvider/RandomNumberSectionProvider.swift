//
//  RandomNumberSectionProvider.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 15.02.2023.
//

import UIKit

class RandomNumberSectionProvider: TableViewSectionProvider {
    let id: String
    private(set) var isVisible = true
    private(set) var cellItems: [TableItem] = []
    private(set) var headerView: UIView?
    private(set) var footerView: UIView?
    
    var onNeedsDisplay: (() -> Void)?

    
    let maxItemCount: Int
    init(id: String, maxItemCount: Int = 10) {
        self.id = id
        self.maxItemCount = maxItemCount
        attachHeaderView()
    }
    
    // MARK: - Lifecycle

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
    
    // MARK: - Cells

    func configure(cell: UITableViewCell, for item: TableItem, at index: Int) {
        guard let cell = cell as? SimpleTableCell else { return }
        cell.titleLabel.text = item.id
    }
    
    // MARK: - Public API

    func generate() {
        let numberOfItems = Int.random(in: 1...maxItemCount)
        let items = (0...numberOfItems).map {
            BasicTableItem(id: "\($0)", cellReuseIdentifier: cellReuseIdentifier)
        }.shuffled()
        display(items)
    }
    
    // MARK: - Private

    private func display(_ items: [TableItem]) {
        self.cellItems = items
        isVisible = true
        onNeedsDisplay?()
    }
    

    private func attachHeaderView() {
        headerView = RandomNumberSectionHeader(title: "Section header \(id)")
        headerView?.backgroundColor = .lightGray
        footerView = RandomNumberSectionHeader(title: "Section footer \(id)")
        footerView?.backgroundColor = .gray
    }
}
