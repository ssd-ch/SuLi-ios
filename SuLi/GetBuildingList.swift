//
//  GetBuildingList.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/05.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import SwiftHTTP
import Kanna
import RealmSwift


struct GetBuildingList {
    
    static let buildingUrl = "http://www.shimane-u.ac.jp/education/school_info/class_data/class_data01.html"
    var loadingStatus: Bool = true
    
    static func start(){
        do {
            let opt = try HTTP.GET(self.buildingUrl)
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                if let doc = HTML(html: response.data, encoding: .utf8)?.css(".body li a") {
                    //Realmに接続
                    let realm = try! Realm()
                    //print(realm.configuration.fileURL)
                    //Buildingのすべてのオブジェクトを取得
                    let buildings = realm.objects(Building.self)
                    //取得したすべてのオブジェクトを削除
                    buildings.forEach { building in
                        try! realm.write() {
                            realm.delete(building)
                        }
                    }
                    
                    for i in 0..<doc.count {
                        //書き込むデータを作成
                        let writeData = Building()
                        writeData.id = i
                        writeData.building_name = doc[i].text!.replaceAll(pattern: "教室配当表_", with: "").replaceAll(pattern: "_", with: " ")
                        writeData.url = doc[i]["href"]!
                        //データをRealmに書き込む
                        try! realm.write() {
                            realm.add(writeData)
                        }
                    }
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
}
