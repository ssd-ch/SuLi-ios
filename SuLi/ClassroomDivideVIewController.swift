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
    
    let week = ["MON", "TUE", "WED", "THU", "FRI"]
 
    @IBAction func pushReloadButton(_ sender: Any) {
        GetClassroomList.start()
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
        //管理されるViewControllerを返す処理
        var childViewControllers:[UIViewController] = []
        for text in week {
            let childView = UIStoryboard(name: "ClassroomDivide", bundle: nil).instantiateViewController(withIdentifier: "Child") as! ClassroomDivideChildViewController
            childView.itemTitle = text
            childViewControllers.append(childView)
        }
        return childViewControllers
    }
}
