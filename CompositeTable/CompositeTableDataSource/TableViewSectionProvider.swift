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
    
    func registerCells(for context: TableViewCellRegistration)
    func viewWillAppear()
    func viewWillDisappear()

    // MARK: - Cells

    func configure(cell: UITableViewCell, for item: TableItem, at index: Int)
}

extension TableViewSectionProvider {
    // MARK: - Lifecycle events
    func viewWillAppear() {}
    func viewWillDisappear() {}
}

protocol TableViewCellDisplayEvents {
    func willDisplay(cell: UITableViewCell, item: TableItem, at index: Int)
    func didEndDiplaying(cell: UITableViewCell, item: TableItem, at index: Int)
}

extension TableViewCellDisplayEvents {
    func willDisplay(cell: UITableViewCell, item: TableItem, at index: Int) {}
    func didEndDiplaying(cell: UITableViewCell, item: TableItem, at index: Int) {}
}
