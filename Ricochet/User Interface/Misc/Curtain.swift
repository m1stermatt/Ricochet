//
//  Curtain.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-12.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

protocol CurtainDelegate : NSObjectProtocol {
    func remove()
    func load()
    func finished()
}

class Curtain : SKNode {
    /* Colors */
    private var transitionColors : [SKColor] = [SKColor(red: 156.0/255, green: 194.0/255, blue: 229.0/255, alpha: 1),
                                                SKColor(red: 173.0/255, green: 229.0/255, blue: 156.0/255, alpha: 1),
                                                SKColor(red: 225.0/255, green: 156.0/255, blue: 229.0/255, alpha: 1),
                                                SKColor(red: 113.0/255, green: 220.0/255, blue: 236.0/255, alpha: 1),
                                                SKColor(red: 238.0/255, green: 131.0/255, blue: 163.0/255, alpha: 1)]
    
    /* UI */
    private var levelNumberLabel : SKLabelNode!
    private var curtain : SKSpriteNode!
    private var messageConfirmation : SKButton!
    private var messageMessage : Message!
    
    /* Boolean */
    private var hasMessage : Bool = false
    
    /* Action */
    private var expand : SKAction!
    private var remove : SKAction!
    private var load : SKAction!
    private var transition : SKAction!
    private var moveIn : SKAction!
    private var moveOut : SKAction!
    private var wait : SKAction!
    private var shrink : SKAction!
    private var finish : SKAction!
    
    weak var delegate : CurtainDelegate?
    
    private var didLoadLevel : Bool = false
    
    init(delegate: CurtainDelegate) {
        super.init()
        
        self.delegate = delegate
        let screenSize = CGSize(width: Screen.width, height: Screen.height)
        
        var levelNumberLabelFont : CGFloat = 90
        var messageConfirmationSize = CGSize(width: 100, height: 40)
        var messageConfirmationFontSize : CGFloat = 24
        var displacement : CGFloat = 30  // Amount the level label moves extra during animation
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            levelNumberLabelFont = 180
            messageConfirmationSize = CGSize(width: 200, height: 80)
            messageConfirmationFontSize = 48
            displacement = 60
        }
        
        curtain = SKSpriteNode(texture: nil, color: transitionColors[0], size: CGSize(width: screenSize.width, height: screenSize.height))
        curtain.anchorPoint = CGPoint(x: 0, y: 1)
        curtain.position = CGPoint(x: 0, y: 0)
        curtain.zPosition = 1
        addChild(curtain)
        
        levelNumberLabel = SKLabelNode(fontNamed: "Futura-Medium")
        levelNumberLabel.fontSize = levelNumberLabelFont
        levelNumberLabel.fontColor = SKColor.white
        levelNumberLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        levelNumberLabel.zPosition = 2
        levelNumberLabel.position = CGPoint(x: -levelNumberLabel.frame.size.width/2, y: -screenSize.height/2)
        addChild(levelNumberLabel)
        
        messageMessage = Message()
        messageMessage.position = CGPoint(x: screenSize.width/2, y: -screenSize.height * 0.65)
        messageMessage.alpha = 0
        messageMessage.zPosition = 2
        addChild(messageMessage)
        
