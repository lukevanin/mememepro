//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/07.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class MemesTableViewController: UITableViewController {
    
    private let memes = Memes.shared
    
    @IBAction func dismissPopupViewController(sender: UIStoryboardSegue) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add blank footer view to remove row placeholders when table has no entries.
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        case let viewController as MemeDetailViewController:
            if let indexPath = tableView.indexPathForSelectedRow {
                viewController.meme = memes.meme(at: indexPath.row)
            }
            
        case let navigationController as UINavigationController:
            if let viewController = navigationController.topViewController as? MemeViewController {
                if let meme = sender as? Meme {
                    viewController.defaultMeme = meme
                }
            }
            
        default:
            // Unexpected view controller
            print("Unexpected destination view controller for segue \(segue.identifier) : \(segue.destination)")
            break
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell", for: indexPath) as! MemeTableViewCell
        
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
    
    private func makeDeleteAction() -> UITableViewRowAction {
        return UITableViewRowAction(
            style: .destructive,
            title: "Delete",
            handler: { [weak self] (action, indexPath) in
                self?.deleteItem(at: indexPath.row)
        })
    }
    
    private func makeEditAction() -> UITableViewRowAction {
        return UITableViewRowAction(
            style: .normal,
            title: "Copy",
            handler: { [weak self] (action, indexPath) in
                self?.editItem(at: indexPath.row)
        })
    }
    
    private func editItem(at index: NSInteger) {
        let meme = memes.meme(at: index)
        performSegue(withIdentifier: "edit", sender: meme)
    }
    
    private func deleteItem(at index: NSInteger) {
        
        // Remove meme from global resource.
        memes.remove(at: index)
        
        // Animate removal from table view.
        tableView.beginUpdates()
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}
