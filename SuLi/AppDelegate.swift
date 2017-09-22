//
//  AppDelegate.swift
//  SuLi
//
//  Created by ssd_ch on 2017/04/30.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let initialTab = self.window!.rootViewController as? UITabBarController  {
            // 0が一番左のタブ
            initialTab.selectedIndex = 0 // 左から1つ目のタブを指定
        }
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/6300978111")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let updateInterval = "updateInterval"
        
        // UserDefaultsを使って時刻を保持する
        let userDefault = UserDefaults.standard
        
        // デフォルト値登録※すでに値が更新されていた場合は、更新後の値のままになる
        userDefault.register(defaults: [updateInterval: 0.0])
        userDefault.register(defaults: [SettingViewContoller.dataSync: true])
        userDefault.register(defaults: [SettingViewContoller.adsDisplay: true])
        
        let now = Date()
        let interval = now.timeIntervalSince1970 - userDefault.double(forKey: updateInterval)
        
        print("update interval : \(interval)")
        
        //1日以上データを更新してない場合はデータを取得する
        if interval >= 86400.0 && userDefault.bool(forKey: SettingViewContoller.dataSync) {
            self.getData(completeHandler: {
                userDefault.set(now.timeIntervalSince1970, forKey: updateInterval)
            })
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func getData(completeHandler: @escaping () -> ()){
        
        //インジケーターを表示
        let indicator = MyAlertController.indicator(title: NSLocalizedString("alert-indicator-title", comment: "読み込み中のアラートのタイトル"))
        self.window?.rootViewController?.present(indicator, animated: true, completion: nil)
        
        UpdateAllData.action(completeHandler: {
            indicator.dismiss(animated: true, completion: nil)
            completeHandler()
        }, errorHandler: { error in
            indicator.dismiss(animated: true, completion: nil)

            //アラートを作成
            let alert = UIAlertController(title: NSLocalizedString("alert-error-title", comment: "エラーアラートのタイトル"), message: NSLocalizedString("alert-failed-get-data", comment: "データ取得失敗のアラートメッセージ"), preferredStyle: UIAlertControllerStyle.alert)
            
            //OKボタンを作成
            let okAction = UIAlertAction(title: NSLocalizedString("alert-ok-button", comment: "OKボタンのテキスト"), style: UIAlertActionStyle.default){ (action: UIAlertAction) in
                //OKボタンが押された後、一度もデータの取得が成功していない場合は取得処理を繰り返す
                if UserDefaults.standard.double(forKey: "updateInterval") == 0.0 {
                    self.getData(completeHandler: completeHandler)
                }
            }
            //OKボタンを追加
            alert.addAction(okAction)
            
            //アラートを表示
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
}

