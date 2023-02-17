//
//  TableSectionView.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 17.02.2023.
//

import UIKit

class TableSectionView {
    var id: String = ""
    var isDisplaying: Bool = true
    var items: [TableItem] = []
    var headerView: UIView?
    var footerView: UIView?

    var onNeedsDisplay: (() -> Void)?
    
    init(id: String) {
        self.id = id
    }

    func display(with items: [TableItem]) {
        isDisplaying = true
        self.items = items
        onNeedsDisplay?()
    }
    
    func hide() {
        isDisplaying = false
        onNeedsDisplay?()
    }
}
