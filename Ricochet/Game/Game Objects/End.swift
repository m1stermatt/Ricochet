//
//  End.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-09.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class End : SKSpriteNode {
    
    private var doesLookLocked : Bool = false 
    private var isLocked : Bool = false {
        didSet {
            lockSprite.isHidden = isLocked ? false : true
            cropNode.isHidden = isLocked ? false : true
        }
    }
    
    private var cropNode : SKCropNode!
    private var lockSprite : SKSpriteNode!
    private var mass : CGFloat!
    
    init(texture: SKTexture?, sizeFactor: CGFloat, shadowOffset: CGFloat) {
        super.init(texture: texture, color: SKColor.clear, size: CGSize(width: texture!.size().width/sizeFactor, height: texture!.size().height/sizeFactor))
        
        let lockTexture = SKTexture(imageNamed: "lock")
        
        lockSprite = SKSpriteNode(texture: lockTexture, color: SKColor.clear, size: CGSize(width: lockTexture.size().width/sizeFactor, height: lockTexture.size().height/sizeFactor))
        lockSprite.isHidden = true
        lockSprite.zPosition = 1
        lockSprite.position = CGPoint.zero
        
        cropNode = SKCropNode()
        cropNode.position = CGPoint.zero
        cropNode.zPosition = 0
        cropNode.isHidden = true
        cropNode.maskNode = SKSpriteNode(texture: nil, color: SKColor.black, size: lockSprite.size)
        cropNode.addChild(lockSprite)
        addChild(cropNode)
        
        let shadowTexture = SKTexture(imageNamed: "endShadow")
        let shadow = SKSpriteNode(texture: shadowTexture, color: SKColor.clear, size: CGSize(width: shadowTexture.size().width/sizeFactor, height: shadowTexture.size().height/sizeFactor))
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: shadowOffset, y: shadowOffset)
        shadow.zPosition = -1
        addChild(shadow)
        
        mass = UIDevice.current.userInterfaceIdiom == .pad ? 40000/sizeFactor : 20000/sizeFactor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public Methods
extension End {
    
    func lock() {
        lockSprite.removeAllActions()
        isLocked = true
        doesLookLocked = true
        
        let moveLock = SKAction.moveTo(y: 0, duration: 0.5)
        moveLock.timingMode = SKActionTimingMode.easeOut
        lockSprite.run(moveLock)
    }
    
    func unlock() {
        lockSprite.removeAllActions()
        doesLookLocked = false
        
        let moveLock = SKAction.moveTo(y: -lockSprite.size.height, duration: 0.5)
        moveLock.timingMode = SKActionTimingMode.easeOut
        let lockEnd = SKAction.run {
            self.isLocked = false
        }
        let sequence = SKAction.sequence([moveLock, lockEnd])
        lockSprite.run(sequence)
    }
    
    func looksLocked() {
        doesLookLocked = true
    }
    
    func notLooksLocked() {
        doesLookLocked = false
    }
    
    func getIsLocked() -> Bool {
        return isLocked
    }
    
    func getDoesLookLocked() -> Bool {
        return doesLookLocked
    }
    
    func getMass() -> CGFloat {
        return mass
    }
    
}
