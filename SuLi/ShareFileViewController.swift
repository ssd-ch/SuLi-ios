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
    @IBOutlet weak var progressView: UIProgressView!
    
    var atPath = ""
    var destinationPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //プログレスバーを0にセットする
        self.progressView.setProgress(0.0, animated: false)
        
        SMBSessionController.downloadTask = SMBSessionController.session?.downloadTaskForFile(atPath: self.atPath, destinationPath: nil, progressHandler: {(totalBytesWritten, totalBytesExpected) in
            let progress = Float(totalBytesWritten) / Float(totalBytesExpected)
            print("ShareFileView : downloaded " + String(format: "%.2f", progress * 100) + "%")
            DispatchQueue.main.async {
                self.progressView.setProgress(progress, animated: true)
            }
        },completionHandler: { filepath in
            print("ShareFileView : File was downloaded to \(filepath!)")
            //メインスレッドで呼び出す
            DispatchQueue.main.async {
                if let url = URL(string: filepath!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                    print("ShareFileView : webview load request")
                    let request = URLRequest(url: url)
                    self.webView.loadRequest(request)
                    
                    self.destinationPath = filepath!
                    
                    //プログレスバーを隠す
                    self.progressView.isHidden = true
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
