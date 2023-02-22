//
//  GallerySectionProvider.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 20.02.2023.
//

import UIKit

class GallerySectionProvider: TableViewSectionProvider {
    let id: String
    private(set) var isVisible = true
    private(set) var cellItems: [TableItem] = []
    private(set) var headerView: UIView?
    private(set) var footerView: UIView?
    
    var onNeedsDisplay: (() -> Void)?
    
    var galleryViewControllers: [GalleryViewController] = []
    
    init(id: String) {
        self.id = id
    }
    
    // MARK: - Lifecycle

    let cellIdentifier = "ContainerCell"
    func registerCells(for context: TableViewCellRegistration) {
        context.register(ContainerCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func viewWillAppear() {
        guard galleryViewControllers.isEmpty else { return }
        galleryViewControllers = makeViewControllers()
        display(galleryViewControllers.map({
            BasicTableItem(id: $0.title!, cellReuseIdentifier: cellIdentifier)
        }))
    }

    // MARK: - Cells
    
    func configure(cell: UITableViewCell, for item: TableItem, at index: Int) {
        guard let cell = cell as? ContainerCell else { return }
        cell.embed(viewController: galleryViewControllers[Int(index)])
    }
    
    // MARK: - Public API
    
    func toggleFirstCellHeight() {
        guard let height = findHeightConstraint(in: galleryViewControllers[0].view) else { return }
        height.constant = height.constant >= 200 ? 128 : 200
        onNeedsDisplay?()
    }
    
    // MARK: - Private
    
    private func display(_ items: [TableItem]) {
        self.cellItems = items
        isVisible = true
        onNeedsDisplay?()
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
    
    private func findHeightConstraint(in view: UIView) -> NSLayoutConstraint? {
        view.constraints.first { $0.firstAttribute == .height }
    }
    
}
