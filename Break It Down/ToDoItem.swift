//
//  ToDoItem.swift
//  Break It Down
//
//  Created by Rob Norback on 8/29/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {
    // Text description of item
    var text:String
    // Is item completed
    var completed:Bool
    
    init(text: String) {
        self.text = text
        completed = false
    }
   
}
