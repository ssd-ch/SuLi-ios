//
//  UpdateAllData.swift
//  SuLi
//
//  Created by ssd_ch on 2017/09/10.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

struct UpdateAllData {
    
    static func action(completeHandler: @escaping () -> (), errorHandler: @escaping (String) -> ()) {
        
        print("UpdateAllData : start task")
        
        let dispatch = DispatchGroup()
        
        //3回のスレッド登録
        for _ in 1...3 {
            dispatch.enter()
        }
        
        var successFlag = true
        
        GetSyllabusForm.start(completeHandler: {
            dispatch.leave()
        }, errorHandler: { error in
            dispatch.leave()
            successFlag = false
        })
        
        GetClassroomDivide.start(completeHandler: {
            dispatch.leave()
        }, errorHandler: { error in
            dispatch.leave()
            successFlag = false
        })
        
        GetCancelInfo.start(completeHandler: {
            dispatch.leave()
        }, errorHandler: { error in
            dispatch.leave()
            successFlag = false
        })
        
        dispatch.notify(queue: DispatchQueue.main) {
            if successFlag {
                print("UpdateAllData : all task complete")
                completeHandler()
            }
            else {
                print("UpdateAllData : failed task")
                errorHandler("")
            }
        }
    }
    
    static func cancel() {
        print("UpdateAllData : canceled task")
    }
}
