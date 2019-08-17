//
//  Header.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-30.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

protocol HeaderDelegate : NSObjectProtocol {
    func changeLevel(to levelNumber: Int)
    func moveTopButtons(extra dis: CGFloat, to pos: CGFloat, flip: Bool)
    func closeTopButtons(to pos: CGFloat, flip: Bool)
    func invertControls()
    func changeRotateControl()
    func toggleSound()
    func toggleMusic()
    func changeDoubleTapSetting()
    func showScrollView()
    func hideScrollView()
}

class Header : SKNode {
    
    /* State */
    private var state = HeaderState.normal
    enum HeaderState {
        case normal, levels, settings, help, ad
    }
    
    /* Level */
    var levels : SKNode!
    private let ROWS = 8
    private let MAX_PER_PAGE = 40
    
    /* Setting */
    private var settings : SKNode!
    private var invertButton : SKButton!
    private var soundToggleButton : SKButton!
    private var musicToggleButton : SKButton!
    private var rotateControlButton : SKButton!
    private var doubleTapSettingButton : SKButton!
    
    /* Help */
    private var help : HelpDisplay!
    
    /* Ad Display */
    private var adDisplay : SKNode!
    
    /* Fortmatting Stuff */
    private var showSize : CGSize!
    private var expandSize : CGSize!
    private var headerHeight : CGFloat!
    private var levelDisplayShowHeight : CGFloat!
    private var displaceHeight : CGFloat!
    private var fontSize : CGFloat = 18
    private let SHOW_DISPLACEMENT : CGFloat = 1.1
    
    /* Delegate */
    weak var delegate : HeaderDelegate?
    
    init(size: CGSize, levelCount: Int, delegate: HeaderDelegate?) {
        super.init()
        
        isUserInteractionEnabled = true
        
        self.delegate = delegate
        
        var pageLabelFontSize : CGFloat = 14
        var buttonYStart : CGFloat = 25
        var buttonHeight : CGFloat = 30
        var buttonWidth : CGFloat = 180
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontSize = 36
            pageLabelFontSize = 28
            buttonYStart = 50
            buttonHeight = 60
            buttonWidth = 360
        }
        
        let statusBarHeight = Screen.statusBarHeight
        let backgroundColor = SKColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
        
        showSize = CGSize(width: size.width, height: size.height + statusBarHeight)
        expandSize = CGSize(width: showSize.width, height: showSize.height * SHOW_DISPLACEMENT)
        
        let header = SKSpriteNode(texture: nil, color: backgroundColor, size: CGSize(width: size.width, height: showSize.height * SHOW_DISPLACEMENT))
        header.position = CGPoint(x: header.size.width/2, y: header.size.height/2)
        header.zPosition = 13
        addChild(header)
        headerHeight = header.size.height
        
