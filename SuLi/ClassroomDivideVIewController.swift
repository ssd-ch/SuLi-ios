//
//  ClassroomDivideVIewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RealmSwift

class ClassroomDivideViewContoroller: ButtonBarPagerTabStripViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var progressView: UIProgressView!
    
    //タブのボタンのテキスト
    let week = [NSLocalizedString("classroom-tab-Monday", comment: "教室配当表のタブ名:月曜日"),
                NSLocalizedString("classroom-tab-Tuesday", comment: "教室配当表のタブ名:火曜日"),
                NSLocalizedString("classroom-tab-Wednesday", comment: "教室配当表のタブ名:水曜日"),
                NSLocalizedString("classroom-tab-Thursday", comment: "教室配当表のタブ名:木曜日"),
                NSLocalizedString("classroom-tab-Friday", comment: "教室配当表のタブ名:金曜日")]
    
    //Buildingオブジェクト
    let building = try! Realm().objects(Building.self)
    
    //表示する配当表のbulding_id
    var buildingId = ClassroomDivideChildViewController.allData
    
    //リロードボタンが押された時の処理
    @IBAction func pushReloadButton(_ sender: Any) {
        
        for view in super.viewControllers as! [ClassroomDivideChildViewController] {
            //データの更新をロックする
            view.rockAccess()
        }
        
        //プログレスバーを表示、0.1にセット
        self.progressView.setProgress(0.1, animated: false)
        self.progressView.isHidden = false
        
        //スレッドを管理するグループを作成
        var groupDispatch = DispatchGroup()
        
        //スレッドの登録
        groupDispatch.enter()
        
        //処理が完了したら通知させるディスパッチを参照で渡して更新処理を始める
        GetClassroomDivide.start(groupDispatch: &groupDispatch)
        
        //処理が完了したらの各ビューのデータを更新
        groupDispatch.notify(queue: DispatchQueue.main) {
            for view in super.viewControllers as! [ClassroomDivideChildViewController] {
                //各ビューのデータを更新
                view.updateData()
            }
            //pickerViewの更新
            self.pickerView.reloadAllComponents()
            
            self.progressView.setProgress(1.0, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.progressView.isHidden = true
            }
        }
    }
    
    //建物選択ボタンが押された時の処理
    @IBAction func pushBuildingType(_ sender: Any) {
        //ピッカーを表示・非表示を切り替える
        if self.pickerView.isHidden {
            self.pickerView.isHidden = false
        }
        else {
            self.pickerView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.white
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = UIColor(red: 254/255, green: 0, blue: 124/255, alpha: 1)
        super.viewDidLoad()
        
        //ピッカーのデリゲートを設定して非表示にする
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.isHidden = true
        
        self.progressView.isHidden = true
        //最前面に表示(storyboardでは前面にしているがタブバーが前面に表示されるので)
        self.view.bringSubview(toFront: self.progressView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理するViewControllerを返す処理
        var childViewControllers:[UIViewController] = []
        for (i,text) in week.enumerated() {
            let childView = UIStoryboard(name: "ClassroomDivide", bundle: nil).instantiateViewController(withIdentifier: "Child") as! ClassroomDivideChildViewController
            childView.itemTitle = text
            childView.buildingId = self.buildingId
            childView.weekday = i
            childViewControllers.append(childView)
        }
        return childViewControllers
    }
    
    //picerviewの列数を返す
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //pickerViewの行数を返す
    func pickerView(_ namePickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.building.count + 1
    }
    
    //pickerViewの要素を返す
    func pickerView(_ namePickerview: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String? {
        if row == 0 {
            return NSLocalizedString("classroomDivide-buildingType-all", comment: "教室配当表の建物:全て")
        }
        else {
            return self.building[row - 1].building_name
        }
    }
    
    //pickerViewで選択した時の処理
    func pickerView(_ namePickerview: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if row == 0 {
            self.buildingId = ClassroomDivideChildViewController.allData
            print("ClassroomDivideViewContoroller : All data selected")
        }
        else {
            self.buildingId = self.building[row - 1].id
            print("ClassroomDivideViewContoroller : building_id : \(self.building[row - 1].id) selected")
        }
        
        //データの更新
        for view in super.viewControllers as! [ClassroomDivideChildViewController] {
            //building_idの設定
            view.buildingId = self.buildingId
            //各ビューのデータを更新
            view.updateData()
        }
    }
}
