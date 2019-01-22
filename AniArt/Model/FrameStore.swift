//
//  FrameStore.swift
//  AniArt
//
//  Created by Matthew Reilly on 1/3/19.
//  Copyright © 2019 UghThatOneGuy. All rights reserved.
//

import Foundation

class FrameStore {
    var frames = [Frame]()
    
    @discardableResult func addFrame(_ frame: Frame) -> Frame {
        frames.append(frame)
        return frame
    }
    
    func removeFrame(_ frame: Frame, _ index: Int) {
            frames.remove(at: index)
    }
    
    /*func moveFrame(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        //get reference to object being moved so can reinsert it
        let movedItem = frames[fromIndex]
        
        //remove from array
        frames.remove(at: fromIndex)
        
        //insert item at new index
        frames.insert(movedItem, at: toIndex)
    }*/
}
