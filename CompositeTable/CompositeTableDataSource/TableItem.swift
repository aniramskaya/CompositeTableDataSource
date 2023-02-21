//
//  TableItem.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 17.02.2023.
//

import Foundation

protocol TableItem {
    var id: String { get }
    var cellReuseIdentifier: String { get }
}
