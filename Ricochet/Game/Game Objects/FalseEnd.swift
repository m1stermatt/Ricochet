//
//  FalseEnd.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-13.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class FalseEnd : SKSpriteNode {
    
    private var mass : CGFloat!
    
    init(texture: SKTexture?, sizeFactor: CGFloat, shadowOffset: CGFloat) {
        super.init(texture: texture, color: SKColor.clear, size: CGSize(width: texture!.size().width/sizeFactor, height: texture!.size().height/sizeFactor))
        
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
extension FalseEnd {
    
    func getMass() -> CGFloat {
        return mass
    }
    
}
