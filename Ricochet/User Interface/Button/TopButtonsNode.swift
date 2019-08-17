//
//  TopButtonsNode.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-06-12.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

protocol TopButtonsNodeDelegate : NSObjectProtocol {
    func handleHeader()
    func restartGame()
    func skipLevel()
}

class TopButtonsNode : SKNode {
    
    private var headerButton : SKButton!
    private var restartButton : SKButton!
    private var skipButton : SKButton!
    private var skipLabel : SKLabelNode!
    
    private var originalY : CGFloat!
    
    weak var delegate : TopButtonsNodeDelegate?
    
    init(delegate: TopButtonsNodeDelegate?, offset: CGFloat) {
        super.init()
        
        self.delegate = delegate
        
        originalY = Screen.height - Screen.statusBarHeight
        
        let arrowTexture = SKTexture(imageNamed: "arrowButton")
        let arrowTextureSelected = SKTexture(imageNamed: "arrowButtonSelected")
        
        headerButton = SKButton(defaultTexture: arrowTexture,
                                selectedTexture: arrowTextureSelected,
                                disabledTexture: arrowTexture,
                                size: CGSize(width: arrowTexture.size().width*0.8, height: arrowTexture.size().height*0.8))
        headerButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(handleHeader))
        headerButton.position = CGPoint(x: round(Screen.width - Screen.statusBarHeight/2 - offset),
                                        y: -offset)
        headerButton.zPosition = 0
        self.addChild(headerButton)
        
        let restartTexture = SKTexture(imageNamed: "restartButton")
        let restartTextureSelected = SKTexture(imageNamed: "restartButtonSelected")
        restartButton = SKButton(defaultTexture: restartTexture, selectedTexture: restartTextureSelected, disabledTexture: restartTexture, size: restartTexture.size())
        let restartButtonYPos1 = restartButton.size.height - headerButton.size.height
        let restartButtonYPos2 = restartButtonYPos1 * 0.5 / restartButton.size.height + 0.5
        restartButton.anchorPoint = CGPoint(x: 0.5, y: round(restartButtonYPos2 * 100)/100)
        restartButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(restartGame))
        restartButton.position = CGPoint(x: round(Screen.width - (headerButton.position.x + headerButton.size.width/2) + restartButton.size.width/2),
                                         y: -offset)
        restartButton.zPosition = 0
        addChild(restartButton)
        
        let skipTexture = SKTexture(imageNamed: "skipButton")
        let skipTextureSelected = SKTexture(imageNamed: "skipButtonSelected")
        skipButton = SKButton(defaultTexture: skipTexture, selectedTexture: skipTextureSelected, disabledTexture: skipTexture, size: skipTexture.size())
        skipButton.color = SKColor.red
        skipButton.anchorPoint = CGPoint(x: 0, y: 0.5)
        skipButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(skipLevel))
        skipButton.position = CGPoint(x: round(Screen.width/2),
                                      y: -offset)
        skipButton.zPosition = 0
        addChild(skipButton)
        
        skipLabel = SKLabelNode(fontNamed: "Futura-Medium")
        skipLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 38 : 20
        skipLabel.fontColor = SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1)
        skipLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        skipLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        skipLabel.zPosition = 0
        skipLabel.position = CGPoint(x: skipButton.position.x - skipButton.size.width / 3,
                                     y: -offset)
        skipLabel.text = "0"
        addChild(skipLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSkipAmount(_ num: Int) {
        skipLabel.text = String(num)
    }
    
    func enableSkipButton() {
        skipLabel.alpha = 1
        skipButton.isEnabled = true
    }
    
    func disableSkipButton() {
        skipLabel.alpha = 0.5
        skipButton.isEnabled = false
    }
    
    func flip(to factor: CGFloat) {
        let flip = SKAction.scaleY(to: factor, duration: 0.2)
        headerButton.run(flip)
    }
    
    func getOriginalY() -> CGFloat {
        return originalY
    }
}


// MARK: Objective-C methods
extension TopButtonsNode {
    @objc func handleHeader() {
        delegate?.handleHeader()
    }
    
    @objc func restartGame() {
        delegate?.restartGame()
    }
    
    @objc func skipLevel() {
        delegate?.skipLevel()
    }
}
