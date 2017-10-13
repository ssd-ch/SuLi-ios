//
//  UpdateAllData.swift
//  SuLi
//
//  Created by ssd_ch on 2017/09/10.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

struct UpdateAllData {
    
    private static var successFlag : Bool!
    private static var status : Bool = true
    private static var dispatch : DispatchGroup!
    private static var dispatchCount : Int = 0
    
    static func action(completeHandler: @escaping () -> (), errorHandler: @escaping (String) -> ()) {
        
        print("UpdateAllData : start task")
        
        if self.status {
            
            self.status = false
            self.dispatchCount = 3
            
            self.dispatch = DispatchGroup()
            
            //3回のスレッド登録
            for _ in 1...self.dispatchCount {
                self.dispatch.enter()
            }
            
            self.successFlag = true
            
            let completeClosure = { () -> () in
                self.dispatch.leave()
                self.dispatchCount -= 1
            }
            
            let errorClosure = { () -> () in
                self.dispatch.leave()
                self.dispatchCount -= 1
                self.successFlag = false
            }
            
            GetSyllabusForm.start(completeHandler: {
                completeClosure()
            }, errorHandler: { error in
                errorClosure()
            })
            
            GetClassroomDivide.start(completeHandler: {
                completeClosure()
            }, errorHandler: { error in
                errorClosure()
            })
            
            GetCancelInfo.start(completeHandler: {
                completeClosure()
            }, errorHandler: { error in
                errorClosure()
            })
            
            dispatch.notify(queue: DispatchQueue.main) {
                
                self.status = true
                
                if self.successFlag! {
                    print("UpdateAllData : all task complete")
                    completeHandler()
                }
                else {
                    print("UpdateAllData : failed task")
                    errorHandler("")
                }
            }
        }
    }
    
    static func cancel() {
        print("UpdateAllData : canceled task")
        if !self.status {
            self.successFlag = false
            GetSyllabusForm.cancel()
            GetCancelInfo.cancel()
            GetClassroomDivide.cancel()
            for _ in 1...self.dispatchCount {
                self.dispatch.leave()
            }
        }
    }
}
