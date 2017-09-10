//
//  GetClassroomDivide.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import SwiftHTTP
import Kanna
import RealmSwift

struct GetClassroomDivide {
    
    private static var groupDispatchHTTP: DispatchGroup?
    
    static func start(completeHandler: @escaping () -> (), errorHandler: @escaping (String) -> ()) {
        
        print("GetClassroomDivide : start task")
        
        autoreleasepool{
            
            //建物別のリンクを取得
            GetBuildingList.start(completeHandler: {
                //Realmに接続
                let realm = try! Realm()
                
                //ClassroomDivideのすべてのオブジェクトを取得
                let objects = realm.objects(ClassroomDivide.self)
                //トランザクションを開始
                try! realm.write() {
                    //取得したすべてのオブジェクトを削除
                    realm.delete(objects)
                    print("GetClassroomDivide : all ClassroomDivide data delete")
                }
                
                //Buildingのすべてのオブジェクトを取得
                let buildings = realm.objects(Building.self)
                
                //スレッドを管理するグループを作成
                self.groupDispatchHTTP = DispatchGroup()
                
                //スレッドの登録
                for _ in buildings {
                    self.groupDispatchHTTP?.enter()
                }
                
                //すべてのページの配当表を取得
                buildings.forEach { building in
                    print("GetClassroomDivide : No.\(building.id) data init")
                    self.scrapingClassroomDivide(building_id: building.id, url: building.url)
                }
                
                //すべてのスレッドの処理が完了
                self.groupDispatchHTTP?.notify(queue: DispatchQueue.main) {
                    print("GetClassroomDivide : all task complete")
                    completeHandler()
                }
                
            }, errorHandler: { message in
                print("GetClassroomDivide : failed task.")
                errorHandler(message)
                return
            })
        }
        
    }
    
