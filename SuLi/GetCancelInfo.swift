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
    
    private static let cancelInfoUrl = NSLocalizedString("cancelInfo", tableName: "ResourceAddress", comment: "講義案内のURL")
    
    private static var opt : HTTP!
    
    static func start(completeHandler: @escaping () -> (), errorHandler: @escaping (String) -> ()){
        
        print("GetCancelInfo : task start")
        
        autoreleasepool{
            
            self.getData(page: 1, data: [], completeHandler: { writeData in
                
                //Realmに接続
                let realm = try! Realm()
                //CancelInfoのすべてのオブジェクトを取得
                let cancelInfo = realm.objects(CancelInfo.self)
                //トランザクションを開始
                try! realm.write() {
                    //取得したすべてのオブジェクトを削除
                    realm.delete(cancelInfo)
                    print("GetCancelInfo : all cancelInfo data delete")
                    
                    for (i,data) in writeData.enumerated() {
                        //マルチスレッドで処理したのでIDが競合するのを防ぐためにここで設定する
                        data.id = i + 1
                        //データを書き込む
                        realm.add(data)
                    }
                    print("GetCancelInfo : all data is written")
                }
                
                print("GetCancelInfo : all task complete")
                completeHandler()
            }, errorHandler: { message in
                print("GetCancelInfo : failed task")
                errorHandler(message)
            })
        }
        
    }
    
    private static func getData(page: Int, data: [CancelInfo], completeHandler: @escaping ([CancelInfo]) -> (), errorHandler: @escaping (String) -> ()) {
        
        autoreleasepool{
            
            var writeData: [CancelInfo] = data
            
            do {
                print("GetCancelInfo : No.\(page) data init")
                
                self.opt = try HTTP.GET(self.cancelInfoUrl, parameters: ["abspage":"\(page)"])
                
                self.opt.start { response in
                    
                    if let err = response.error {
                        print("GetCancelInfo : No.\(page) data failed \(err.localizedDescription)")
                        errorHandler(err.localizedDescription)
                        return
                    }
                    
                    if let doc = HTML(html: response.data, encoding: .utf8)?.css(".table_data tr") {
                        
                        if doc.count >= 2 {
                            for i in 1..<doc.count {
                                
                                let tdNodes = doc[i].css("td")
                                
                                //書き込むデータを作成
                                let data = CancelInfo()
                                
                                data.date = tdNodes[0].text!
                                data.classification = tdNodes[1].text!
                                data.time = tdNodes[2].text!
                                data.department = tdNodes[3].text!
                                data.classname = tdNodes[4].text!
                                data.person = tdNodes[5].text!
                                data.place = tdNodes[6].text!
                                data.note = tdNodes[7].text!
                                
                                writeData.append(data)
                            }
                        }
                        
                        print("GetCancelInfo : No.\(page) data complete")
                    }
                    
                    if let doc = HTML(html: response.data, encoding: .utf8)?.css(".prevnextpage") {
                        
                        if doc.count < (page == 1 ? 1 : 2) {
                            //これ以上読み込むページがない(処理が完了)
                            completeHandler(writeData)
                        }
                        else {
                            //次のページを読み込む
                            self.getData(page: page + 1, data: writeData, completeHandler: completeHandler, errorHandler: errorHandler)
                        }
                    }
                    else {
                        errorHandler("error: can't get next page flag")
                    }
                    
                }
                
            } catch let error {
                print("got an error creating the request: \(error)")
                errorHandler(error.localizedDescription)
            }
        }
    }
    
    static func cancel() {
        if self.opt?.isExecuting ?? false {
            self.opt.cancel()
        }
    }
}
