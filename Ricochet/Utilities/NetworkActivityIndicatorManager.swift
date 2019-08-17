//
//  NetworkActivityIndicatorManager.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-06-11.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import StoreKit

class NetworkActivityIndicatorManager : NSObject {
    
    private static var loadingCount = 0
    
    class func started() {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    class func finished(){
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
