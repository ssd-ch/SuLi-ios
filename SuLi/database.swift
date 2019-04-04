//
//  database.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import RealmSwift

class ClassroomDivide: Object {
    
    @objc dynamic var id = -1
    @objc dynamic var building_id = -1
    @objc dynamic var place = ""
    @objc dynamic var weekday = -1
    @objc dynamic var time = -1
    @objc dynamic var cell_text = ""
    @objc dynamic var cell_color = ""
    @objc dynamic var classname = ""
    @objc dynamic var person = ""
    @objc dynamic var department = ""
    @objc dynamic var class_code = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Building: Object {
    
    @objc dynamic var id = -1
    @objc dynamic var building_name = ""
    @objc dynamic var url = ""
    @objc dynamic var color = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SyllabusForm: Object {
    
    @objc dynamic var id = -1
    @objc dynamic var form = ""
    @objc dynamic var display = ""
    @objc dynamic var value = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class CancelInfo: Object {
    
    @objc dynamic var id = -1
    @objc dynamic var date = ""
    @objc dynamic var time = ""
    @objc dynamic var classification = ""
    @objc dynamic var department = ""
    @objc dynamic var classname = ""
    @objc dynamic var person = ""
    @objc dynamic var place = ""
    @objc dynamic var note = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

struct RealmManagement {
    
    //マイグレーション
    static let config = Realm.Configuration(
        // 新しいスキーマバージョンを設定します。以前のバージョンより大きくなければなりません。
        // （スキーマバージョンを設定したことがなければ、最初は0が設定されています）
        schemaVersion: 1,
        
        // マイグレーション処理を記述します。古いスキーマバージョンのRealmを開こうとすると
        // 自動的にマイグレーションが実行されます。
        migrationBlock: { migration, oldSchemaVersion in
            // 最初のマイグレーションの場合、`oldSchemaVersion`は0です
            if (oldSchemaVersion < 1) {
                // Realmは自動的に新しく追加されたプロパティと、削除されたプロパティを認識します。
                // そしてディスク上のスキーマを自動的にアップデートします。
                print("RealmManagement : Run migration")
            }
    })
    
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
