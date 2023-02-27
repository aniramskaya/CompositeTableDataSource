//
//  CompositeTableDataSource.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 17.02.2023.
//

import UIKit

public class CompositeTableDataSource: NSObject {
    private struct TableSectionData {
        var id: String
        var providerIndex: Int
        var items: [TableItem]
    }

    private var tableView: UITableView
    private var snapshot: [TableSectionData] = []

    public private (set) var sectionProviders: [TableViewSectionProvider] = []

    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - View lifecycle support
     
    public func reloadIfNeeded() {
        sectionProviders.forEach { $0.reloadIfNeeded() }
    }
    
    // MARK: - Public

    func setSectionProviders(_ providers: [TableViewSectionProvider]) {
        attach(providers: providers)
    }

    // MARK: - Private
    
    private var tableReloadOperation: BlockOperation?
    // TODO: Поставить защиту от непредвиденных ситуаций когда этот метод вызывается off-screen. Надо ли?
    private func requestRefresh() {
        guard tableReloadOperation == nil else { return }
        let operation = BlockOperation {
            self.reloadTable()
            self.tableReloadOperation = nil
        }
        tableReloadOperation = operation
        OperationQueue.main.addOperation(operation)
    }
    
    private func reloadTable() {
        let newSnapshot = makeSnapshot()
        if snapshot.isEmpty {
            snapshot = newSnapshot
            tableView.reloadData()
        } else {
            applySnapshot(newSnapshot, animatingWith: .fade)
        }
    }
    
    private func changes<T: Equatable>(old: [T], new: [T]) -> (removals: IndexSet, insertions: IndexSet) {
        var sectionsToDelete = IndexSet()
        var sectionsToInsert = IndexSet()
        let sectionDiff = new.difference(from: old)
        for change in sectionDiff {
            switch change {
            case let .remove(offset: offset, element: _, associatedWith: _):
                sectionsToDelete.insert(offset)
            case let .insert(offset: offset, element: _, associatedWith: _):
                sectionsToInsert.insert(offset)
            }
        }
        return (sectionsToDelete, sectionsToInsert)
    }
    
    private func firstDuplicate<T: Hashable>(_ array: [T]) -> T? {
        var counts: [T: Int] = [:]
        for item in array {
            counts[item] = (counts[item] ?? 0)  + 1
        }
        return counts.first { $1 > 1 }?.key
    }
    
    private func applySnapshot(_ new: [TableSectionData], animatingWith animation: UITableView.RowAnimation) {
        let old = snapshot
        
        let oldSectionIds = old.map { $0.id }
        let newSectionIds = new.map { $0.id }
        
        if let duplicate = firstDuplicate(newSectionIds) {
            let message = "CompositeTableDataSource detected duplicate section identifier \"\(duplicate)\". Section identifiers must be unique."
            fatalError(message)
        }
        
        let (sectionsToDelete, sectionsToInsert) = changes(old: oldSectionIds, new: newSectionIds)
        
        let intactOldSections = (0..<old.count).compactMap { sectionsToDelete.contains($0) ? nil : $0 }
        let intactNewSections = (0..<new.count).compactMap { sectionsToInsert.contains($0) ? nil : $0 }
        
        var rowsToDelete: [IndexPath] = []
        var rowsToInsert: [IndexPath] = []
        for section in 0..<intactOldSections.count {
            let oldSectionIndex = intactOldSections[section]
            let newSectionIndex = intactNewSections[section]
            let oldItems = old[oldSectionIndex].items.map { $0.id }
            let newItems = new[newSectionIndex].items.map { $0.id }
            
            if let duplicate = firstDuplicate(newItems) {
                fatalError("CompositeTableDataSource detected duplicate row identifier \"\(duplicate)\" in section \(newSectionIndex). Row identifiers must be unique within section.")
            }

            let (removals, insertions) = changes(old: oldItems, new: newItems)
            rowsToDelete.append(contentsOf: removals.map { IndexPath(row: $0, section: oldSectionIndex) })
            rowsToInsert.append(contentsOf: insertions.map { IndexPath(row: $0, section: newSectionIndex) })
        }
        
        
        tableView.performBatchUpdates(
            {
                snapshot = new
                tableView.deleteRows(at: rowsToDelete, with: animation)
                tableView.deleteSections(sectionsToDelete, with: animation)
                tableView.insertSections(sectionsToInsert, with: animation)
                tableView.insertRows(at: rowsToInsert, with: animation)
            }) { _ in
                guard let visibleRows = self.tableView.indexPathsForVisibleRows else { return }
                if #available(iOS 15.0, *) {
                    self.tableView.reconfigureRows(at: visibleRows)
                } else {
                    self.tableView.reloadRows(at: visibleRows, with: .none)
                }
            }
    }
    
    private func makeSnapshot() -> [TableSectionData] {
        var result: [TableSectionData] = []
        sectionProviders.enumerated().forEach { index, provider in
            guard provider.isVisible else { return }
            result.append(TableSectionData(id: provider.id, providerIndex: index, items: provider.cellItems))
        }
        return result
    }
    
    private func attach(providers: [TableViewSectionProvider]) {
        var oldProviders = sectionProviders
        var newProviders = providers
        let oldProvidersIds = oldProviders.map { $0.id }
        let newProvidersIds = newProviders.map { $0.id }

        func attach(_ provider: inout TableViewSectionProvider) {
            provider.onNeedsDisplay = { [weak self] in
                self?.requestRefresh()
            }
            provider.registerCells(for: tableView)
        }
        
        func detach(_ provider: inout TableViewSectionProvider) {
            provider.onNeedsDisplay = nil
            provider.unregisterCells(for: tableView)
        }
        
        let diff = newProvidersIds.difference(from: oldProvidersIds)
        for change in diff {
            switch change {
            case let .insert(offset: offset, element: _, associatedWith: _):
                attach(&newProviders[offset])
            case let .remove(offset: offset, element: _, associatedWith: _):
                detach(&oldProviders[offset])
            }
        }
        sectionProviders = providers
        snapshot = []
        requestRefresh()
    }
}

extension CompositeTableDataSource: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        snapshot.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        snapshot[section].items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = snapshot[indexPath.section]
        let item = section.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellReuseIdentifier, for: indexPath)
        sectionProviders[section.providerIndex].configure(cell: cell, for: item, at: indexPath.row)
        return cell
    }
}

extension CompositeTableDataSource: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let providerIndex = snapshot[section].providerIndex
        return sectionProviders[providerIndex].headerView == nil ? CGFloat.ulpOfOne : UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let providerIndex = snapshot[section].providerIndex
        return sectionProviders[providerIndex].headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let providerIndex = snapshot[section].providerIndex
        return sectionProviders[providerIndex].footerView == nil ? CGFloat.ulpOfOne : UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let providerIndex = snapshot[section].providerIndex
        return sectionProviders[providerIndex].footerView
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let providerIndex = snapshot[indexPath.section].providerIndex
        guard let eventListener = sectionProviders[providerIndex] as? TableViewCellDisplayEvents else { return }
        let item = snapshot[indexPath.section].items[indexPath.row]
        eventListener.willDisplay(cell: cell, item: item, at: indexPath.row)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let providerIndex = snapshot[indexPath.section].providerIndex
        guard let eventListener = sectionProviders[providerIndex] as? TableViewCellDisplayEvents else { return }
        guard indexPath.section < snapshot.count else { return }
        let section = snapshot[indexPath.section]
        guard indexPath.row < section.items.count else { return }
        let item = section.items[indexPath.row]
        eventListener.didEndDiplaying(cell: cell, item: item, at: indexPath.row)
    }
}
