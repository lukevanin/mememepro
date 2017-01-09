//
//  EmptyContentView.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Used to display a placeholder for an empty meme list. Improves user experience by directing the user to engage with
//  the app when there is no content.
//
//  The view is loaded from a nib so that it can be reused in multiple places without duplication of effort. If this
//  were implemented in a storyboard, each view controller would need its own UI layout for the placeholder view. 
//

import UIKit

protocol EmptyContentDelegate: class {
    func emptyContentViewDidCreate(view: EmptyContentView)
}

class EmptyContentView: UIView {
    
    //
    //  Delegate reference for the content view. A weak reference is used for the delegate so that it can be released
    //  automatically when the content placeholder is removed from the view hierarchy.
    //
    weak var delegate: EmptyContentDelegate?
    
    //
    //  Create Meme button tapped. Notify the delegate.
    //
    @IBAction func onCreateAction(_ sender: Any) {
        delegate?.emptyContentViewDidCreate(view: self)
    }
    
    //
    //  Instantiate the content placeholder and display it in a view. The placeholder is centered to the parent view.
    //
    static func show(in container: UIView) -> EmptyContentView? {
        
        // Ensure any existing view is removed. Prevents accidentally adding the view twice in case a view is already
        // visible.
        hide(in: container)
        
        guard let window = container.superview else {
            return nil
        }
        
        // Try instantiate the view from the nib.
        guard let view = loadFromNib() else {
            return nil
        }
        
        // Add the view to the parent.
        container.addSubview(view)
        
        // Align view to center of parent.
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            ])
        
        // Return new instance.
        return view
    }
    
    //
    // Removes any instance of the placeholder view from a container view.
    //
    static func hide(in container: UIView) {
        for subview in container.subviews {
            if subview is EmptyContentView {
                subview.removeFromSuperview()
            }
        }
    }

    //
    // Instantiates content view from nib file.
    //
    static func loadFromNib() -> EmptyContentView? {
        let nib = UINib.init(nibName: "EmptyContentView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? EmptyContentView else {
            return nil
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
