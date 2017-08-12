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

struct RealmManagement {
    
    //ファイルの肥大化を防ぐために最適化を行う
    static func fileOptimisation() {
        do {
            let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
            print(realm.configuration.fileURL!)
            try! realm.writeCopy(toFile: (realm.configuration.fileURL?.deletingLastPathComponent().appendingPathComponent("temp.realm"))!)
            try FileManager.default.removeItem(at: realm.configuration.fileURL!)
            try FileManager.default.moveItem(at: (realm.configuration.fileURL?.deletingLastPathComponent().appendingPathComponent("temp.realm"))!, to: realm.configuration.fileURL!)
        } catch let error as NSError {
            print("Error - \(error.localizedDescription)")
        }
    }
    
}
