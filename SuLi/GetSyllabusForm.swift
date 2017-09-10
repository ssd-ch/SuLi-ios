//
//  GetSyllabusForm.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/09.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import SwiftHTTP
import Kanna
import RealmSwift


struct GetSyllabusForm {
    
    static let syllabusFormUrl = NSLocalizedString("syllabus-form", tableName: "ResourceAddress", comment: "シラバスの検索フォームのURL")
    
    static func start(completeHandler: @escaping () -> (), errorHandler: @escaping (String) -> ()){
        
        print("GetSyllabusForm : start task")
        
        autoreleasepool(){
            
            do {
                let opt = try HTTP.GET(self.syllabusFormUrl)
                opt.start { response in
                    if let err = response.error {
                        print("GetSyllabusForm : failed. \(err.localizedDescription)")
                        errorHandler(err.localizedDescription)
                        return //also notify app of failure as needed
                    }
                    if let doc = HTML(html: response.data, encoding: .shiftJIS)?.css("table").first {
                        //Realmに接続
                        let realm = try! Realm()
                        
                        //SyllabusFormのすべてのオブジェクトを取得
                        let syllabusForm = realm.objects(SyllabusForm.self)
                        
                        //トランザクションを開始
                        try! realm.write() {
                            
                            //取得したすべてのオブジェクトを削除
                            realm.delete(syllabusForm)
                            
                            if let year = doc.css("[name='nendo']").first!["value"] { //年度
                                //書き込むデータを用意する
                                let writeData = SyllabusForm()
                                writeData.id = 0
                                writeData.form = "nendo"
                                writeData.display = year.replaceAll(pattern: "\r\n|\n", with: "")
                                writeData.value = year
                                //データをRealmに書き込む
                                realm.add(writeData)
                            }
                            
                            let options1 = doc.css("[name='j_s_cd'] option") //学部
                            for (i,node) in options1.enumerated() {
                                let writeData = SyllabusForm()
                                writeData.id = Int("1\(NSString(format: "%03d", i))")!
                                writeData.form = "j_s_cd"
                                writeData.display = node.text!.replaceAll(pattern: "\r\n|\n", with: "")
                                writeData.value = node["value"]!
                                //データをRealmに書き込む
                                realm.add(writeData)
                            }
                            
                            let options2 = doc.css("[name=kamokud_cd] option") //科目分類
                            for (i,node) in options2.enumerated() {
                                let writeData = SyllabusForm()
                                writeData.id = Int("2\(NSString(format: "%03d", i))")!
                                writeData.form = "kamokud_cd"
                                writeData.display = node.text!.replaceAll(pattern: "\r\n|\n", with: "")
                                writeData.value = node["value"]!
                                //データをRealmに書き込む
                                realm.add(writeData)
                            }
                            
                            let options3 = doc.css("[name=yobi] option") //曜日
                            for (i,node) in options3.enumerated() {
                                let writeData = SyllabusForm()
                                writeData.id = Int("3\(NSString(format: "%03d", i))")!
                                writeData.form = "yobi"
                                writeData.display = node.text!.replaceAll(pattern: "\r\n|\n", with: "")
                                writeData.value = node["value"]!
                                //データをRealmに書き込む
                                realm.add(writeData)
                            }
                            
                            let options4 = doc.css("[name=jigen] option") //時限
                            for (i,node) in options4.enumerated() {
                                let writeData = SyllabusForm()
                                writeData.id = Int("4\(NSString(format: "%03d", i))")!
                                writeData.form = "jigen"
                                writeData.display = node.text!.replaceAll(pattern: "\r\n|\n", with: "")
                                writeData.value = node["value"]!
                                //データをRealmに書き込む
                                realm.add(writeData)
                            }
                        }
                        
                        //処理が完了
                        print("GetSyllabusForm : all task complete")
                        completeHandler()
                    }
                }
            } catch let error {
                print("got an error creating the request: \(error)")
                errorHandler(error.localizedDescription)
            }
        }
    }
}