        let levelTexture = SKTexture(imageNamed: "levelButton")
        let levelTextureSelected = SKTexture(imageNamed: "levelButtonSelected")
        let levelButton = SKButton(defaultTexture: levelTexture, selectedTexture: levelTextureSelected, disabledTexture: levelTexture, size: levelTexture.size())
        levelButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(handleLevelsDisplay))
        levelButton.position = CGPoint(x: round((showSize.height - statusBarHeight) / 2), y: round((showSize.height - statusBarHeight) / 2))
        levelButton.zPosition = 14
        addChild(levelButton)
        
        let settingTexture = SKTexture(imageNamed: "settingButton")
        let settingTextureSelected = SKTexture(imageNamed: "settingButtonSelected")
        let settingButton = SKButton(defaultTexture: settingTexture, selectedTexture: settingTextureSelected, disabledTexture: settingTexture, size: settingTexture.size())
        settingButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(handleSettingsDisplay))
        settingButton.position = CGPoint(x: round(showSize.width - (showSize.height - statusBarHeight) / 2), y: levelButton.position.y)
        settingButton.zPosition = 14
        addChild(settingButton)
        
        let helpTexture = SKTexture(imageNamed: "helpButton")
        let helpTextureSelected = SKTexture(imageNamed: "helpButtonSelected")
        let helpButton = SKButton(defaultTexture: helpTexture, selectedTexture: helpTextureSelected, disabledTexture: helpTexture, size: helpTexture.size())
        helpButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(handleHelpDisplay))
        helpButton.position = CGPoint(x: (settingButton.position.x - levelButton.position.x) / 3 + levelButton.position.x, y: levelButton.position.y)
        helpButton.zPosition = 14
        addChild(helpButton)
        
        let adTexture = SKTexture(imageNamed: "moneyButton")
        let adTextureSelected = SKTexture(imageNamed: "moneyButtonSelected")
        let adButton = SKButton(defaultTexture: adTexture, selectedTexture: adTextureSelected, disabledTexture: nil, size: adTexture.size())
        adButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(handleAdDisplay))
        adButton.position = CGPoint(x: (settingButton.position.x - levelButton.position.x) / 3 * 2 + levelButton.position.x, y: levelButton.position.y)
        adButton.zPosition = 14
        addChild(adButton)
        
        levels = SKNode()
        
        let buttonSize = size.width/CGFloat(ROWS + 1)
        
        for i in 0..<levelCount {
            let levelButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonSize, height: buttonSize))
            levelButton.setButtonLabel(title: String(i+1), font: "Futura-Medium", fontSize: fontSize)
            levelButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(levelButtonClicked(sender:)))
            levelButton.name = String(i+1)
            levelButton.position = CGPoint(x: round(size.width * CGFloat(i / MAX_PER_PAGE) + CGFloat(i % ROWS + 1) * buttonSize),
                                           y: round(-CGFloat(i % MAX_PER_PAGE / ROWS + 1) * buttonSize))
            levelButton.zPosition = 1
            levelButton.isEnabled = false
            levels.addChild(levelButton)
        }
        
        let levelsBackground = SKSpriteNode(texture: nil,
                                            color: backgroundColor,
                                            size: CGSize(width: size.width * CGFloat((levelCount - 1) / MAX_PER_PAGE + 1),
                                                         height: (levels.calculateAccumulatedFrame().height + buttonSize) * SHOW_DISPLACEMENT))
        levelsBackground.zPosition = 0
        levelsBackground.position = CGPoint(x: levelsBackground.size.width/2, y: levelsBackground.size.height * 0.5 - levelsBackground.size.height / SHOW_DISPLACEMENT)
        levels.addChild(levelsBackground)
        
        for i in 0..<(levelCount - 1) / MAX_PER_PAGE + 1 {
            let pageLabel = SKLabelNode(text: NSLocalizedString("Page", comment: "") + ": \(i + 1)")
            pageLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
            pageLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            pageLabel.zPosition = 1
            pageLabel.fontColor = SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1)
            pageLabel.fontSize = pageLabelFontSize
            pageLabel.fontName = "Futura-Medium"
            pageLabel.position = CGPoint(x: size.width/2 + CGFloat(i) * size.width, y: -buttonSize/4)
            levels.addChild(pageLabel)
        }
        
        levels.zPosition = 1
        levels.position = CGPoint(x: 0, y: levels.calculateAccumulatedFrame().height / SHOW_DISPLACEMENT)
        levels.isHidden = true
        addChild(levels)
        
        levelDisplayShowHeight = levels.calculateAccumulatedFrame().height / SHOW_DISPLACEMENT
        
        settings = SKNode()
        
        let settingsBackground = SKSpriteNode(texture: nil,
                                              color: backgroundColor,
                                              size: CGSize(width: size.width,
                                                           height: (buttonYStart + buttonHeight * 8) * SHOW_DISPLACEMENT))
        settingsBackground.zPosition = 0
        settingsBackground.position = CGPoint(x: settingsBackground.size.width/2, y: settingsBackground.size.height * 0.5 - settingsBackground.size.height / SHOW_DISPLACEMENT)
        settings.addChild(settingsBackground)
        
        invertButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        invertButton.setButtonLabel(title: NSLocalizedString("Invert Controls", comment: "") + " \u{25A1}", font: "Futura-Medium", fontSize: fontSize)
        invertButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(invertControls))
        invertButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart)
        invertButton.zPosition = 1
        settings.addChild(invertButton)
        
        rotateControlButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        rotateControlButton.setButtonLabel(title: NSLocalizedString("Use Control Beam", comment: "") + " \u{25A1}", font: "Futura-Medium", fontSize: fontSize)
        rotateControlButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(changeRotateControl))
        rotateControlButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight)
        rotateControlButton.zPosition = 1
        settings.addChild(rotateControlButton)
        
        soundToggleButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        soundToggleButton.setButtonLabel(title: NSLocalizedString("Sound On", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        soundToggleButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(toggleSound))
        soundToggleButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight * 2)
        soundToggleButton.zPosition = 1
        settings.addChild(soundToggleButton)
        
        musicToggleButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        musicToggleButton.setButtonLabel(title: NSLocalizedString("Music On", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        musicToggleButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(toggleMusic))
        musicToggleButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight * 3)
        musicToggleButton.zPosition = 1
        settings.addChild(musicToggleButton)
        
        doubleTapSettingButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        doubleTapSettingButton.setButtonLabel(title: NSLocalizedString("Double Tap to Restart", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        doubleTapSettingButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(changeDoubleTapSetting))
        doubleTapSettingButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight * 4)
        doubleTapSettingButton.zPosition = 1
        settings.addChild(doubleTapSettingButton)
        
        let separator = SKSpriteNode(texture: nil, color: SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1), size: CGSize(width: size.width * 0.8, height: 1))
        separator.zPosition = 1
        separator.position = CGPoint(x: size.width / 2, y: -buttonYStart - buttonHeight * 5)
        settings.addChild(separator)
        
        let restorePurchasesButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        restorePurchasesButton.setButtonLabel(title: NSLocalizedString("Restore Purchases", comment: ""), font: "Futura-Medium", fontSize: fontSize)
        restorePurchasesButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(restoreAllPurchases))
        restorePurchasesButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight * 6)
        restorePurchasesButton.zPosition = 1
        settings.addChild(restorePurchasesButton)
        
        let rateButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        rateButton.setButtonLabel(title: NSLocalizedString("Rate 5 Stars", comment: ""), font: "Futura-Medium", fontSize: fontSize)
        rateButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(rate))
        rateButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight * 7)
        rateButton.zPosition = 1
        settings.addChild(rateButton)
        
        settings.zPosition = 5
        settings.position = CGPoint(x: 0, y: settings.calculateAccumulatedFrame().height / SHOW_DISPLACEMENT)
        settings.isHidden = true
        addChild(settings)
        
        help = HelpDisplay()
        help.zPosition = 8
        help.position = CGPoint(x: 0, y: help.getHeight())
        help.isHidden = true
        addChild(help)
        
        adDisplay = SKNode()
        adDisplay.zPosition = 10
        adDisplay.isHidden = true
        
        let moneyDisplayBackground = SKSpriteNode(texture: nil,
                                              color: backgroundColor,
                                              size: CGSize(width: size.width,
                                                           height: (buttonYStart + buttonHeight * 3) * SHOW_DISPLACEMENT))
        moneyDisplayBackground.zPosition = 0
        moneyDisplayBackground.position = CGPoint(x: moneyDisplayBackground.size.width/2, y: moneyDisplayBackground.size.height * 0.5 - moneyDisplayBackground.size.height / SHOW_DISPLACEMENT)
        adDisplay.addChild(moneyDisplayBackground)
        
        let supportButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        supportButton.setButtonLabel(title: NSLocalizedString("Support Devs", comment: "") + " - ", font: "Futura-Medium", fontSize: fontSize)
        supportButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(supportDevs))
        supportButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart)
        supportButton.zPosition = 1
        adDisplay.addChild(supportButton)
        
        let unlockLevelButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        unlockLevelButton.setButtonLabel(title: NSLocalizedString("Unlock All Levels", comment: "") + " - ", font: "Futura-Medium", fontSize: fontSize)
        unlockLevelButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(purchaseAllLevels))
        unlockLevelButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight)
        unlockLevelButton.zPosition = 1
        unlockLevelButton.name = "unlockLevelButton.name"
        adDisplay.addChild(unlockLevelButton)
        
        let skipLevelButton = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: CGSize(width: buttonWidth, height: buttonHeight))
        skipLevelButton.setButtonLabel(title: NSLocalizedString("Purchase Five Passes", comment: "") + " - ", font: "Futura-Medium", fontSize: fontSize)
        skipLevelButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(purchaseSkips))
        skipLevelButton.position = CGPoint(x: showSize.width / 2, y: -buttonYStart - buttonHeight * 2)
        skipLevelButton.zPosition = 1
        adDisplay.addChild(skipLevelButton)
        
        IAPHelper.showPrices(purchase : .SupportDevs, button: supportButton)
        IAPHelper.showPrices(purchase : .UnlockLevels, button: unlockLevelButton)
        IAPHelper.showPrices(purchase : .Skips5, button: skipLevelButton)
        
        adDisplay.position = CGPoint(x: 0, y: adDisplay.calculateAccumulatedFrame().height / SHOW_DISPLACEMENT)
        addChild(adDisplay)
        
        displaceHeight = adDisplay.calculateAccumulatedFrame().height / (SHOW_DISPLACEMENT * 10)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Objective-C Methods
