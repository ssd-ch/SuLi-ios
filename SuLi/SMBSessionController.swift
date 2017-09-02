//
//  SMBSessionController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/31.
//  Copyright © 2017年 ssd. All rights reserved.
//

import TOSMBClient

struct SMBSessionController {
    
    //static変数にしないとメモリ解放されてEXC_BAD_ACCESSが発生する
    static var session: TOSMBSession?
    static var downloadTask: TOSMBSessionDownloadTask?
}

