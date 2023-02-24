//
//  TableViewCellRegistration.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 22.02.2023.
//

import UIKit

public protocol TableViewCellRegistration {
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String)
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
}

extension UITableView: TableViewCellRegistration {}
