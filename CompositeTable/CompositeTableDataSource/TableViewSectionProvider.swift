//
//  TableSectionDataSource.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 15.02.2023.
//

import UIKit

/// Провайдер секции таблицы, используемый в `CompositeTableDataSource` для разделения работы разных поставщиков данных.
/// `TableViewSectionProvider` можно рассматривать как View в архитектурных паттернах или как ViewController в терминах UIKit.
protocol TableViewSectionProvider {
    /// Идентификатор секции таблицы. Должен быть уникальным в пределах таблицы.
    var id: String { get }
    
    // MARK: - Display controls
    /// Флаг, отвечающий за отображение секции этого провайдера на экране. При назначении этому свойству значения `false` секция перестает отображатьс на экране. Сам провайдер при этом остается в составе `CompositeTableDataSource` и продолжает получать вызовы `reloadIfNeeded`.
    var isVisible: Bool { get }
    /// Элементы, которые должны отображаться на экране.
    var cellItems: [TableItem] { get }
    /// Заголовок секции
    var headerView: UIView?  { get }
    /// Футер секции
    var footerView: UIView? { get }

    /// Замыкание, которое должно вызываться сразу после изменения свойства `cellItems` для того чтобы `CompositeTableDataSource` обновил информацию на экране.
    ///
    /// Промедление в вызове этого замыкания недопустимо, так как `CompositeTableDataSource` хранит снимок данных таблицы и при несовпадении типов или количества элементов в снимке и `cellItems` вероятнее всего случится краш,
    ///
    /// После изменения свойств `isVisible`, `cellItems`, `headerView`, `footerView` также желательно вызывать `onNeedsDisplay`, но промедление в этом случае не приведет к крашу.
    var onNeedsDisplay: (() -> Void)? { get set }

    // MARK: - Lifecycle events
    
    /// В реализации этого метода необходимо зарегистрировать ячейки с их reuseIdentifier.
    ///
    /// Вызывается в момент присоединения провайдера к `CompositeTableDataSource`. К моменту вызова этого метода `onNeedsDisplay` уже назначен и его можно вызывать сразу после регистрации ячеек таблицы.
    /// Можно рассматривать этот метод как аналог `viewDidLoad` у `ViewController`
    func registerCells(for context: TableViewCellRegistration)
    /// В реализации этого метода можно удалить зарегистрированные ячейки
    ///
    /// Вызывается в момент отсоединения провайдера от `CompositeTableDataSource`. К моменту вызова этого метода `onNeedsDisplay` уже равен `nil`
    /// Можно рассматривать этот метод как аналог `viewDidUnoad` у `ViewController` (этого метода у него сейчас нет, но был когда-то)
    func unregisterCells(for context: TableViewCellRegistration)
    /// Вызов этого метода сообщает провайдеру, что он может обновить свои данные.
    ///
    /// Можно рассматривать этот метод как аналог `ViewWillAppear` у `UIViewController`
    func reloadIfNeeded()

    // MARK: - Cells
    
    /// Реализация этого метода должна сконфигурировать переданную в параметре ячейку
    ///
    /// Ячейки создаются самим `CompositeTableDataSource` с использованием `reuseIdentifier`-а, который берется из `TableItem`
    func configure(cell: UITableViewCell, for item: TableItem, at index: Int)
}

extension TableViewSectionProvider {
    // MARK: - Lifecycle events
    func reloadIfNeeded() {}
    func unregisterCells(for context: TableViewCellRegistration) {}
}

protocol TableViewCellDisplayEvents {
    func willDisplay(cell: UITableViewCell, item: TableItem, at index: Int)
    func didEndDiplaying(cell: UITableViewCell, item: TableItem, at index: Int)
}

extension TableViewCellDisplayEvents {
    func willDisplay(cell: UITableViewCell, item: TableItem, at index: Int) {}
    func didEndDiplaying(cell: UITableViewCell, item: TableItem, at index: Int) {}
}
