//
//  GalleryViewController.swift
//  CompositeTable
//
//  Created by Марина Чемезова on 20.02.2023.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
}

class GalleryViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var items: [Int] = [] {
        didSet {
            guard isViewLoaded else { return }
            collectionView.reloadData()
        }
    }
    var cellColor: UIColor = .white
    
    let cellIdentifier = "GalleryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
    }
    
    private func registerCells() {
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    static func loadFromNib() -> GalleryViewController {
        return GalleryViewController(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell
        cell.titleLabel.text = String(describing: items[indexPath.item])
        cell.backgroundColor = cellColor
        return cell
    }
}
