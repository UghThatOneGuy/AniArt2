//
//  ImageStore.swift
//  AniArt
//
//  Created by Matthew Reilly on 1/3/19.
//  Copyright © 2019 UghThatOneGuy. All rights reserved.
//

import Foundation
import UIKit
import Swift

class ImageStore: UIView{
    var images = [UIImage]()
    
    @discardableResult func addImage() -> UIImage {
        let newImage = UIImage()
        images.append(newImage)
        return newImage
    }
    
    func removeImage(_ image: UIImage, _ index: Int) {
            images.remove(at: index)
    }
    
    func replaceImage(_ image: UIImage, _ index: Int) {
        images[index] = image
    }
    
    /*func moveImage(from fromIndex: Int, to toIndex: Int) {
     if fromIndex == toIndex {
     return
     }
     //get reference to object being moved so can reinsert it
     let movedItem = images[fromIndex]
     
     //remove from array
     images.remove(at: fromIndex)
     
     //insert item at new index
     images.insert(movedItem, at: toIndex)
     }*/
}
