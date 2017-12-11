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
    private static let dispatchCount : Int = 3
    private static var semaphore : DispatchSemaphore!
    
    static func action(completeHandler: @escaping () -> (), errorHandler: @escaping (String) -> ()) {
        
        print("UpdateAllData : start task")
        
        if self.status {
            
            self.status = false

            self.semaphore = DispatchSemaphore(value: 0)
            
            self.successFlag = true
            
            let completeClosure = { () -> () in
                print("UpdateAllData : semaphore signal")
                self.semaphore.signal()
            }
            
            let errorClosure = { () -> () in
                print("UpdateAllData : semaphore signal (error)")
                self.successFlag = false
                self.semaphore.signal()
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
            
            //別スレッドでセマフォを待つ
            DispatchQueue.global(qos: .default).async {
                //signalを3回待つ
                for _ in 1...self.dispatchCount {
                    self.semaphore.wait()
                }
                
                if self.successFlag! {
                    print("UpdateAllData : all task complete")
                    completeHandler()
                }
                else {
                    print("UpdateAllData : failed task")
                    errorHandler("")
                }
                
                self.status = true
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
                print("UpdateAllData : semaphore signal (cancel)")
                self.semaphore.signal()
            }
        }
    }
}
