//
//  Task.swift
//  ToDoListRealm
//
//  Created by Ajay Ghodadra on 13/09/16.
//  Copyright © 2016 Ajay Ghodadra. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    dynamic var name = ""
    dynamic var createdAt = NSDate()
    dynamic var state = false

}
