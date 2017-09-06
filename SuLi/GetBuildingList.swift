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
    
    static let buildingUrl = NSLocalizedString("buildingList", tableName: "ResourceAddress", comment: "建物別教室配当表一覧のURL")
    var loadingStatus: Bool = true
    
    private static var groupDispatchHTTP: DispatchGroup?
    
    static func start(groupDispatch: inout DispatchGroup){
        
        print("GetBuildingList : start task")
        
        self.groupDispatchHTTP = DispatchGroup()
        self.groupDispatchHTTP?.enter()
        
        autoreleasepool(){
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
                        
                        //Buildingのすべてのオブジェクトを取得
                        let buildings = realm.objects(Building.self)
                        
                        //トランザクションを開始
                        try! realm.write() {
                            //取得したすべてのオブジェクトを削除
                            realm.delete(buildings)
                            
                            for i in 0..<doc.count {
                                //書き込むデータを作成
                                let writeData = Building()
                                writeData.id = i
                                writeData.building_name = doc[i].text!.replaceAll(pattern: "教室配当表_", with: "").replaceAll(pattern: "_", with: " ")
                                writeData.url = doc[i]["href"]!
                                //データをRealmに書き込む
                                realm.add(writeData)
                            }
                        }
                    }
                    self.groupDispatchHTTP?.leave()
                }
            } catch let error {
                print("got an error creating the request: \(error)")
            }
        }
        
        self.groupDispatchHTTP?.notify(queue: DispatchQueue.main) { [groupDispatch] in
            print("GetBuildingList : all task complete")
            let dispatch = groupDispatch
            dispatch.leave()
        }
    }
}
