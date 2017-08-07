//
//  GetClassroomList.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import SwiftHTTP
import Kanna
import RealmSwift

struct GetClassroomList {

    static func start(){
        
        //建物別のリンクを取得
        GetBuildingList.start()
        
        //Realmに接続
        let realm = try! Realm()
        
        //ClassroomDivideのすべてのオブジェクトを取得
        let objects = realm.objects(ClassroomDivide.self)
        //取得したすべてのオブジェクトを削除
        objects.forEach { object in
            try! realm.write() {
                realm.delete(object)
            }
        }
        
        //Buildingのすべてのオブジェクトを取得
        let buildings = realm.objects(Building.self)
        
        //すべてのページの配当表を取得
        buildings.forEach { building in
            
            let building_id = building.id //これ以下は別スレッドでRealmのオブジェクトにアクセスできないので退避
            
            do {
                let opt = try HTTP.GET(building.url)
                opt.start { response in
                    if let err = response.error {
                        print("error: \(err.localizedDescription)")
                        return //also notify app of failure as needed
                    }
                    if let doc = HTML(html: response.data, encoding: .utf8)?.css(".body tr") {
                        print(building_id)
                        
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
                                        if let style = tdData[i == 0 ? pn + 2 : pn + 1].css("span").first?["style"] {
                                            if let index = style.range(of: "#") {
                                                let index_int = style.distance(from: style.startIndex, to: index.lowerBound)
                                                color = style.substring(with: style.index(style.startIndex, offsetBy: index_int)..<style.index(style.startIndex, offsetBy: index_int + 7))
                                            }
                                        }
                                        else {
                                            L_Info = ExtractionLecture(str: text)
                                        }
                                    }
                                    let id = "\(NSString(format: "%02d", building_id))\(NSString(format: "%02d", pn))\(d)\(i)"
                                    
                                    print("\(id), \(building_id),\(places[pn]), \(d), \(i + 1), \(text), \(color), \(L_Info[0]), \(L_Info[1]), \(L_Info[2]), \(L_Info[3])")
                                }
                            }
                        }
                    }
                }
            } catch let error {
                print("got an error creating the request: \(error)")
            }
            
        }
    }
}

private func ExtractionLecture(str: String) -> [String]{
    
    var result = ["", "", "", ""]
    
    return result
}