        messageConfirmation = SKButton(defaultTexture: nil, selectedTexture: nil, disabledTexture: nil, size: messageConfirmationSize)
        messageConfirmation.setButtonLabel(title: NSLocalizedString("Got it", comment: ""), font: "Futura-Medium", fontSize: messageConfirmationFontSize)
        messageConfirmation.setLabelColor(color: SKColor.white)
        messageConfirmation.setSelectedLabelColor(color: SKColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.5))
        messageConfirmation.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(Curtain.confirmedMessage))
        messageConfirmation.position = CGPoint(x: messageMessage.position.x, y: -screenSize.height * 0.75)
        messageConfirmation.zPosition = 2
        messageConfirmation.alpha = 0
        addChild(messageConfirmation)
        
        expand = SKAction.resize(toHeight: screenSize.height, duration: 0.5)
        expand.timingMode = SKActionTimingMode.easeInEaseOut
        remove = SKAction.run({
            self.delegate?.remove()
        })
        load = SKAction.run({
            self.delegate?.load()
        })
        transition = SKAction.run({
            let pause = SKAction.wait(forDuration: 0.3)
            let moveIn1 = SKAction.moveTo(x: screenSize.width/2 + displacement, duration: 0.4)
            moveIn1.timingMode = SKActionTimingMode.easeOut
            let moveIn2 = SKAction.moveTo(x: screenSize.width/2, duration: 0.2)
            moveIn2.timingMode = SKActionTimingMode.easeIn
            let moveOut1 = SKAction.moveTo(x: screenSize.width/2 - displacement, duration: 0.2)
            moveOut1.timingMode = SKActionTimingMode.easeOut
            let moveOut2 = SKAction.moveTo(x: screenSize.width + self.levelNumberLabel.frame.size.width * 0.5, duration: 0.4)
            moveOut2.timingMode = SKActionTimingMode.easeIn
            let seq = SKAction.sequence([pause, moveIn1, moveIn2, pause, moveOut1, moveOut2])
            
            self.levelNumberLabel.run(seq)
        })
        moveIn = SKAction.run({
            let pause = SKAction.wait(forDuration: 0.3)
            let moveIn1 = SKAction.moveTo(x: screenSize.width/2 + displacement, duration: 0.4)
            moveIn1.timingMode = SKActionTimingMode.easeOut
            let moveIn2 = SKAction.moveTo(x: screenSize.width/2, duration: 0.2)
            moveIn2.timingMode = SKActionTimingMode.easeIn
            let seq = SKAction.sequence([pause, moveIn1, moveIn2])
            self.levelNumberLabel.run(seq)
            
            self.messageConfirmation.run(.sequence([
                .wait(forDuration: 1.5),
                .fadeAlpha(to: 1, duration: 0.3)]))
            self.messageMessage.run(.fadeAlpha(to: 1, duration: 0.6))
        })
        moveOut = SKAction.run({
            let moveOut1 = SKAction.moveTo(x: screenSize.width/2 - displacement, duration: 0.2)
            moveOut1.timingMode = SKActionTimingMode.easeOut
            let moveOut2 = SKAction.moveTo(x: screenSize.width + self.levelNumberLabel.frame.size.width*0.5, duration: 0.4)
            moveOut2.timingMode = SKActionTimingMode.easeIn
            let seq = SKAction.sequence([moveOut1, moveOut2])
            self.levelNumberLabel.run(seq)
            
            self.messageConfirmation.run(.fadeAlpha(to: 0, duration: 0.6))
            self.messageMessage.run(.fadeAlpha(to: 0, duration: 0.6))
        })
        wait = SKAction.wait(forDuration: 2.1)
        shrink = SKAction.resize(toHeight: 1, duration: 0.5)
        shrink.timingMode = SKActionTimingMode.easeInEaseOut
        finish = SKAction.run({
            self.hasMessage = false
            self.delegate?.finished()
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Objective C methods
extension Curtain {
    @objc func confirmedMessage() {
        if !didLoadLevel {
            curtain.run(.sequence([load, moveOut, .wait(forDuration: 0.9), shrink, finish]))
            didLoadLevel = true
        }
    }
}

// MARK: Public Methods
extension Curtain {
    
    func setLevelText(levelNumber: Int) {
        self.levelNumberLabel.text = String(levelNumber + 1)
    }
    
    func setMessageText(text: String) {
        hasMessage = true
        messageMessage.setText(text: text, withColor: SKColor.white)
    }
    
    func animate(shouldExpand: Bool) {
        
        didLoadLevel = false
        
        if shouldExpand {
            let colorIndex = Int(arc4random() % UInt32(transitionColors.count))
            curtain.color = transitionColors[colorIndex]
        }
        else {
            curtain.color = transitionColors[0]
        }
        
        levelNumberLabel.position.x = -self.levelNumberLabel.frame.size.width/2
        
        if shouldExpand {
            curtain.size = CGSize(width: curtain.size.width, height: 1)
            if hasMessage {
                curtain.run(.sequence([expand, remove, moveIn]))
            }
            else {
                curtain.run(.sequence([expand, remove, load, transition, wait, shrink, finish]))
            }
        } else {
            if hasMessage {
                curtain.run(.sequence([.wait(forDuration: 1), moveIn]))
            }
            else {
                curtain.run(.sequence([.wait(forDuration: 1), load, transition, wait, shrink, finish]))
            }
        }
    }
}
