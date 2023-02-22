//
//  TableItem.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 17.02.2023.
//

import Foundation

/// Абстракиный элемент таблицы
protocol TableItem {
    /// Идентификатор элемента. Должен быть уникальным в пределах одной секции таблицы
    var id: String { get }
    /// Идентификатор ячейки, по которому у `UITableView` будет запрашиваться переиспользуемая ячейка
    var cellReuseIdentifier: String { get }
}
