//
//  GallerySectionProvider.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 20.02.2023.
//

import UIKit

class GallerySectionProvider: TableViewSectionProvider {
    var view: TableSectionView
    
    var galleryViewControllers: [GalleryViewController] = []
    
    init() {
        view = TableSectionView(id: "Galleries")
    }
    
    let cellIdentifier = "ContainerCell"
    func registerCells(for tableView: UITableView) {
        tableView.register(ContainerCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func configure(cell: UITableViewCell, for item: TableItem, at index: UInt) {
        guard let cell = cell as? ContainerCell else { return }
        cell.embed(viewController: galleryViewControllers[Int(index)])
    }
    
    func viewWillAppear() {
        guard galleryViewControllers.isEmpty else { return }
        galleryViewControllers = makeViewControllers()
        view.display(with: galleryViewControllers.map({
            BasicTableItem(id: $0.title!, cellReuseIdentifier: cellIdentifier)
        }))
    }
    
    private func makeViewControllers() -> [GalleryViewController] {
        let vc1 = GalleryViewController.loadFromNib()
        vc1.title = "Gallery 1"
        vc1.items = [1,2,3,4,5,6,7,8,9,10]
        vc1.cellColor = .yellow
        vc1.view.heightAnchor.constraint(equalToConstant: 128).isActive = true
        let vc2 = GalleryViewController.loadFromNib()
        vc2.title = "Gallery 2"
        vc2.items = [11,12,13,14,15,16,17,18,19,20]
        vc2.cellColor = .green
        vc2.view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        let vc3 = GalleryViewController.loadFromNib()
        vc3.title = "Gallery 3"
        vc3.items = [21,22,23,24,25,26,27,28,29,30]
        vc3.cellColor = .blue
        vc3.view.heightAnchor.constraint(equalToConstant: 128).isActive = true
        return [vc1, vc2, vc3]
    }
    
}
