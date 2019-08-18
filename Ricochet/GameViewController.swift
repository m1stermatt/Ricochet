//
//  GameViewController.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-08.
//  Copyright © 2017 WamDev. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import StoreKit

extension Notification.Name {
    static let purchaseLevels = Notification.Name("levels")
    static let purchaseSkips = Notification.Name("skips")
    static let supportDevs = Notification.Name("support")
    static let restorePurchases = Notification.Name("restore")
    static let rate = Notification.Name("rate")
}

class GameViewController: UIViewController {
    
    var iAPHelper : IAPHelper!
    let UnlockLevels = RegisteredPurchase.UnlockLevels
    let SupportDevs = RegisteredPurchase.SupportDevs
    let Skips5 = RegisteredPurchase.Skips5
    
    var scene : GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        iAPHelper = IAPHelper(delegate: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseAllLevels(notification:)), name: .purchaseLevels, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseSkips(notification:)), name: .purchaseSkips, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(supportDevs(notification:)), name: .supportDevs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restorePurchases(notification:)), name: .restorePurchases, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rate(notification:)), name: .rate, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.ambient)))
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Could not play")
        }
        
        if let scene = GameScene(fileNamed:"GameScene") {
            self.scene = scene
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
            scene.setDelegate(self)
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}

// MARK: IAPHelperDelegate
extension GameViewController : IAPHelperDelegate {
    func showAlert(alert : UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func boughtAllLevels() {
        scene.unlockAllLevels()
    }
    
    func boughtSkips() {
        scene.addSkips()
    }
}

// MARK: Notifications
extension GameViewController {
    @objc func purchaseAllLevels(notification: NSNotification) {
        iAPHelper.purchase(purchase: UnlockLevels)
    }
    @objc func purchaseSkips(notification: NSNotification) {
        iAPHelper.purchase(purchase: Skips5)
    }
    @objc func supportDevs(notification: NSNotification) {
        iAPHelper.purchase(purchase: SupportDevs)
    }
    @objc func restorePurchases(notification: NSNotification) {
        iAPHelper.restorePurchases()
    }
    @objc func rate(notification: NSNotification) {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
        else {
            let ratePrompt = UIAlertController(title: NSLocalizedString("Rate rico.chet", comment: ""), message: nil, preferredStyle: UIAlertController.Style.alert)
            ratePrompt.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
                self.rateApp(appId: "id1360468944") { success in
                    print("RateApp \(success)")
                }
            }))
            ratePrompt.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            present(ratePrompt, animated: true, completion: nil)
        }
    }
}

// MARK: Rate
extension GameViewController {
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
}

// MARK: GameScene Delegate
extension GameViewController : GameSceneDelegate {
    func promptForPurchase() {
        let purchaseAlert = UIAlertController(title: NSLocalizedString("Purchase 5 Skips?", comment: ""), message: nil, preferredStyle: UIAlertController.Style.alert)
        purchaseAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            self.iAPHelper.purchase(purchase: self.Skips5)
        }))
        purchaseAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(purchaseAlert, animated: true, completion: nil)
    }
    
    func promptToSkip() {
        let skipAlert = UIAlertController(title: NSLocalizedString("Skip Level?", comment: ""), message: nil, preferredStyle: UIAlertController.Style.alert)
        skipAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            self.scene.skip()
        }))
        skipAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(skipAlert, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
