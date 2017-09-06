//
//  SyllabusDetailViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/02.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import SwiftHTTP
import Kanna
import RealmSwift

class SyllabusDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SyllabusDetailDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    
    //シラバスのURL
    var link: String?
    
    //シラバスを取得するためのクラス
    var syllabus: GetSyllabus?
    
    //取得したシラバス情報
    var tableData: SyllabusData = SyllabusData()
    
    //セクション
    var sectionIndex = [NSLocalizedString("syllabus-section-basic", comment: "シラバスのセクション名:基本情報"),
                        NSLocalizedString("syllabus-section-detail", comment: "シラバスのセクション名:詳細情報"),
                        NSLocalizedString("syllabus-section-teachers", comment: "シラバスのセクション名:担当者"),
                        NSLocalizedString("syllabus-section-place", comment: "シラバスのセクション名:場所")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //プログレスバーを0.1にセットする
        self.progressView.setProgress(0.1, animated: false)
        
        //セクション名のみ表示されてしまうので非表示にしておく
        self.tableView.isHidden = true
        
        self.tableView.estimatedRowHeight = 30
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.syllabus = GetSyllabus(self.link!)
        self.syllabus?.delegate = self
        self.syllabus!.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //リロードデータ用デリゲートメソッド
    func finishTask(data: SyllabusData, mode: Bool) {
        self.progressView.setProgress(1.0, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.progressView.isHidden = true
        }
        
        self.tableView.isHidden = false
        self.tableData = data
        self.tableView.reloadData()
    }
    
    //プログレス用デリゲートメソッド
    func progress(_ progress: Float) {
        self.progressView.setProgress(progress, animated: true)
    }
    
    //各セクションのデータの個数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.tableData.basic.count
        case 1:
            return self.tableData.detail.count
        case 2:
            return self.tableData.teachers.count
        case 3:
            return self.tableData.place.count
        default:
            return 0
        }
    }
    
    //セクション名を返す
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        return self.sectionIndex[section]
    }
    
    //セクションの個数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionIndex.count
    }
    
    //セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.text = self.tableData.basic[indexPath.row].0
            cell.detailTextLabel?.text = self.tableData.basic[indexPath.row].1
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! SyllabusCustomViewCell
            cell.titleLabel.text = self.tableData.detail[indexPath.row].0
            cell.detaiLabel.text = self.tableData.detail[indexPath.row].1
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath)
            cell.textLabel?.text = self.tableData.teachers[indexPath.row].0
            cell.detailTextLabel?.text = self.tableData.teachers[indexPath.row].1
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath)
            cell.textLabel?.text = self.tableData.place[indexPath.row].0
            cell.detailTextLabel?.text = self.tableData.place[indexPath.row].1
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.text = "N/A"
            cell.detailTextLabel?.text = "N/A"
            return cell
        }
    }
}

protocol SyllabusDetailDelegate {
    
    func finishTask(data: SyllabusData, mode: Bool) -> Void
    func progress(_ progress: Float) -> Void
}

class GetSyllabus {
    
    var URL = ""
    var loadingStatus: Bool = true
    
    var delegate: SyllabusDetailDelegate?
    
    init(_ url: String) {
        self.URL = url
    }
    
    func start() {
        
        let resultData = SyllabusData()
        
        do {
            let opt = try HTTP.GET(self.URL)
            
            opt.progress = { progress in
                //サーバーの関係で取得するデータサイズが-1になってしまうので10000byteあたりを想定してプログレスバーを更新する
                let val = progress / Float(-10000.0)
                if val < 1.0 && val > 0.1 {
                    DispatchQueue.main.async {
                        self.delegate!.progress(val)
                    }
                }
            }
            
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                if let doc = HTML(html: response.data, encoding: .shiftJIS)?.css("table.normal") {
                    if doc.count >= 3 {
                        
                        //基本データ
                        let thBasic = doc[0].css("th")
                        let tdBasic = doc[0].css("td")
                        
                        for i in 0..<thBasic.count {
                            resultData.basic.append((thBasic[i].text!, tdBasic[i].text!))
                        }
                        
                        //講義内容
                        let thDetail = doc[1].css("th")
                        let tdDetail = doc[1].css("td")
                        
                        for i in 0..<thDetail.count {
                            let text = tdDetail[i].toHTML!.replaceAll(pattern: "<br>", with: "\n")
                            resultData.detail.append((thDetail[i].text!, HTML(html: text, encoding: .utf8)!.text!))
                        }
                        
                        //担当教員
                        let tdTeacher = doc[2].css("td")
                        
                        for i in stride(from: 0, to: tdTeacher.count, by: 2) {
                            resultData.teachers.append((tdTeacher[i].text!, tdTeacher[i+1].text!))
                        }
                        
                        //講義場所
                        //(授業名または担当教員の苗字が一致)かつ(いずれかの曜日時限が一致)する場所を問い合わせる
                        let placeQuery = try! Realm().objects(ClassroomDivide.self).filter("( classname like '*\(tdBasic[4].text!)*' or person like '*\(tdBasic[10].text!.replaceAll(pattern: "[ 　]+.*", with: ""))*' ) and " + self.CreateWhereTime(text: tdBasic[7].text!))
                        
                        for data in placeQuery {
                            if data.person.matches(pattern: ".*\(tdBasic[10].text!.replaceAll(pattern: " |　", with: ".*")).*") {
                                resultData.place.append(
                                    (data.place, "\(NSLocalizedString("syllabus-place-weekday-\(data.weekday)", comment: "シラバスの場所:曜日")) \(NSLocalizedString("syllabus-place-time-\(data.time)", comment: "シラバスの場所:時限"))")
                                )
                            }
                        }
                        
                        //一つも該当しなかった場合
                        if resultData.place.count <= 0 {
                            resultData.place.append(
                                (NSLocalizedString("syllabus-place-error-title", comment: "シラバスの場所:該当なしの時のタイトル"),
                                NSLocalizedString("syllabus-place-error-detail", comment: "シラバスの場所:該当なしの時の詳細"))
                                )
                        }
                        
                        //メインスレッドで呼び出す
                        DispatchQueue.main.async {
                            self.delegate?.finishTask(data: resultData, mode: false)
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.delegate?.finishTask(data: resultData, mode: false)
                        }
                    }
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    private func CreateWhereTime(text: String) -> String {
        
        var whereText: String = ""
        
        let weekday_array = text.matcherSubString(pattern: "[月火水木金土日]+").components(separatedBy: String.separeteCharacter)
        var time_array = text.matcherSubString(pattern: "\\(.{1,2}限,([2468]+|10|12|14)").replaceAll(pattern: "\\(.{1,2}限,", with: "").components(separatedBy: String.separeteCharacter)
        
        for i in 0..<weekday_array.count {
            
            var day: Int
            
            switch weekday_array[i] {
            case "月":
                day = 0
            case "火":
                day = 1
            case "水":
                day = 2
            case "木":
                day = 3
            case "金":
                day = 4
            case "土":
                day = 5
            case "日":
                day = 6
            default:
                day = -1
            }
            
            if !time_array[i].matches(pattern: "[2468]|10|12|14") {
                time_array[i] = "0"
            }
            
            whereText += "( weekday = \(day) and time = \(Int(time_array[i])! / 2) )"
            
            if i + 1 < weekday_array.count {
                whereText += " or "
            }
        }
        
        return " ( \(whereText) ) "
    }

}

class SyllabusData {
    
    var basic: [(String,String)]
    var detail: [(String,String)]
    var teachers: [(String,String)]
    var place: [(String,String)]
    
    init() {
        basic = []
        detail = []
        teachers = []
        place = []
    }
}