extension Header {
    
    @objc func supportDevs() {
        NotificationCenter.default.post(name: .supportDevs, object: nil)
    }
    
    @objc func purchaseAllLevels() {
        NotificationCenter.default.post(name: .purchaseLevels, object: nil)
    }

    @objc func purchaseSkips() {
        NotificationCenter.default.post(name: .purchaseSkips, object: nil)
    }
    
    @objc func restoreAllPurchases() {
        NotificationCenter.default.post(name: .restorePurchases, object: nil)
    }
    
    @objc func rate() {
        NotificationCenter.default.post(name: .rate, object: nil)
    }
    
    @objc func invertControls() {
        delegate?.invertControls()
    }
    
    @objc func toggleSound() {
        delegate?.toggleSound()
    }
    
    @objc func toggleMusic() {
        delegate?.toggleMusic()
    }
    
    @objc func changeRotateControl() {
        delegate?.changeRotateControl()
    }
    
    @objc func changeDoubleTapSetting() {
        delegate?.changeDoubleTapSetting()
    }
    
    @objc func handleSettingsDisplay() {
        switch state {
        case .levels:
            delegate?.hideScrollView()
            hide(display: levels)
        case .help:
            help.reset()
            hide(display: help)
        case .ad:
            hide(display: adDisplay)
        case .settings:
            state = .normal
            hide(display: settings)
            return
        default: break
        }
        state = .settings
        show(display: settings)
    }
    
