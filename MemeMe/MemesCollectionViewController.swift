//
//  MemesCollectionViewController.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/07.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Display list of memes in a grid layout.
//

import UIKit

private let reuseIdentifier = "MemeCell"

class MemesCollectionViewController: UICollectionViewController {
    
    // Access the share model.
    private let memes = Memes.shared

    //
    //  Action called by the unwind segue on the meme editor view controller. This function does not do anything, but
    //  exists so that the app knows where to unwind to.
    //
    @IBAction func dismissPopupViewController(sender: UIStoryboardSegue) {
        
    }
    
    
    
    //
    // MARK: View life cycle
    //
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let collectionView = collectionView {
            updateItemSize(displaySize: collectionView.bounds.size)
            collectionView.reloadData()
        }
        
        updateEmptyContent()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateItemSize(displaySize: size)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    
    //
    // MARK: User interface
    //
    
    //
    //  Show content placeholder view if memes list is empty.
    //
    private func updateEmptyContent() {
        if memes.count == 0 {
            if let placeholderView = EmptyContentView.show(in: view) {
                placeholderView.delegate = self
            }
            collectionView?.isScrollEnabled = false
        }
        else {
            EmptyContentView.hide(in: view)
            collectionView?.isScrollEnabled = true
        }
    }

    //
    //  Set the layout of the cell to a reasonable size. The size is calculated so that a predefined number of cells 
    //  fits equally into the shortest dimension of the display area, while minimizing the amount of space between
    //  items. Applicable section insets are included in the calculation.
    //
    //  Any mismatch between the ideal size and the final calculated size is accomodated by the inter-item cell spacing.
    //
    private func updateItemSize(displaySize: CGSize) {
        
        guard let collectionView = collectionView else {
            return
        }
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        // Pre-compute the visible region which the cells can appear inside.
        let sectionInset = layout.sectionInset
        let availableWidth = displaySize.width - sectionInset.left - sectionInset.right
        let availableHeight = displaySize.height - sectionInset.top - sectionInset.bottom
        
        // Work out the size which we would like the cell to be.
        // On iPhone, tries to fit 3 cells into the view in the shortest dimension (width in landscape, height in 
        // portrait). On iPad, tries to fit 5 cells.
        let idealNumberOfCells: CGFloat
        
        switch UIDevice.current.userInterfaceIdiom {
            
        case .pad:
            // iPad: Try show 5 cells in the shortest dimension
            idealNumberOfCells = 5
            
        default:
            // iPhone and other devices: Try show 3 cells
            idealNumberOfCells = 3
        }
        
        let idealSize: CGFloat = min(availableWidth, availableHeight) / idealNumberOfCells
        
        // Calculate an actual number of cells so that whole number fits into the available space, while minimizing the
        // amount of wasted space. The final size may be slightly smaller or larger than the ideal size
        let numberOfItems = round(availableWidth / idealSize)
        let numberOfSpaces = numberOfItems - 1
        let itemSize = floor((availableWidth - numberOfSpaces) / numberOfItems)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
    }
    

    
    //
    // MARK: - Navigation
    //
    

    //
    //  Intercept a segue and prepare the pending view controller before preentation.
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MemeDetailViewController {
            // Showing meme detail view controller. Set the meme for the selected cell.
            if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
                viewController.meme = memes.meme(at: indexPath.item)
            }
        }
    }

    
    
    //
    // MARK: UICollectionViewDataSource
    //

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

//
//  Content placeholder delegate.
//
extension MemesCollectionViewController: EmptyContentDelegate {
    
    //
    //  Called when the user taps on the "Create meme" button on the content placeholder.
    //  Segue to the editor with a blank canvas.
    //
    func emptyContentViewDidCreate(view: EmptyContentView) {
        performSegue(withIdentifier: "edit", sender: nil)
    }
}
