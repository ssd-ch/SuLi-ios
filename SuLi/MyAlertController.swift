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
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        //OKボタンを作成
        let okAction = UIAlertAction(title: NSLocalizedString("alert-ok-button", comment: "OKボタンのテキスト"), style: UIAlertAction.Style.default){ (action: UIAlertAction) in
            //OKボタンが押された時の処理
            //print("Tap OK button")
        }
        
        //OKボタンを追加
        alertController.addAction(okAction)
        
        return alertController
    }
    
    static func cancel(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        //キャンセルボタンを作成
        let cancelAction = UIAlertAction(title: NSLocalizedString("alert-cancel-button", comment: "キャンセルボタンのテキスト"), style: UIAlertAction.Style.cancel){ (action: UIAlertAction) in
            //キャンセルボタンが押された時の処理
            //print("Tap cancel button")
        }
        
        //キャンセルボタンを追加
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    static func indicator(title: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: "\n", preferredStyle: UIAlertController.Style.alert)
        
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        
        let views: [String: UIView] = ["alert": alert.view, "indicator": indicator]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(12)-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: [], metrics: nil, views: views)
        alert.view.addConstraints(constraints)
        
        indicator.isUserInteractionEnabled = false
        indicator.color = UIColor.lightGray
        indicator.startAnimating()
        
        return alert
    }
    
    static func cancelIndicator(title: String, cancelHandler: @escaping () -> ()) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: "\n", preferredStyle: UIAlertController.Style.alert)
        
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("alert-cancel-button", comment: "キャンセルボタンのテキスト"), style: UIAlertAction.Style.cancel){ (action: UIAlertAction) in
            cancelHandler()
        }
        alert.addAction(cancelAction)
        
        let views: [String: UIView] = ["alert": alert.view, "indicator": indicator]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(53)-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: [], metrics: nil, views: views)
        alert.view.addConstraints(constraints)
        
        indicator.isUserInteractionEnabled = false
        indicator.color = UIColor.lightGray
        indicator.startAnimating()
        
        return alert
    }
}
