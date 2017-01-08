//
//  Memes.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/08.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class Memes {

    // Global shared instance (singleton)
    static let shared = Memes()
    
    private var memes = [Meme]()
    
    var count: Int {
        return memes.count
    }
    
    func meme(at index: Int) -> Meme {
        return memes[index]
    }
    
    func remove(at index: Int) {
        memes.remove(at: index)
    }
    
    func add(meme: Meme) {
        memes.insert(meme, at: 0)
    }
}