    @objc func handleHelpDisplay() {
        switch state {
        case .levels:
            delegate?.hideScrollView()
            hide(display: levels)
        case .settings:
            hide(display: settings)
        case .ad:
            hide(display: adDisplay)
        case .help:
            state = .normal
            help.reset()
            hide(display: help)
            return
        default: break
        }
        state = .help
        show(display: help)
        help.animate()
    }
    
    @objc func handleLevelsDisplay() {
        switch state {
        case .settings:
            hide(display: settings)
        case .help:
            help.reset()
            hide(display: help)
        case .ad:
            hide(display: adDisplay)
        case .levels:
            state = .normal
            hide(display: levels)
            delegate?.hideScrollView()
            return
        default: break
        }
        state = .levels
        show(display: levels)
        delegate?.showScrollView()
    }
    
    @objc func handleAdDisplay() {
        switch state {
        case .settings:
            hide(display: settings)
        case .help:
            help.reset()
            hide(display: help)
        case .levels:
            delegate?.hideScrollView()
            hide(display: levels)
        case .ad:
            state = .normal
            hide(display: adDisplay)
            return
        default: break
        }
        state = .ad
        show(display: adDisplay)
    }
    
    @objc func levelButtonClicked(sender: SKButton) {
        if state == .levels {
            delegate?.changeLevel(to: sender.getTextNumber() - 1)
        }
    }
}

// MARK: Public Methods
extension Header {
    
    func hide(display node: SKNode) {
        node.removeAllActions()
        let hide = SKAction.moveTo(y: node.calculateAccumulatedFrame().height / SHOW_DISPLACEMENT, duration: 0.4)
        hide.timingMode = SKActionTimingMode.easeOut
        let finish = SKAction.run {node.isHidden = true}
        let sequence = SKAction.sequence([hide, finish])
        node.run(sequence)
        delegate?.closeTopButtons(to: headerHeight / SHOW_DISPLACEMENT, flip: false)
    }
    
