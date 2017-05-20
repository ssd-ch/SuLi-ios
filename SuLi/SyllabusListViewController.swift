//
//  SyllabusListViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/04/30.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import SwiftHTTP
import Kanna

class SyllabusListViewController: UIViewController,UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SyllabusListDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedLink: String?
    var syllabus: SearchSyllabus?
    
    // セルに表示するテキスト
    var tableData : [SyllabusList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.searchBar.delegate = self

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //リロードデータ用デリゲートメソッド
    func reloadTableData(data: [SyllabusList], mode: Bool) {
        if(mode) {
            print("add data")
            self.tableData += data
        }
        else {
            self.tableData = data
        }
        self.tableView.reloadData()
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.searchBar.showsCancelButton = true
        self.syllabus = SearchSyllabus(self.searchBar.text!)
        self.syllabus?.delegate = self
        self.syllabus!.start()
        //self.tableView.reloadData()
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.view.endEditing(true)
        self.searchBar.text = ""
        //self.tableView.reloadData()
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        return true
    }

    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = tableData[indexPath.row].lecture
        cell.detailTextLabel?.text = tableData[indexPath.row].teacher
        return cell
    }
    
    // Segueで遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! SyllabusDetailViewController
            controller.link = tableData[indexPath.row].link
        }
    }
    
    //スクロールするたびに呼び出される
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height && tableView.isDragging {
            //一番下に来た時の処理
            print("end scroll")
            if(syllabus?.status())! {
                syllabus?.load()
            }
        }
    }
    
}

protocol SyllabusListDelegate {
    
    func reloadTableData(data: [SyllabusList], mode: Bool) -> Void
}

class SearchSyllabus {
    
    let URL = "http://gakumuweb1.shimane-u.ac.jp/shinwa/SYOutsideReferSearchList"
    let URLdomain = "http://gakumuweb1.shimane-u.ac.jp"
    let dispCnt: String = "100"
    var searchword: String
    var loadCount: Int
    var hitNum: Int
    var loadingStatus: Bool = true //true:ロード可, false: ロード中,これ以上追加読み込みするデータがない
    
    var delegate: SyllabusListDelegate?
    
    init(_ searchWord: String) {
        self.searchword = searchWord
        loadCount = 0
        hitNum = 0
    }
    
    func status() -> Bool {
        return self.loadingStatus
    }
    
    func start() {
        
        var resultData : [SyllabusList] = []
        
        do {
            self.loadingStatus = false
            let opt = try sjisHTTP.GET(self.URL, parameters: ["nendo": "2017","disp_cnt": dispCnt, "j_name": self.searchword, "s_cnt" : String(loadCount) ])
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                if let doc = HTML(html: response.data, encoding: .shiftJIS)?.css("body tr") {
                    if doc.count > 0 {
                        let cntText = (HTML(html: response.data, encoding: .shiftJIS)?.css("p")[0].text?.replaceAll(pattern: "(.*｜　全)|(件　｜.*)", with: ""))!
                        self.hitNum = Int(cntText)!
                        self.loadCount += doc.count-1
                        for i in 1..<doc.count {
                            let td_node = doc[i].css("td")
                            let lecture = (td_node[2].text?.replaceAll(pattern: "\n|(　／　.*)", with: ""))!
                            let teacher = td_node[3].text
                            let link = self.URLdomain + (td_node[2].css("a").first?["href"]!)!
                            resultData.append(SyllabusList(data: (lecture,teacher!,link)))
                        }
                        //メインスレッドで呼び出す
                        DispatchQueue.main.async {
                            self.delegate?.reloadTableData(data: resultData, mode: false)
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.delegate?.reloadTableData(data: resultData, mode: false)
                        }
                    }
                }
                if(self.hitNum > self.loadCount) {
                    //追加読み込み可の状態へ
                    self.loadingStatus = true
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    func load(){
        
        if(self.loadingStatus) {
            self.loadingStatus = false //ロード中
            
            var resultData : [SyllabusList] = []
            
            do {
                let opt = try sjisHTTP.GET(self.URL, parameters: [
                    "nendo": "2017",
                    "j_s_cd": "",
                    "kamokud_cd": "",
                    "j_name": self.searchword,
                    "j_name_eng": "",
                    "keyword": "",
                    "tantonm": "",
                    "yobi": "",
                    "jigen": "",
                    "disp_cnt": String(loadCount),
                    "s_cnt": self.dispCnt ])
                opt.start { response in
                    if let err = response.error {
                        print("error: \(err.localizedDescription)")
                        return //also notify app of failure as needed
                    }
                    if let doc = HTML(html: response.data, encoding: .shiftJIS)?.css("body tr") {
                        //print("opt finished: \(String(data: response.data, encoding: .shiftJIS))")
                        if doc.count > 0 {
                            let cntText = (HTML(html: response.data, encoding: .shiftJIS)?.css("p")[0].text?.replaceAll(pattern: "(.*｜　全)|(件　｜.*)", with: ""))!
                            self.hitNum = Int(cntText)!
                            self.loadCount += doc.count-1
                            for i in 1..<doc.count {
                                let td_node = doc[i].css("td")
                                let lecture = (td_node[2].text?.replaceAll(pattern: "\n|(　／　.*)", with: ""))!
                                let teacher = td_node[3].text
                                let link = self.URLdomain + (td_node[2].css("a").first?["href"]!)!
                                resultData.append(SyllabusList(data: (lecture,teacher!,link)))
                            }
                            //メインスレッドで呼び出す
                            DispatchQueue.main.async {
                                self.delegate?.reloadTableData(data: resultData, mode: true)
                            }
                        }else {
                            //print(response.description)
                            print("no data")
                        }
                    }
                    if(self.hitNum > self.loadCount) {
                        self.loadingStatus = true
                    }
                }
            } catch let error {
                print("got an error creating the request: \(error)")
            }
        }
    }
    
}

class SyllabusList {
    var lecture  = ""
    var teacher  = ""
    var link = ""
    
    init(data: (String,String,String)){
        lecture = data.0
        teacher = data.1
        link = data.2
    }
}