    private static func scrapingClassroomDivide(building_id: Int,url: String) {
        autoreleasepool(){
            do {
                let opt = try HTTP.GET(url)
                opt.start { response in
                    if let err = response.error {
                        print("error: \(err.localizedDescription)")
                        return //also notify app of failure as needed
                    }
                    if let doc = HTML(html: response.data, encoding: .utf8)?.css(".body tr") {
                        
                        //Realmに接続
                        let realm = try! Realm()
                        
                        //トランザクションを開始
                        try! realm.write() {
                            
                            //各教室の取得
                            var places : [String] = []
                            var place_cnt = 0
                            for td in doc[0].css("td").dropFirst(1) {
                                for _ in 0..<(td["colspan"] == nil ? 1 : Int(td["colspan"]!)!) {
                                    if td["rowspan"] == nil {
                                        places += [td.text! + " " + doc[1].css("td")[place_cnt].text!]
                                        place_cnt += 1
                                    }
                                    else {
                                        places += [td.text!]
                                    }
                                }
                            }
                            for i in 0..<places.count {
                                places[i] = places[i].replaceAll(pattern: "\r\n|\n", with: "")
                                places[i] = places[i].replaceAll(pattern: "_|　", with: " ").HalfWidthNumber
                            }
                            
                            for d in 0..<5 { //月から金のループ
                                let point = d * 5 + 2 //trタグの位置
                                for i in 0..<5 { //1から5コマのループ
                                    
                                    let tdData = doc[point + i].css("td")
                                    for pn in 0..<places.count { //場所のループ
                                        var text = tdData[i == 0 ? pn + 2 : pn + 1].text! //一番最初は曜日名が入るので一つずらす
                                        var L_Info = ["", "", "", ""]
                                        var color = "#000000"
                                        
                                        if text == "\u{00A0}" || text == "" || text == "\r\n" || text == "\n" { //&nbsp;,"",改行のみ
                                            text = ""
                                        }
                                        else {
                                            text = text.replaceAll(pattern: "\r\n|\n", with: "")
                                            L_Info = self.ExtractionLecture(str: text)
                                        }
                                        
                                        if let style = tdData[i == 0 ? pn + 2 : pn + 1].css("span").first?["style"] {
                                            if let index = style.range(of: "#") {
                                                let index_int = style.distance(from: style.startIndex, to: index.lowerBound)
                                                color = style.substring(with: style.index(style.startIndex, offsetBy: index_int)..<style.index(style.startIndex, offsetBy: index_int + 7))
                                            }
                                        }
                                        
                                        let id = "\(NSString(format: "%02d", building_id))\(NSString(format: "%02d", pn))\(d)\(i)"
                                        
                                        //書き込むデータを作成
                                        let resultData = ClassroomDivide()
                                        resultData.id = Int(id)!
                                        resultData.building_id = building_id
                                        resultData.place = places[pn]
                                        resultData.weekday = d
                                        resultData.time = i + 1
                                        resultData.cell_text = text
                                        resultData.cell_color = color
                                        resultData.classname = L_Info[0]
                                        resultData.person = L_Info[1]
                                        resultData.department = L_Info[2]
                                        resultData.class_code = L_Info[3]
                                        
                                        //データをRealmに書き込む
                                        realm.add(resultData)
                                        
                                        //print("\(id), \(building_id),\(places[pn]), \(d), \(i + 1), \(text), \(color), \(L_Info[0]), \(L_Info[1]), \(L_Info[2]), \(L_Info[3])")
                                    }
                                }
                            }
                            
                            if doc.count > 27 {
                                var place_text = ""
                                var day_cache = ""
                                var pn = doc[2].css("td").count - 2
                                
                                for i in 27..<doc.count {
                                    var tdText = [doc[i].css("td")[0].text!, doc[i].css("td")[1].text!, doc[i].css("td")[2].text!.replaceAll(pattern: "\r\n|\n", with: "")]
                                    if tdText[0] == "\u{00A0}" && tdText[1] == "\u{00A0}" {
                                        place_text = tdText[2].replaceAll(pattern: "　", with: "").HalfWidthNumber
                                    }
                                    else {
                                        tdText[0] = tdText[0].replaceAll(pattern: "[ 　\u{00A0}]", with: "") //全角半角&nbspスペースの排除
                                        tdText[1] = tdText[1].replaceAll(pattern: "[ 　\u{00A0}]", with: "") //全角半角&nbspスペースの排除
                                        if tdText[0] == "" {
                                            tdText[0] = day_cache
                                        }
                                        day_cache = tdText[0]
                                        let dayText = "月火水木金土日"
                                        let day = dayText.distance(from: dayText.startIndex, to: dayText.range(of: tdText[0])!.lowerBound)
                                        let time = Int(tdText[1].matcherSubString(pattern: "\\..*").replaceAll(pattern: "\\.", with: ""))! / 2
                                        let id = "\(NSString(format: "%02d", building_id))\(NSString(format: "%02d", pn))\(day)\(time)"
                                        pn += 1
                                        let L_Info = self.ExtractionLecture(str: tdText[2])
                                        
                                        //書き込むデータを作成
                                        let resultData = ClassroomDivide()
                                        resultData.id = Int(id)!
                                        resultData.building_id = building_id
                                        resultData.place = place_text
                                        resultData.weekday = day
                                        resultData.time = time
                                        resultData.cell_text = tdText[2]
                                        resultData.cell_color = "#000000"
                                        resultData.classname = L_Info[0]
                                        resultData.person = L_Info[1]
                                        resultData.department = L_Info[2]
                                        resultData.class_code = L_Info[3]
                                        
                                        //データをRealmに書き込む
                                        realm.add(resultData)
                                        
                                        //print("\(id), \(building_id),\(place_text), \(day), \(time), \(tdText[2]), #000000, \(L_Info[0]), \(L_Info[1]), \(L_Info[2]), \(L_Info[3])")
                                    }
                                }
                            }
                        }
                        
                        print("GetClassroomDivide : No.\(building_id) data complete")
                    }
                    
                    //処理の終了を通知
                    self.groupDispatchHTTP?.leave()
                }
            } catch let error {
                print("got an error creating the request: \(error)")
            }
        }
    }
    
    private static func ExtractionLecture(str: String) -> [String]{
        
        var result = ["", "", "", ""]
        
        let d_code = "ＬＳＥＨＭＳＡＦＣ○*"
        
        var text = str.replaceAll(pattern: "、", with: " ")
        
        //授業名
        if text.matches(pattern: ".*『.*』.*") {
            result[0] = text.matcherSubString(pattern: "『.*』").replaceAll(pattern: "[『』]", with: "")
            text = text.replaceAll(pattern: "『.*』", with: "")
        }
        //時間割コード
        if text.matches(pattern: ".*[A-Z0-9]{6}.*") {
            result[3] = text.matcherSubString(pattern: "[A-Z0-9]{6,}")
            text = text.replaceAll(pattern: "[A-Z0-9/]{6,}", with: "")
        }
        //担当者情報
        if text.matches(pattern: ".*[" + d_code + "].*") {
            let t = text.matcherSubString(pattern: "[" + d_code + "]{1,2}[^" + d_code + "]*")
            result[2] = t.matcherSubString(pattern: "[" + d_code + "]{1,2}")
            result[1] = t.replaceAll(pattern: "[" + d_code + "]", with: "")
        }
        
        for i in 0..<result.count {
            result[i] = result[i].replaceAll(pattern: "[　 ]", with: "")
        }
        
        //print("授業名:\(result[0]) 時間割コード:\(result[3]) 担当者名:\(result[1]) 担当者所属:\(result[2]) --> \(str.replaceAll(pattern: "\r\n|\n", with: ""))")
        
        return result
    }
    
}
