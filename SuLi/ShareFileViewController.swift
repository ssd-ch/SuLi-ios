//
//  ShareFileViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/26.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import TOSMBClient

class ShareFileViewController : UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var atPath = ""
    var destinationPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SMBSessionController.downloadTask = SMBSessionController.session?.downloadTaskForFile(atPath: self.atPath, destinationPath: nil, progressHandler: {(totalBytesWritten, totalBytesExpected) in
        },completionHandler: { filepath in
            print("ShareFileView : File was downloaded to \(filepath!)")
            //メインスレッドで呼び出す
            DispatchQueue.main.async {
                if let url = URL(string: filepath!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                    print("ShareFileView : webview load request")
                    let request = URLRequest(url: url)
                    self.webView.loadRequest(request)
                    
                    self.destinationPath = filepath!
                }
                else {
                    print("ShareFileView : invalidation url")
                }
            }
        }, failHandler: { error in
            print("ShareFileView : \(String(describing: error?.localizedDescription))")
        })
        SMBSessionController.downloadTask?.resume()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            do {
                try FileManager.default.removeItem(atPath: self.destinationPath)
                print("ShareFileView : delete \(self.destinationPath)")
            } catch {
                print("ShareFileView : failed delete \(self.destinationPath)")
            }
        }
    }
}
