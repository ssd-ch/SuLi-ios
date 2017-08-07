//
//  database.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import RealmSwift

class ClassroomDivide: Object {
    
    dynamic var id = -1
    dynamic var building_id = -1
    dynamic var place = ""
    dynamic var weekday = -1
    dynamic var time = -1
    dynamic var cell_text = ""
    dynamic var cell_color = ""
    dynamic var classname = ""
    dynamic var person = ""
    dynamic var department = ""
    dynamic var class_code = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Building: Object {
    
    dynamic var id = -1
    dynamic var building_name = ""
    dynamic var url = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SyllabusForm: Object {
    
    dynamic var id = -1
    dynamic var form = ""
    dynamic var display = ""
    dynamic var value = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

class CancelInfo: Object {
    
    dynamic var id = -1
    dynamic var date = ""
    dynamic var time = ""
    dynamic var classification = ""
    dynamic var department = ""
    dynamic var classname = ""
    dynamic var person = ""
    dynamic var place = ""
    dynamic var note = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
