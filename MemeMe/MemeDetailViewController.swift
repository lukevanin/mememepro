//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/07.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Display a precomposed meme.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme: Meme?
    
    @IBOutlet weak var memeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = meme?.memedImage else {
            return
        }
        memeImageView.image = image
        let imageSize = image.size
        let aspectRatio = imageSize.width / imageSize.height
        memeImageView.widthAnchor.constraint(equalTo: memeImageView.heightAnchor, multiplier: aspectRatio)
    }

}
