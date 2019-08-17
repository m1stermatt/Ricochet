//
//  Tutorial.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-11.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class Message : SKNode {
    
    private var textColor : SKColor!
    
    static var fontSize : CGFloat = 18
    
    override init() {
        super.init()
        
        textColor = SKColor(red: 196.0/255, green: 194.0/255, blue: 193.0/255, alpha: 1)
    }
    
    init(text: String) {
        super.init()
        
        name = "tutorial"
        textColor = SKColor(red: 196.0/255, green: 194.0/255, blue: 193.0/255, alpha: 1)
        
        setText(text: text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Public Functions
extension Message {
    func setText(text: String, withColor color: SKColor) {
        textColor = color
        setText(text: text)
    }
    func setText(text: String) {
        removeAllChildren()
        let label = SKLabelNode(fontNamed: "Futura-Medium")
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
        label.fontColor = textColor
        label.fontSize = Message.fontSize
        label.text = NSLocalizedString(text, comment: "")
        let tutorialLabel = label.multilined()
        tutorialLabel.zPosition = 0
        tutorialLabel.position = CGPoint(x: 0, y: 0)
        addChild(tutorialLabel)
    }
}
