//
//  MyAlertController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/09/08.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class MyAlertController {
    
    static func action(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //OKボタンを作成
        let okAction = UIAlertAction(title: NSLocalizedString("alert-ok-button", comment: "OKボタンのテキスト"), style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            //OKボタンが押された時の処理
            //print("Tap OK button")
        }
        
        //OKボタンを追加
        alertController.addAction(okAction)
        
        return alertController
    }
}
