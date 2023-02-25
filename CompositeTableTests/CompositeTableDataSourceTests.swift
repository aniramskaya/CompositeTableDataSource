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
        let (tableView, sut) = makeSUT()

        XCTAssertEqual(sut.numberOfSections(in: tableView), 0)
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

    func test_dataSource_CallsReloadIfNeededOnViewWillAppearCall() throws {
        let (_, sut) = makeSUT()
        let provider1 = TestSectionProvider(id: uniqueString())
        let provider2 = TestSectionProvider(id: uniqueString())
        
        sut.setSectionProviders([provider1, provider2])
        sut.viewWillAppear()

        XCTAssertEqual(provider1.messages, [.registerCells, .reloadIfNeeded])
        XCTAssertEqual(provider2.messages, [.registerCells, .reloadIfNeeded])
    }
    
    func test_dataSource_rendersSectionOnProviderAttachment() throws {
        let (tableView, sut) = makeSUT()
        let provider = TestSectionProvider(id: uniqueString())
        let section = makeTestSection(rowCount: 3)

        provider.cellItems = section.items
        sut.setSectionProviders([provider])
        RunLoop.main.run(until: Date() + 0.5)

        expectSection(atIndex: 0, in: tableView, matches: section)
    }

    // MARK: - Private
    
    private func expectSection(atIndex index: Int, in tableView: UITableView, matches section: TestSection, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: index), section.items.count, "Section row count mismatch")
        for cellIndex in 0..<section.items.count {
            let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: cellIndex, section: index))
            guard let testCell = cell as? TestCell
            else {
                XCTFail("Expected cell to be TestCell found \(type(of: cell))")
                return
            }
            XCTAssertEqual(testCell.title, section.items[cellIndex].title, "Expected row \(section.items[cellIndex].title) found \(testCell.title ?? "nil") at index \(cellIndex)")
        }
    }
    
    private func makeTestSection(rowCount: Int = 1, headerTitle: String? = nil, footerTitle: String? = nil ) -> TestSection {
        return TestSection(
            items: (0..<rowCount).map {
                TestTableItem(id: UUID().uuidString, cellReuseIdentifier: TestSectionProvider.cellReuseIdentifier, title: "\($0)")
                
            },
            headerTitle: headerTitle,
            footerTitle: footerTitle
        )
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (UITableView, CompositeTableDataSource) {
        let tableView = UITableView()
        let sut = CompositeTableDataSource(tableView: tableView)
        addTeardownBlock { [weak sut] in
            RunLoop.main.run(until: Date() + 0.5)
            XCTAssertNil(sut, file: file, line: line)
        }
        return (tableView, sut)
    }
    
    private func uniqueString() -> String {
        UUID().uuidString
    }
}

class TestViewController: UITableViewController {
    var dataSource: CompositeTableDataSource?
}

class TestSectionProvider: TableViewSectionProvider {
    var id: String
    
    var isVisible = true
    
    var cellItems: [CompositeTable.TableItem] = []
    
    var headerView: UIView?
    
    var footerView: UIView?
    
    var onNeedsDisplay: (() -> Void)?
    
    static let cellReuseIdentifier = "TestCell"
    
    init(id: String) {
        self.id = id
    }
    
    enum Message: Equatable {
        case registerCells
        case unregisterCells
        case reloadIfNeeded
    }
    
    var messages: [Message] = []
    
    func registerCells(for context: CompositeTable.TableViewCellRegistration) {
        messages.append(.registerCells)
        context.register(TestCell.self, forCellReuseIdentifier: Self.cellReuseIdentifier)
    }
    
    func reloadIfNeeded() {
        messages.append(.reloadIfNeeded)
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

struct TestSection {
    let items: [TestTableItem]
    let headerTitle: String?
    let footerTitle: String?
}

class TestHeaderFooter: UIView {
    var titleLabel = UILabel()
}

extension TestHeaderFooter {
    var title: String? { titleLabel.text }
}
