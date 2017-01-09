//
//  Memes.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/08.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Model to maintain a collection of memes. Provides a convenience accessor to a global singleton instance.
//
//  The courseware recommends implementing shared state in the AppDelegate, while also mentioning it as a 
//  "controversial" approach. Curious about the controversy I researched some alternative methods, resulting in the 
//  singleton pattern. While not without controversy, this seems to be more flexible (ie higher code reuse). 
//
//  An even better approach might be to use dependency injection and pass the instance between view controllers in
//  the prepareForSegue().
//

import Foundation

class Memes {

    // Global shared instance (singleton)
    static let shared = Memes()
    
    private var memes = [Meme]()
    
    //
    //  Number of available memes.
    //
    var count: Int {
        return memes.count
    }
    
    //
    //  Retrieve a meme at a specific index.
    //
    func meme(at index: Int) -> Meme {
        return memes[index]
    }
    
    //
    //  Remove a meme at a specific index.
    //
    func remove(at index: Int) {
        memes.remove(at: index)
    }
    
    //
    //  Insert a new meme into the collection. Memes are inserted at the head (0th index) of the list.
    //
    func add(meme: Meme) {
        memes.insert(meme, at: 0)
    }
}
