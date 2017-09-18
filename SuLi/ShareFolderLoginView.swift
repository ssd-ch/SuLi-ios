//
//  ShareFolderLoginView.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import TOSMBClient
import GoogleMobileAds

class ShareFolderLoginViewContoller : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    private let host = NSLocalizedString("shareStorage-hostName", tableName: "ResourceAddress", comment: "共有ストレージのホスト名")
    private let ip = NSLocalizedString("shareStorage-ip", tableName: "ResourceAddress", comment: "共有ストレージのホスト名")
    private let domain = NSLocalizedString("shareStorage-domain", tableName: "ResourceAddress", comment: "共有ストレージのドメイン名")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.idTextField.delegate = self
        self.passwordTextField.delegate = self
        
        //パスワード表示にする
        self.passwordTextField.isSecureTextEntry = true
        
        //バナー広告
        self.bannerView.adUnitID = NSLocalizedString("banner-id", tableName: "ResourceAddress", comment: "バナーID")
        self.bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "17a73169a9326a325c38836f01f7624c"]
        self.bannerView.load(request)
    }
    
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを隠す
        self.idTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func pushLoginButton(_ sender: Any) {
        
        //DNSを逆引きする
        let host = CFHostCreateWithName(nil, self.domain as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? NSData {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                //IPアドレスが解決できたので遷移を許可する
                let numAddress = String(cString: hostname)
                print("resolved host address \(numAddress)")
                SMBSessionController.session = TOSMBSession(hostName: self.host, ipAddress: numAddress)
                SMBSessionController.session?.setLoginCredentialsWithUserName(self.idTextField.text!, password: self.passwordTextField.text!)
                SMBSessionController.session?.requestContentsOfDirectory(atFilePath: "/", success: { d in
                    DispatchQueue.main.async {
                        let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShareFolderView") as! ShareFolderViewContoller
                        nextViewController.navigationItem.title = "work"
                        self.show(nextViewController, sender: nil)
                    }
                }, error: { error in
                    print(error!.localizedDescription)
                    //アラートを作成
                    let alert = MyAlertController.action(title: NSLocalizedString("alert-error-title", comment: "エラーアラートのタイトル"), message: error!.localizedDescription)
                    //アラートを表示
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
        else {
            print("can't resolve smb server address")
            //アラートを作成
            let alert = MyAlertController.action(title: NSLocalizedString("alert-error-title", comment: "エラーアラートのタイトル"), message: NSLocalizedString("alert-error-server-not-found", comment: "サーバーが見つからない時のメッセージ"))
            //アラートを表示
            self.present(alert, animated: true, completion: nil)
        }
        
    }

}
