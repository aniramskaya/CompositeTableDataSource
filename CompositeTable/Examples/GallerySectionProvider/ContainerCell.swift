//
//  ContainerCell.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 20.02.2023.
//

import UIKit

class ContainerCell: UITableViewCell {
    private var embeddedVC: UIViewController?

    func embed(viewController: UIViewController) {
        if embeddedVC != nil && embeddedVC !== viewController {
            embeddedVC?.view.removeFromSuperview()
        }
        embeddedVC = viewController
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
