//
//  MemesCollectionViewController.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/07.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCell"

class MemesCollectionViewController: UICollectionViewController {
    
    private let memes = Memes.shared

    @IBAction func dismissPopupViewController(sender: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let collectionView = collectionView {
            updateItemSize(displaySize: collectionView.bounds.size)
            collectionView.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateItemSize(displaySize: size)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func updateItemSize(displaySize: CGSize) {
        guard let collectionView = collectionView else {
            return
        }
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
//        let displaySize = collectionView.bounds.size
        let sectionInset = layout.sectionInset
        let availableWidth = displaySize.width - sectionInset.left - sectionInset.right
        let availableHeight = displaySize.height - sectionInset.top - sectionInset.bottom
        
        let idealSize: CGFloat = min(availableWidth, availableHeight) / 3.0
        
        let numberOfItems = round(availableWidth / idealSize)
        let numberOfSpaces = numberOfItems - 1
        let itemSize = floor((availableWidth - numberOfSpaces) / numberOfItems)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MemeDetailViewController {
            if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
                viewController.meme = memes.meme(at: indexPath.item)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        let meme = memes.meme(at: indexPath.item)
        cell.memeImageView.image = meme.memedImage
        return cell
    }

}
