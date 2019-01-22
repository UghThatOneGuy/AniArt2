//
//  Frame.swift
//  AniArt
//
//  Created by Matthew Reilly on 1/2/19.
//  Copyright © 2019 UghThatOneGuy. All rights reserved.
//

import Foundation

struct Frame{
    var lines: [Line]
    var undoQueue: [Line]
    
    init(lines: [Line], undoQueue: [Line]){
        self.lines = lines
        self.undoQueue = undoQueue
    }
}
