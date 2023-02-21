//
//  SimpleTableCell.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 15.02.2023.
//

import UIKit

class SimpleTableCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleHeightConstraint: NSLayoutConstraint!
    
    func toggleHeight() {
        titleHeightConstraint.isActive.toggle()
    }
}
