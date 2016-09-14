//
//  StickPicsCollectionViewController.swift
//  StickPics
//
//  Created by Dylan Wight on 8/20/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit
import Messages

class StickPicsCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    
    static let storyboardIdentifier = "StickPicsCollectionViewController"
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StickPicHistory.load().stickPicURLs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let url = StickPicHistory.load().stickPicURLs[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickPicCell", for: indexPath) as! StickPicCell
        
        print("sticker: \(url)")
        
        do {
            cell.stickerView.sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "test")
        } catch {
            fatalError("Failed to load sticker image: \(error)")
        }
        
        return cell
    }
}

