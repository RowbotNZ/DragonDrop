//
//  DetailViewController.swift
//  DragonDrop
//
//  Created by Rowan on 19/08/17.
//  Copyright © 2017 Rowan Livingstone. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: class {
    func detailViewController(_: DetailViewController, didUpdate dataSource: [DisplayItemConvertible])
}

class DetailViewController: UIViewController {
    
    static let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dropContainerView: UIView!
    
    var dataSource = [DisplayItemConvertible]()
    weak var delegate: DetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: String(describing: PerfectCell.self), bundle: nil), forCellWithReuseIdentifier: DetailViewController.cellReuseIdentifier)
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        //Set up drop interaction for deletion
        let dropInteraction = UIDropInteraction(delegate: self)
        dropContainerView.addInteraction(dropInteraction)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dropContainerView.layer.cornerRadius = 0.5 * dropContainerView.bounds.size.width
        dropContainerView.layer.masksToBounds = true
    }
    
}

extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailViewController.cellReuseIdentifier, for: indexPath) as! PerfectCell
        
        let displayItem = dataSource[indexPath.item].displayItem
        
        switch displayItem {
        case .placeholder:
            cell.activityIndicator.startAnimating()
        case .plain(let title, let detail, let color):
            cell.titleLabel.text = title
            cell.detailLabel.text = detail
            cell.contentView.backgroundColor = color
        case .image(let image):
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            cell.backgroundView = imageView
        }
        
        return cell
    }
    
}

extension DetailViewController: UICollectionViewDelegate {
    
    
    
}

extension DetailViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let draggable = dataSource[indexPath.item] as? Draggable else { return [] }
        return [draggable.dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        guard let draggable = dataSource[indexPath.item] as? Draggable else { return [] }
        return [draggable.dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        dropContainerView.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        dropContainerView.isHidden = true
    }
    
}

extension DetailViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        collectionView.performBatchUpdates({
            for item in coordinator.items {
                if let localObject = item.dragItem.localObject as AnyObject as? DisplayItemConvertible {
                    if let sourceIndexPath = item.sourceIndexPath {
                        dataSource.remove(at: sourceIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                    }
                    
                    dataSource.insert(localObject, at: destinationIndexPath.item)
                    collectionView.insertItems(at: [destinationIndexPath])
                    
                    delegate?.detailViewController(self, didUpdate: dataSource)
                }
                else {
                    let handledTypes: [NSItemProviderReading.Type] = [UIImage.self, CustomModel.self]
                    for handledType in handledTypes {
                        if item.dragItem.itemProvider.canLoadObject(ofClass: handledType) {
                            struct PlaceholderModel: DisplayItemConvertible { }
                            dataSource.insert(PlaceholderModel(), at: destinationIndexPath.item)
                            collectionView.insertItems(at: [destinationIndexPath])
                            
                            item.dragItem.itemProvider.loadObject(ofClass: handledType, completionHandler: { (object, error) in
                                DispatchQueue.main.async {
                                    collectionView.performBatchUpdates({
                                        self.dataSource.remove(at: destinationIndexPath.item)
                                        collectionView.deleteItems(at: [destinationIndexPath])
                                        
                                        if let image = object as? UIImage {
                                            self.dataSource.insert(ImageModel(image: image), at: destinationIndexPath.item)
                                            collectionView.insertItems(at: [destinationIndexPath])
                                            
                                            self.delegate?.detailViewController(self, didUpdate: self.dataSource)
                                        }
                                        else if let customModel = object as? CustomModel {
                                            self.dataSource.insert(customModel, at: destinationIndexPath.item)
                                            collectionView.insertItems(at: [destinationIndexPath])
                                            
                                            self.delegate?.detailViewController(self, didUpdate: self.dataSource)
                                        }
                                    })
                                }
                            })
                            
                            break
                        }
                    }
                }
            }
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
}

extension DetailViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        dropContainerView.backgroundColor = UIColor.red.adjusted(withLightnessFactor: 0.75)
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        dropContainerView.backgroundColor = .red
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        collectionView.performBatchUpdates({
            for item in session.items {
                guard let localObject = item.localObject else { continue }
                guard let dataSourceObject = localObject as AnyObject as? DisplayItemConvertible else { continue }
                guard let index = dataSource.index(where: { $0.displayItem == dataSourceObject.displayItem }) else { continue }
                
                dataSource.remove(at: index)
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                
                delegate?.detailViewController(self, didUpdate: dataSource)
            }
        }, completion: nil)
    }
    
}
