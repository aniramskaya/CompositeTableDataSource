//
//  TableSectionDataSource.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 15.02.2023.
//

import UIKit

protocol TableViewSectionProvider {
    var view: TableSectionView { get set }
    
    func registerCells(for tableView: UITableView)
    
    // MARK: - Lifecycle events
    
    func viewWillAppear()
    func viewWillDisappear()

    // MARK: - Cells

    func configure(cell: UITableViewCell, for item: TableItem, at index: UInt)

    // MARK: - Behaviour

    func willDisplay(cell: UITableViewCell, item: TableItem, at index: UInt)
    func didEndDiplaying(cell: UITableViewCell, item: TableItem, at index: UInt)
}

extension TableViewSectionProvider {
    // MARK: - Lifecycle events
    func viewWillAppear() {}
    func viewWillDisappear() {}
    
    func willDisplay(cell: UITableViewCell, item: TableItem, at index: UInt) {}
    func didEndDiplaying(cell: UITableViewCell, item: TableItem, at index: UInt) {}
}