    func show(display node: SKNode) {
        let height = node.calculateAccumulatedFrame().height
        node.isHidden = false
        node.removeAllActions()
        let show1 = SKAction.moveTo(y: -displaceHeight, duration: 0.45)
        show1.timingMode = SKActionTimingMode.easeOut
        let show2 = SKAction.moveTo(y: 0, duration: 0.2)
        show2.timingMode = SKActionTimingMode.easeIn
        let sequence = SKAction.sequence([show1, show2])
        node.run(sequence)
        delegate?.moveTopButtons(extra: height / SHOW_DISPLACEMENT + displaceHeight + showSize.height,
                                 to: height / SHOW_DISPLACEMENT + showSize.height, flip: false)
    }
    
    func selectLevelButton(level: Int) {
        let levelButton = levels.childNode(withName: String(level))
        if levelButton is SKButton {
            (levelButton as! SKButton).setLabelColor(color: SKColor(red: 137.0/255, green: 203.0/255, blue: 140.0/255, alpha: 1))
        }
    }
    
    func unselectLevelButton(level: Int) {
        let levelButton = levels.childNode(withName: String(level))
        if levelButton is SKButton {
            (levelButton as! SKButton).setLabelColor(color: SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1))
        }
    }
    
    func invertButtonDidChange(inverted: Bool) {
        if inverted {
            invertButton.setButtonLabel(title: NSLocalizedString("Invert Controls", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        }
        else {
            invertButton.setButtonLabel(title: NSLocalizedString("Invert Controls", comment: "") + " \u{25A1}", font: "Futura-Medium", fontSize: fontSize)
        }
    }
    
    func soundToggleDidChange(isSound: Bool) {
        if isSound {
            soundToggleButton.setButtonLabel(title: NSLocalizedString("Sound On", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        }
        else {
            soundToggleButton.setButtonLabel(title: NSLocalizedString("Sound On", comment: "") + " \u{25A1}", font: "Futura-Medium", fontSize: fontSize)
        }
    }
    
    func musicToggleDidChange(isMusic: Bool) {
        if isMusic {
            musicToggleButton.setButtonLabel(title: NSLocalizedString("Music On", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        }
        else {
            musicToggleButton.setButtonLabel(title: NSLocalizedString("Music On", comment: "") + " \u{25A1}", font: "Futura-Medium", fontSize: fontSize)
        }
    }
    
    func rotateControlSettingChange(uses: Bool) {
        if uses {
            rotateControlButton.setButtonLabel(title: NSLocalizedString("Use Control Beam", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        }
        else {
            rotateControlButton.setButtonLabel(title: NSLocalizedString("Use Control Beam", comment: "") + " \u{25A1}", font: "Futura-Medium", fontSize: fontSize)
        }
    }
    
    func doubleTapControlSettingChange(yes: Bool) {
        if yes {
            doubleTapSettingButton.setButtonLabel(title: NSLocalizedString("Double Tap to Restart", comment: "") + " \u{25A0}", font: "Futura-Medium", fontSize: fontSize)
        }
        else {
            doubleTapSettingButton.setButtonLabel(title: NSLocalizedString("Double Tap to Restart", comment: "") + " \u{25A1}", font: "Futura-Medium", fontSize: fontSize)
        }
    }
    
    func hiding() {
        switch state {
        case .levels: handleLevelsDisplay()
        case .settings: handleSettingsDisplay()
        case .help: handleHelpDisplay()
        case .ad: handleAdDisplay()
        default: break
        }
    }
    
    func unlockLevel(_ number: Int) {
        let levelButton = levels.childNode(withName: String(number + 1))
        if levelButton is SKButton {
            (levelButton as! SKButton).isEnabled = true
        }
    }
    
    func unlockLevels(_ number: Int) {
        for levelButton in levels.children {
            if levelButton is SKButton {
                if Int(levelButton.name!)! <= number + 1 {
                    (levelButton as! SKButton).isEnabled = true
                }
            }
        }
    }
    
    func unlockAllLevels() {
        for levelButton in levels.children {
            if levelButton is SKButton {
                (levelButton as! SKButton).isEnabled = true
            }
        }
    }
    
    func getShowSize() -> CGSize {
        return showSize
    }
    
    func getExpandSize() -> CGSize {
        return expandSize
    }
    
    func getHeaderHeight() -> CGFloat {
        return headerHeight
    }
    
    func getLevelDisplayShowHeight() -> CGFloat {
        return levelDisplayShowHeight
    }
    
    func getLevelsPerPage() -> Int {
        return MAX_PER_PAGE
    }
    
}
