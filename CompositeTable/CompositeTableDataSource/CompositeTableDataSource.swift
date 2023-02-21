//
//  CompositeTableDataSource.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 17.02.2023.
//

import UIKit

class CompositeTableDataSource: NSObject {
    private struct TableSectionData {
        var id: String
        var items: [TableItem]
    }

    private var tableView: UITableView
    private var snapshot: [TableSectionData] = []

    public private (set) var sectionProviders: [TableViewSectionProvider] = []

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - View lifecycle support
     
    func viewWillAppear() {
        sectionProviders.forEach { $0.viewWillAppear() }
    }

    func viewWillDisappear() {
        sectionProviders.forEach { $0.viewWillDisappear() }
    }

    
    // MARK: - Private
    
    var tableReloadOperation: BlockOperation?
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
        print("Starting reload data")
        printFirstSectionDiff()
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
        for section in intactOldSections {
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
        
        snapshot = new
        
        tableView.performBatchUpdates {
            tableView.deleteRows(at: rowsToDelete, with: animation)
            tableView.deleteSections(sectionsToDelete, with: animation)
            tableView.insertSections(sectionsToInsert, with: animation)
            tableView.insertRows(at: rowsToInsert, with: animation)
        }
    }
    
    private func printFirstSectionDiff() {
        guard !snapshot.isEmpty, !sectionProviders.isEmpty else { return }
        let oldIds = snapshot[0].items.map { $0.id }
        let newIds = sectionProviders[0].cellItems.map { $0.id }
        print(oldIds)
        print(newIds)
        print(newIds.difference(from: oldIds))
    }
    
    private func makeSnapshot() -> [TableSectionData] {
        return sectionProviders.compactMap { (provider) -> TableSectionData? in
            guard provider.isVisible else { return nil }
            return TableSectionData(id: provider.id, items: provider.cellItems)
        }
    }
    
    private func attachingOnNeedsDisplay(_ providers: [TableViewSectionProvider]) -> [TableViewSectionProvider] {
        providers.map {
            var provider = $0
            provider.registerCells(for: tableView)
            provider.onNeedsDisplay = { [weak self] in
                self?.requestRefresh()
            }
            return provider
        }
    }
}

extension CompositeTableDataSource: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func setSectionProviders(_ providers: [TableViewSectionProvider]) {
        sectionProviders = attachingOnNeedsDisplay(providers)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        snapshot.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        snapshot[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = snapshot[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellReuseIdentifier, for: indexPath)
        sectionProviders[indexPath.section].configure(cell: cell, for: item, at: UInt(indexPath.row))
        return cell
    }
}

extension CompositeTableDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionProviders[section].headerView == nil ? CGFloat.ulpOfOne : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionProviders[section].headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionProviders[section].footerView == nil ? CGFloat.ulpOfOne : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionProviders[section].footerView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = snapshot[indexPath.section].items[indexPath.row]
        sectionProviders[indexPath.section].willDisplay(cell: cell, item: item, at: UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section < snapshot.count else { return }
        let section = snapshot[indexPath.section]
        guard indexPath.row < section.items.count else { return }
        let item = section.items[indexPath.row]
        sectionProviders[indexPath.section].didEndDiplaying(cell: cell, item: item, at: UInt(indexPath.row))
    }
}
