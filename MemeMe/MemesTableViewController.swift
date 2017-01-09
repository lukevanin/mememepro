//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/07.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Display a list of memes in a table view.
//
//  Features:
//      - Shows a placeholder message when empty. Tap the "Create meme" button to get started.
//      - Tap + icon to create a meme.
//      - Swipe on a cell to delete an existing meme, or create a new meme based on an existing meme.
//

import UIKit

class MemesTableViewController: UITableViewController {

    //  Access the shared data model.
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add blank footer view to remove row placeholders when table has no entries.
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateEmptyContent()
    }
    
    //
    //  Intercept a segue, and configure the pending view controller.
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        case let viewController as MemeDetailViewController:
            // Navigating to meme detail view controller, pass in the meme for the tapped row.
            if let indexPath = tableView.indexPathForSelectedRow {
                viewController.meme = memes.meme(at: indexPath.row)
            }
            
        case let navigationController as UINavigationController:
            // Navigating to the editor view controller. 
            // If an existing meme was passed in to the segue, forward it to the view controller to allow the user to 
            // edit it.
            if let viewController = navigationController.topViewController as? MemeViewController {
                if let meme = sender as? Meme {
                    viewController.defaultMeme = meme
                }
            }
            
        default:
            // Unexpected view controller.
            print("Unexpected destination view controller for segue \(segue.identifier) : \(segue.destination)")
            break
        }
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
            tableView.isScrollEnabled = false
        }
        else {
            EmptyContentView.hide(in: view)
            tableView.isScrollEnabled = true
        }
    }
    
    
    //
    // MARK: - Table view data source
    //
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell", for: indexPath) as! MemeTableViewCell
        
        // Configure the cell with the meme.
        let meme = memes.meme(at: indexPath.row)
        cell.topTextLabel.text = meme.topText
        cell.bottomTextLabel.text = meme.bottomText
        cell.memeImageView.image = meme.memedImage

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            makeDeleteAction(),
            makeEditAction()
        ]
    }
    
    //
    //  Action for deleting a meme.
    //
    private func makeDeleteAction() -> UITableViewRowAction {
        return UITableViewRowAction(
            style: .destructive,
            title: "Delete",
            handler: { [weak self] (action, indexPath) in
                self?.deleteItem(at: indexPath.row)
        })
    }
    
    //
    //  Action for copying a meme.
    //
    private func makeEditAction() -> UITableViewRowAction {
        return UITableViewRowAction(
            style: .normal,
            title: "Copy",
            handler: { [weak self] (action, indexPath) in
                self?.copyItem(at: indexPath.row)
        })
    }
    
    
    
    //
    // MARK: Meme model
    //
    
    
    
    //
    //  Presents the meme editor pre-filled with the contents of an existing meme. 
    //  This allows a new meme to be created easily from an existing meme.
    //
    private func copyItem(at index: NSInteger) {
        let meme = memes.meme(at: index)
        performSegue(withIdentifier: "edit", sender: meme)
    }
    
    //
    //  Removes a meme from the collection. The row for the deleted meme is removed with an animation. If the last meme
    //  in the list is deleted, then the empty content placeholder is shown.
    //
    private func deleteItem(at index: NSInteger) {
        
        // Remove meme from global resource.
        memes.remove(at: index)
        
        // Animate removal from table view.
        tableView.beginUpdates()
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        // Ensure empty content placeholder is visible if required.
        updateEmptyContent()
    }
}

//
//  Content placeholder delegate.
//
extension MemesTableViewController: EmptyContentDelegate {
    
    //
    //  Called when the user taps on the "Create meme" button on the content placeholder. 
    //  Segue to the editor with a blank canvas.
    //
    func emptyContentViewDidCreate(view: EmptyContentView) {
        performSegue(withIdentifier: "edit", sender: nil)
    }
}
