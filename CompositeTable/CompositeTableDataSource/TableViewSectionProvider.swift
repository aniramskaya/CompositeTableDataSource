//
//  TableSectionDataSource.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 15.02.2023.
//

import UIKit

protocol TableViewSectionProvider {
    var id: String { get }
    var isVisible: Bool { get }
    var cellItems: [TableItem] { get }
    var headerView: UIView?  { get }
    var footerView: UIView? { get }

    var onNeedsDisplay: (() -> Void)? { get set }

    // MARK: - Lifecycle events
    
    func registerCells(for tableView: UITableView)
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
    
    // MARK: - Behaviour
    func willDisplay(cell: UITableViewCell, item: TableItem, at index: UInt) {}
    func didEndDiplaying(cell: UITableViewCell, item: TableItem, at index: UInt) {}
}


