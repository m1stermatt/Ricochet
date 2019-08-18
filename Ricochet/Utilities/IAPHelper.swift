//
//  IAPHelper.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-06-11.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

enum RegisteredPurchase : String {
    case UnlockLevels = "UnlockLevels"
    case SupportDevs = "SupportDevs"
    case Skips5 = "Skips"
}

protocol IAPHelperDelegate : NSObjectProtocol {
    func showAlert(alert: UIAlertController)
    func boughtAllLevels()
    func boughtSkips()
}

class IAPHelper {
    
    let bundleID = "ca.wamdev.Ricochet"
    
    weak var delegate : IAPHelperDelegate?
    
    init(delegate: IAPHelperDelegate?) {
        self.delegate = delegate
    }
    
    static func showPrices(purchase : RegisteredPurchase, button: SKButton) {
        NetworkActivityIndicatorManager.started()
        SwiftyStoreKit.retrieveProductsInfo(["ca.wamdev.Ricochet." + purchase.rawValue]) { result in
            
            if let product = result.retrievedProducts.first {
                let numberFormatter = NumberFormatter()
                let price = product.price
                let locale = product.priceLocale
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = locale
                let formattedText = numberFormatter.string(from: price)
                button.setText(button.getText() + formattedText!)
            }
        }
    }
    
    func purchase(purchase : RegisteredPurchase) {
        NetworkActivityIndicatorManager.started()
        SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue, completion: {
            result in
            NetworkActivityIndicatorManager.finished()
            
            if case .success(let product) = result {
                
                if product.productId == self.bundleID + "." + "UnlockLevels" {
                    self.delegate?.boughtAllLevels()
                }
                
                if product.productId == self.bundleID + "." + "Skips" {
                    self.delegate?.boughtSkips()
                }
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                
                self.delegate?.showAlert(alert: self.alertForPurchaseResult(result: result))
            }
        })
    }
    
    func restorePurchases() {
        NetworkActivityIndicatorManager.started()
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            NetworkActivityIndicatorManager.finished()
            
            for product in result.restoredPurchases {
                
                if product.productId == self.bundleID + "." + "UnlockLevels" {
                    self.delegate?.boughtAllLevels()
                }
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            self.delegate?.showAlert(alert: self.alertForRestorePurchases(result: result))
        })
    }
}

/// MARK: Alert Methods
extension IAPHelper {
    
    func alertWithTitle(title : String, message : String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func alertForPurchaseResult(result : PurchaseResult) -> UIAlertController {
        switch result {
        case .success(let product):
            print("Purchase Succesful: \(product.productId)")
            return alertWithTitle(title: "Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown:
                if (error as NSError).domain == SKErrorDomain {
                    return alertWithTitle(title: "Purchase Failed", message: "Check your internet connection or try again later")
                }
                else {
                    return alertWithTitle(title: "Purchase Failed", message: "Unknown Error")
                }
            case .clientInvalid:
                return alertWithTitle(title: "Purchase Failed", message: "You are not allowed to make payments")
            case .paymentCancelled:
                return alertWithTitle(title: "Purchase Failed", message: "Payment Cancelled")
            case .paymentInvalid:
                return alertWithTitle(title: "Purchase Failed", message: "Payment Invalid")
            case .paymentNotAllowed:
                return alertWithTitle(title: "Purchase Failed", message: "You are not authorized to make payments")
            case .storeProductNotAvailable:
                return alertWithTitle(title: "Purchase Failed", message: "This product is unavailable")
            case .cloudServicePermissionDenied:
                return alertWithTitle(title: "Purchase Failed", message: "Cloud Service Permission Denied")
            case .cloudServiceNetworkConnectionFailed:
                return alertWithTitle(title: "Purchase Failed", message: "Cloud Service Network Connected Failed")
            case .cloudServiceRevoked:
                return alertWithTitle(title: "Purchase Failed", message: "Cloud Service Revoked")
            default:
                return alertWithTitle(title: "Purchase Failed", message: "Error")
            }
        }
    }
    
    func alertForRestorePurchases(result : RestoreResults) -> UIAlertController {
        if result.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(result.restoreFailedPurchases)")
            return alertWithTitle(title: "Restore Failed", message: "Unknown Error")
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: "Purchases Restored", message: "All purchases have been restored")
        }
        else {
            return alertWithTitle(title: "Nothing To Restore", message: "No previous purchases were made")
        }
    }
}
