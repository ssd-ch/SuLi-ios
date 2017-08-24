//
//  WorkFolderLoginView.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import TOSMBClient

class WorkFolderLoginViewContoller : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.idTextField.delegate = self
        self.passwordTextField.delegate = self
        
        //パスワード表示にする
        self.passwordTextField.isSecureTextEntry = true
    }
    
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを隠す
        self.idTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        return true
    }
    
    // Segueで遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let controller = segue.destination as! WorkFolderViewContoller
        controller.id = self.idTextField.text!
        controller.password = self.passwordTextField.text!
    }
}
