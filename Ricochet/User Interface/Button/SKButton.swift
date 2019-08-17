//
//  SKButton.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-28.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class SKButton: SKSpriteNode {
    
    enum FTButtonActionType: Int {
        case TouchUpInside = 1,
        TouchDown, TouchUp
    }
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                texture = isEnabled ? defaultTexture : disabledTexture
            }
            label.color = isEnabled ? labelColor : disabledLabelColor
            alpha = isEnabled ? 1 : 0.5
        }
    }
    var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
            label.fontColor = isSelected ? selectedLabelColor : labelColor
        }
    }
    
    // Textures
    private var defaultTexture: SKTexture?
    private var selectedTexture: SKTexture?
    private var disabledTexture: SKTexture?
    
    // Label
    private var label: SKLabelNode
    private var labelColor: SKColor
    private var selectedLabelColor: SKColor
    private var disabledLabelColor: SKColor
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(defaultTexture: SKTexture?, selectedTexture:SKTexture?, disabledTexture: SKTexture?, size: CGSize) {
        
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        self.label = SKLabelNode(fontNamed: "Arial");
        self.labelColor = SKColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha: 1)
        self.selectedLabelColor = SKColor(red: 150.0/255, green: 150.0/255, blue: 150.0/255, alpha: 1)
        self.disabledLabelColor = SKColor(red: 120.0/255, green: 120.0/255, blue: 120.0/255, alpha: 1)
        
        super.init(texture: defaultTexture, color: SKColor.clear, size: size)
        isUserInteractionEnabled = true
        
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        self.label.zPosition = 1
        self.label.fontColor = labelColor
        addChild(self.label)
        
    }
    
    private var actionTouchUpInside: Selector?
    private var actionTouchUp: Selector?
    private var actionTouchDown: Selector?
    private weak var targetTouchUpInside: AnyObject?
    private weak var targetTouchUp: AnyObject?
    private weak var targetTouchDown: AnyObject?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        isSelected = true
        if (targetTouchDown != nil && targetTouchDown!.responds(to :actionTouchDown!)) {
            UIApplication.shared.sendAction(actionTouchDown!, to: targetTouchDown, from: self, for: nil)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.responds(to: actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.location(in: parent!)
            
            if (frame.contains(touchLocation)) {
                UIApplication.shared.sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, for: nil)
            }
            
        }
        
        if (targetTouchUp != nil && targetTouchUp!.responds(to: actionTouchUp!)) {
            UIApplication.shared.sendAction(actionTouchUp!, to: targetTouchUp, from: self, for: nil)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.responds(to: actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.location(in: parent!)
            
            if (frame.contains(touchLocation)) {
                UIApplication.shared.sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, for: nil)
            }
            
        }
        
        if (targetTouchUp != nil && targetTouchUp!.responds(to: actionTouchUp!)) {
            UIApplication.shared.sendAction(actionTouchUp!, to: targetTouchUp, from: self, for: nil)
        }
    }
}

// MARK: Public Methods
extension SKButton {
    
    /*
     New function for setting text. Calling function multiple times does
     not create a ton of new labels, just updates existing label.
     You can set the title, font type and font size with this function
     */
    
    func setButtonLabel(title: String, font: String, fontSize: CGFloat) {
        self.label.text = title
        self.label.fontSize = fontSize
        self.label.fontName = font
        self.label.position = CGPoint(x: 0, y: 0)
    }
    
    func setText(_ text: String) {
        self.label.text = text
    }
    
    func setLabelColor(color: SKColor) {
        self.labelColor = color
        self.label.fontColor = self.labelColor
    }
    
    func setSelectedLabelColor(color: SKColor) {
        self.selectedLabelColor = color
    }
    
    /**
     * Taking a target object and adding an action that is triggered by a button event.
     */
    func setButtonAction(target: AnyObject, triggerEvent event:FTButtonActionType, action:Selector) {
        
        switch (event) {
        case .TouchUpInside:
            targetTouchUpInside = target
            actionTouchUpInside = action
        case .TouchDown:
            targetTouchDown = target
            actionTouchDown = action
        case .TouchUp:
            targetTouchUp = target
            actionTouchUp = action
        }
        
    }
    
    func getTextNumber() -> Int {
        return Int(label.text!)!
    }
    
    func getText() -> String {
        return label.text!
    }
    
}
