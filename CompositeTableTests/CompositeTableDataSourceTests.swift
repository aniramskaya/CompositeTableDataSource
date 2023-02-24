//
//  CompositeTableTests.swift
//  CompositeTableTests
//
//  Created by Марина Чемезова on 05.02.2023.
//

import XCTest
import UIKit
@testable import CompositeTable

final class CompositeTableDataSourceTests: XCTestCase {
    func test_tableView_StaysEmptyWhenDataSourceHasNoProviders() throws {
        let tableView = UITableView()
        let _ = CompositeTableDataSource(tableView: tableView)
        
        XCTAssertEqual(tableView.numberOfSections, 0)
    }
    
    func test_dataSource_CallsRegisterCellsOnProviderAttached() throws {
        let (_, sut) = makeSUT()
        let provider = TestSectionProvider(id: uniqueString())
        
        sut.setSectionProviders([provider])
        
        XCTAssertEqual(provider.messages, [.registerCells])
    }
    
    func test_dataSource_CallsUnregisterCellsOnProviderDetached() throws {
        let (_, sut) = makeSUT()
        let provider = TestSectionProvider(id: uniqueString())
        
        sut.setSectionProviders([provider])
        sut.setSectionProviders([])

        XCTAssertEqual(provider.messages, [.registerCells, .unregisterCells])
    }
    
    // MARK: - Private
    
    private func makeSUT() -> (UITableView, CompositeTableDataSource) {
        let tableView = UITableView()
        let sut = CompositeTableDataSource(tableView: tableView)
        return (tableView, sut)
    }
    
    private func uniqueString() -> String {
        UUID().uuidString
    }
}

class TestSectionProvider: TableViewSectionProvider {
    var id: String
    
    var isVisible = true
    
    var cellItems: [CompositeTable.TableItem] = []
    
    var headerView: UIView?
    
    var footerView: UIView?
    
    var onNeedsDisplay: (() -> Void)?
    
    let cellReuseIdentifier = "TestCell"
    
    init(id: String) {
        self.id = id
    }
    
    enum Message: Equatable {
        case registerCells
        case unregisterCells
    }
    
    var messages: [Message] = []
    
    func registerCells(for context: CompositeTable.TableViewCellRegistration) {
        messages.append(.registerCells)
        context.register(TestCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    func configure(cell: UITableViewCell, for item: CompositeTable.TableItem, at index: Int) {
        guard let testItem = item as? TestTableItem else { return }
        var content = cell.defaultContentConfiguration()
        content.text = testItem.title
        cell.contentConfiguration = content
    }
    
    func unregisterCells(for context: CompositeTable.TableViewCellRegistration) {
        messages.append(.unregisterCells)
    }
}

class TestCell: UITableViewCell {
    var title: String? {
        (contentConfiguration as? UIListContentConfiguration)?.text
    }
}

struct TestTableItem: CompositeTable.TableItem {
    var id: String
    var cellReuseIdentifier: String
    var title: String
}
