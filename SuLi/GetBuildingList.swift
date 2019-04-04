//
//  GetBuildingList.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/05.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import Alamofire
import Kanna
import RealmSwift

struct GetBuildingList {
    
    private static let buildingUrl = NSLocalizedString("buildingList", tableName: "ResourceAddress", comment: "建物別教室配当表一覧のURL")
    
    private static var request: DataRequest?
    
    static func start(completeHandler: @escaping () -> (), errorHandler: @escaping (String) -> ()){
        
        print("GetBuildingList : start task")
        
        autoreleasepool{
            
            let manager = RequestManager.manager()
            self.request = manager.request(self.buildingUrl, method: .get)
            self.request?.responseString { response in
                if let err = response.error {
                    print("GetBuildingList : failed task. \(err.localizedDescription)")
                    errorHandler(err.localizedDescription)
                    return
                }
                guard let data = response.data else { return }
                if let doc = try? HTML(html: data, encoding: .utf8).css(".body li a") {
                    
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
                    
                    print("GetBuildingList : all task complete")
                    completeHandler()
                }
            }
        }
    }
    
    static func cancel() {
        self.request?.cancel()
    }
}
