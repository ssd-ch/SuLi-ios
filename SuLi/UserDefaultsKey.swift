//
//  UserDefaultsKey.swift
//  SuLi
//
//  Created by ssd_ch on 2017/10/07.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation

struct UserDefaultsKey {
    
    //初期取得処理
    static let firstLaunch = "firstLaunch"
    
    //データ同期のインターバル
    static let syllabusUpdateInterval = "syllabusUpdateInterval"
    static let classroomDivideUpdateInterval = "classroomDivideUpdateInterval"
    static let noticeUpdateInterval = "noticeUpdateInterval"
    
    //設定の状態を取得するためのキー
    static let dataSync = "dataSync"
    static let adsDisplay = "adsDisplay"
}
