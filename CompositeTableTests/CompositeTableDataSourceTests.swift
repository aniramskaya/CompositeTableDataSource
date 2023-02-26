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
        let section = makeTestSection(rowCount: 3, headerTitle: uniqueString(), footerTitle: uniqueString())

        let provider = makeProvider(section)
        sut.setSectionProviders([provider])
        waitForAnimations()

        expectSection(atIndex: 0, in: tableView, toMatch: section)
    }

    func test_dataSource_rendersAllSectionsOnProviderListAttachment() throws {
        let (tableView, sut) = makeSUT()
        let sections = makeTestSections(sectionCount: 3)
        let providers = makeProviders(sections)
        
        sut.setSectionProviders(providers)
        waitForAnimations()

        expectSections(sections, match: tableView)
    }
    
    func test_dataSource_replacesSectionOnProviderReplacement() throws {
        let (tableView, sut) = makeSUT()

        var sections = makeTestSections(sectionCount: 3)
        var providers = makeProviders(sections)
        
        sut.setSectionProviders(providers)
        waitForAnimations()

        expectSections(sections, match: tableView)

        sections[1] = makeTestSection(rowCount: 3, headerTitle: uniqueString(), footerTitle: uniqueString())
        providers[1] = makeProvider(sections[1])

        sut.setSectionProviders(providers)
        waitForAnimations()

        expectSections(sections, match: tableView)
    }

    func test_dataSource_changesSectionsAccordingToProvidersChanges() throws {
        let (tableView, sut) = makeSUT()

        var sections = makeTestSections(sectionCount: 3)
        let providers = makeProviders(sections)
        
        sut.setSectionProviders(providers)
        waitForAnimations()

        expectSections(sections, match: tableView)

        // remove header and footer for the first section
        sections[0].headerTitle = nil
        sections[0].footerTitle = nil
        updateProvider(providers[0], with: sections[0])
        
        // remove one item and append two in the third section
        sections[2].items.remove(at: 1)
        sections[2].items.insert(TestTableItem(id: uniqueString(), cellReuseIdentifier: TestSectionProvider.cellReuseIdentifier, title: uniqueString()), at: 0)
        sections[2].items.append(TestTableItem(id: uniqueString(), cellReuseIdentifier: TestSectionProvider.cellReuseIdentifier, title: uniqueString()))
        updateProvider(providers[2], with: sections[2])

        // hide the second section
        sections.remove(at: 1)
        updateProvider(providers[1], with: nil)
        

        waitForAnimations()

        expectSections(sections, match: tableView)
    }
    
    func test_dataSource_ProviderOnNeedsDisplayMultipleCallsDoesNotLeadToMultipleTableReloads() throws {
        let (tableView, sut) = makeSUT()
        let section = makeTestSection(rowCount: 3, headerTitle: uniqueString(), footerTitle: uniqueString())

        let provider = makeProvider(section)
        sut.setSectionProviders([provider])
        waitForAnimations()

        let tableUpdateCallCount = tableView.reloadDataCallCount + tableView.performBatchUpdatesCallCount
        provider.onNeedsDisplay?()
        provider.onNeedsDisplay?()
        waitForAnimations()
        
        XCTAssertEqual(tableView.reloadDataCallCount + tableView.performBatchUpdatesCallCount, tableUpdateCallCount + 1)
    }
    
    // MARK: - Private
    
    private func waitForAnimations() {
        RunLoop.main.run(until: Date() + 0.01)
    }
    
    private func expectSections(_ sections: [TestSection], match tableView: UITableView, file: StaticString = #filePath, line: UInt = #line) {
        sections.enumerated().forEach { index, section in
            expectSection(atIndex: index, in: tableView, toMatch: section, file: file, line: line)
        }
    }
    
    private func expectSection(atIndex index: Int, in tableView: UITableView, toMatch section: TestSection, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: index), section.items.count, "Section row count mismatch", file: file, line: line)
        for cellIndex in 0..<section.items.count {
            let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: cellIndex, section: index))
            guard let testCell = cell as? TestCell
            else {
                XCTFail("Expected cell to be TestCell found \(type(of: cell)) at index \(cellIndex) in section \(index)", file: file, line: line)
                return
            }
            XCTAssertEqual(testCell.title, section.items[cellIndex].title, "Expected row \(section.items[cellIndex].title) found \(testCell.title ?? "nil") at index \(cellIndex) in section \(index)", file: file, line: line)
        }
        
        let headerTitle = (tableView.delegate?.tableView?(tableView, viewForHeaderInSection: index) as? TestHeaderFooter)?.title
        XCTAssertEqual(headerTitle, section.headerTitle, "Section header title at \(index)", file: file, line: line)
        let footerTitle = (tableView.delegate?.tableView?(tableView, viewForFooterInSection: index) as? TestHeaderFooter)?.title
        XCTAssertEqual(footerTitle, section.footerTitle, "Section footer title at \(index)", file: file, line: line)
    }
    
    private func updateProvider(_ provider: TestSectionProvider, with section: TestSection?) {
        guard let section else {
            provider.isVisible = false
            return
        }
        provider.cellItems = section.items
        if let headerTitle = section.headerTitle {
            let headerView = TestHeaderFooter()
            headerView.titleLabel.text = headerTitle
            provider.headerView = headerView
        } else {
            provider.headerView = nil
        }
        if let footerTitle = section.footerTitle {
            let footerView = TestHeaderFooter()
            footerView.titleLabel.text = footerTitle
            provider.footerView = footerView
        } else {
            provider.footerView = nil
        }
        provider.onNeedsDisplay?()
    }
    
    private func makeProviders(_ sections: [TestSection]) -> [TestSectionProvider] {
        sections.map { makeProvider($0) }
    }
    
    private func makeProvider(_ section: TestSection) -> TestSectionProvider {
        let provider = TestSectionProvider(id: section.id)
        if let headerTitle = section.headerTitle {
            let headerView = TestHeaderFooter()
            headerView.titleLabel.text = headerTitle
            provider.headerView = headerView
        }
        if let footerTitle = section.footerTitle {
            let footerView = TestHeaderFooter()
            footerView.titleLabel.text = footerTitle
            provider.footerView = footerView
        }
        provider.cellItems = section.items
        return provider
    }
    
    private func makeTestSections(sectionCount: Int, rowCount: Int = 3) -> [TestSection] {
        (0..<sectionCount).map { _ in
            makeTestSection(rowCount: rowCount, headerTitle: uniqueString(), footerTitle: uniqueString())
        }
    }
    
    private func makeTestSection(rowCount: Int = 1, headerTitle: String? = nil, footerTitle: String? = nil ) -> TestSection {
        return TestSection(
            id: uniqueString(),
            items: (0..<rowCount).map {
                TestTableItem(id: uniqueString(), cellReuseIdentifier: TestSectionProvider.cellReuseIdentifier, title: "\($0)")
                
            },
            headerTitle: headerTitle,
            footerTitle: footerTitle
        )
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (TestTableView, CompositeTableDataSource) {
        let tableView = TestTableView()
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

class TestTableView: UITableView {
    var reloadDataCallCount = 0
    override func reloadData() {
        reloadDataCallCount += 1
        super.reloadData()
    }

    var performBatchUpdatesCallCount = 0
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdatesCallCount += 1
        super.performBatchUpdates(updates, completion: completion)
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
    let id: String
    var items: [TestTableItem]
    var headerTitle: String?
    var footerTitle: String?
}

class TestHeaderFooter: UIView {
    var titleLabel = UILabel()
}

extension TestHeaderFooter {
    var title: String? { titleLabel.text }
}
