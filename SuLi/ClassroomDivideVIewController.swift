//
//  ClassroomDivideVIewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ClassroomDivideViewContoroller: ButtonBarPagerTabStripViewController {
    
    //タブのボタンのテキスト
    let week = ["MON", "TUE", "WED", "THU", "FRI"]
    
    //リロードボタンが押された時の処理
    @IBAction func pushReloadButton(_ sender: Any) {
        
        for view in super.viewControllers as! [ClassroomDivideChildViewController] {
            //データの更新をロックする
            view.rockAccess()
        }
        
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
            childView.weekday = i
            childViewControllers.append(childView)
        }
        return childViewControllers
    }
}
