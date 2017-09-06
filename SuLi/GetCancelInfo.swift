//
//  GetCancelInfo.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/09.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import SwiftHTTP
import Kanna
import RealmSwift


struct GetCancelInfo {
    
    static let cancelInfoUrl = NSLocalizedString("cancelInfo", tableName: "ResourceAddress", comment: "講義案内のURL")
    
    static func start( groupDispatch: inout DispatchGroup){
        
        autoreleasepool(){
            
            print("GetCancelInfo : start")
            
            let dispatch = DispatchGroup()
            dispatch.enter()
            
            var pageNum = 1
            var count = 1
            var nextFlg = true
            var loadingStatus = true
            
            //Realmに接続
            let realm = try! Realm()
            //CancelInfoのすべてのオブジェクトを取得
            let cancelInfo = realm.objects(CancelInfo.self)
            //トランザクションを開始
            try! realm.write() {
                print("GetCancelInfo : all cancelInfo data delete init")
                //取得したすべてのオブジェクトを削除
                realm.delete(cancelInfo)
                print("GetCancelInfo : all cancelInfo data delete complete")
            }
            
            repeat {
                
                if loadingStatus {
                    
                    loadingStatus = false //HTTPアクセス中はロックをかける
                    
                    do {
                        print("GetCancelInfo : No.\(pageNum) data init")
                        
                        let opt = try HTTP.GET(self.cancelInfoUrl, parameters: ["abspage":"\(pageNum)"])
                        
                        opt.start { response in
                            if let err = response.error {
                                print("error: \(err.localizedDescription)")
                                nextFlg = false
                                return //also notify app of failure as needed
                            }
                            if let doc = HTML(html: response.data, encoding: .utf8)?.css(".table_data tr") {
                                
                                //Realmに接続
                                let realmWrite = try! Realm()
                                
                                for i in 1..<doc.count {
                                    
                                    //トランザクションを開始
                                    try! realmWrite.write() {
                                    
                                        let tdNodes = doc[i].css("td")
                                        
                                        //書き込むデータを作成
                                        let writeData = CancelInfo()
                                        writeData.id = count
                                        count += 1
                                        
                                        writeData.date = tdNodes[0].text!
                                        writeData.classification = tdNodes[1].text!
                                        writeData.time = tdNodes[2].text!
                                        writeData.department = tdNodes[3].text!
                                        writeData.classname = tdNodes[4].text!
                                        writeData.person = tdNodes[5].text!
                                        writeData.place = tdNodes[6].text!
                                        writeData.note = tdNodes[7].text!
                                        
                                        //データをRealmに書き込む
                                        realmWrite.add(writeData)
                                    }
                                }
                            }
                            
                            if let doc = HTML(html: response.data, encoding: .utf8)?.css(".prevnextpage") {
                                if doc.count < (pageNum == 1 ? 1 : 2) {
                                    nextFlg = false
                                    dispatch.leave()
                                }
                                pageNum += 1
                            }
                            
                            loadingStatus = true //次のアクセスの許可をする
                            
                            print("GetCancelInfo : No.\(pageNum - 1) data complete")
                        }
                        
                    } catch let error {
                        print("got an error creating the request: \(error)")
                        nextFlg = false
                    }
                }
                
            } while nextFlg
            
            //すべての処理が完了したので通知
            dispatch.notify(queue: DispatchQueue.main) { [groupDispatch] in
                let dispatch = groupDispatch
                dispatch.leave()
                print("GetCancelInfo : all task complete")
            }
        }
    }
}
