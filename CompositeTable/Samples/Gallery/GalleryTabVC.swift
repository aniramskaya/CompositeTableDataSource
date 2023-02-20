//
//  GalleryTabVC.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 20.02.2023.
//

import UIKit

class GalleryTabVC: UIViewController {
    @IBOutlet var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let galleryVC = GalleryViewController.loadFromNib()
        galleryVC.items = [1,2,3,4,5,6,7,8,9,10]
        galleryVC.cellColor = .yellow
        addChild(galleryVC)
        galleryVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(galleryVC.view)
        NSLayoutConstraint.activate([
            galleryVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            galleryVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            galleryVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            galleryVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        galleryVC.didMove(toParent: self)
    }
}
