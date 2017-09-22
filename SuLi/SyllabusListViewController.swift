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
import RealmSwift
import GoogleMobileAds

class SyllabusListViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SyllabusListDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    private var syllabus: SearchSyllabus?
    
    // セルに表示するテキスト
    var tableData : [SyllabusList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.searchBar.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //ナビゲーションバーの下線をなくす
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //検索バーの枠線をなくす
        self.searchBar.layer.borderColor = self.searchBar.barTintColor?.cgColor
        self.searchBar.layer.borderWidth = 1.0
        
        //検索バーのテキストフィールドのカーソルの色を変える
        UITextField.appearance(whenContainedInInstancesOf: [SyllabusListViewController.self]).tintColor = self.searchBar.barTintColor
        
        //バナー広告
        self.bannerView.adUnitID = NSLocalizedString("banner-id", tableName: "ResourceAddress", comment: "バナーID")
        self.bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "17a73169a9326a325c38836f01f7624c"]
        self.bannerView.load(request)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SyllabusListViewController : load display")
        
        //バナー広告
        if UserDefaults.standard.bool(forKey: SettingViewContoller.adsDisplay) {
            self.bannerView.isAutoloadEnabled = true
            self.bannerViewHeightConstraint.constant = 50
            self.bannerView.isHidden = false
        }
        else {
            self.bannerView.isAutoloadEnabled = false
            self.bannerViewHeightConstraint.constant = 0
            self.bannerView.isHidden = true
        }
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("SyllabusListViewController : \(error.localizedDescription)")
        self.bannerViewHeightConstraint.constant = 0
        self.bannerView.isHidden = true
    }
    
    //リロードデータ用デリゲートメソッド
    func reloadTableData(data: [SyllabusList], mode: Bool) {
        if(mode) {
            self.tableData += data
        }
        else {
            self.tableData = data
            if data.count == 0 {
                DispatchQueue.main.async {
                    //アラートを作成
                    let alert = MyAlertController.action(title: NSLocalizedString("alert-syllabus-title", comment: "シラバス検索結果のタイトル"), message: NSLocalizedString("alert-syllabus-not-found", comment: "シラバス検索結果0のメッセージ"))
                    //アラートを表示
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        //メインスレッドで呼び出す
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //エラー用デリゲートメソッド
    func errorHandler(message: String) {
        DispatchQueue.main.async {
            //アラートを作成
            let alert = MyAlertController.action(title: NSLocalizedString("alert-error-title", comment: "エラーアラートのタイトル"), message: message)
            //アラートを表示
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.searchBar.showsCancelButton = true
        self.syllabus = SearchSyllabus(self.searchBar.text!)
        self.syllabus?.delegate = self
        self.syllabus!.load(addMode: false)
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
    
    // セルの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    // セルの内容を返す
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
            if syllabus != nil {
                if syllabus!.loadingStatus {
                    syllabus!.load(addMode: true)
                }
            }
        }
    }
    
}

protocol SyllabusListDelegate {
    
    func reloadTableData(data: [SyllabusList], mode: Bool) -> Void
    func errorHandler(message: String) -> Void
}

class SearchSyllabus {
    
    let URL = NSLocalizedString("syllabus-search", tableName: "ResourceAddress", comment: "シラバスの検索結果のURL")
    let URLdomain = NSLocalizedString("syllabus-domain", tableName: "ResourceAddress", comment: "シラバスの検索ページのドメイン")
    let dispCnt: String = "100"
    let searchForm = try! Realm().objects(SyllabusForm.self)
    var searchword: String
    var loadCount: Int
    var hitNum: Int
    var loadingStatus: Bool = true //true:ロード可, false: ロード中,これ以上追加読み込みするデータがない
    
    var delegate: SyllabusListDelegate?
    
    init(_ searchWord: String) {
        self.searchword = searchWord
        self.loadCount = 0
        self.hitNum = 0
    }
    
    func load(addMode: Bool){
        
        if self.searchForm.count == 0 {
            self.delegate?.errorHandler(message: NSLocalizedString("alert-syllabus-form-not-found", comment: "シラバスのフォームデータが取得されていない時のメッセージ"))
            return
        }
        
        if(self.loadingStatus) {
            self.loadingStatus = false //ロード中
            
            var resultData : [SyllabusList] = []
            
            do {
                let opt = try sjisHTTP.GET(self.URL, parameters: [
                    "nendo": self.searchForm.filter("form = 'nendo'").first!.value,
                    "j_s_cd": "",
                    "kamokud_cd": "",
                    "j_name": self.searchword,
                    "j_name_eng": "",
                    "keyword": "",
                    "tantonm": "",
                    "yobi": "",
                    "jigen": "",
                    "disp_cnt": self.dispCnt,
                    "s_cnt": String(self.loadCount) ])
                opt.start { response in
                    if let err = response.error {
                        print("Search Syllabus : failed. \(err.localizedDescription)")
                        self.delegate!.errorHandler(message: err.localizedDescription)
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
                        }else {
                            //print(response.description)
                            print("Search Syllabus : no syllabus found")
                        }
                        self.delegate?.reloadTableData(data: resultData, mode: addMode)
                    }
                    if(self.hitNum > self.loadCount) {
                        self.loadingStatus = true
                    }
                }
            } catch let error {
                print("got an error creating the request: \(error)")
                self.delegate!.errorHandler(message: error.localizedDescription)
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

