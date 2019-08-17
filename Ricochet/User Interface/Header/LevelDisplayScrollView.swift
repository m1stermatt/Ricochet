//
//  LevelDisplayScrollView.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-01-07.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class LevelDisplayScrollView: UIScrollView {
    // MARK: - Static Properties
    
    /// Touches allowed
    static var disabledTouches = false
    
    /// Scroll view
    private static var scrollView: UIScrollView!
    
    // MARK: - Properties
    
    /// Current scene
    private let currentScene: SKScene
    
    /// Moveable node
    private let moveableNode: SKNode
    
    /// Touched nodes
    private var nodesTouched = [AnyObject]()
    
    // MARK: - Init
    init(frame: CGRect, scene: SKScene, moveableNode: SKNode) {
        self.currentScene = scene
        self.moveableNode = moveableNode
        super.init(frame: frame)
        
        LevelDisplayScrollView.scrollView = self
        self.frame = frame
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
        isUserInteractionEnabled = true
        bounces = false
        isPagingEnabled = true
        
        let flip = CGAffineTransform(scaleX: 1, y: -1)
        transform = flip
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Touches
extension LevelDisplayScrollView {
    /// Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: currentScene)
            
            guard !LevelDisplayScrollView.disabledTouches else { return }
            
            nodesTouched = currentScene.nodes(at: location)
            for node in nodesTouched {
                node.touchesBegan(touches, with: event)
                if node is SKButton {
                    (node as! SKButton).isSelected = false
                }
            }
        }
    }
    
    /// Moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: currentScene)
            
            guard !LevelDisplayScrollView.disabledTouches else { return }
            
            nodesTouched = currentScene.nodes(at: location)
            for node in nodesTouched {
                node.touchesMoved(touches, with: event)
                if node is SKButton {
                    (node as! SKButton).isSelected = false
                }
            }
        }
    }
    
    /// Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: currentScene)
            
            guard !LevelDisplayScrollView.disabledTouches else { return }
            
            nodesTouched = currentScene.nodes(at: location)
            for node in nodesTouched {
                node.touchesEnded(touches, with: event)
                if node is SKButton {
                    (node as! SKButton).isSelected = false
                }
            }
        }
    }
}

// MARK: - Touch Controls
extension LevelDisplayScrollView {
    /// Disable
    class func disable() {
        LevelDisplayScrollView.scrollView?.isUserInteractionEnabled = false
        LevelDisplayScrollView.disabledTouches = true
    }
    
    /// Enable
    class func enable() {
        LevelDisplayScrollView.scrollView?.isUserInteractionEnabled = true
        LevelDisplayScrollView.disabledTouches = false
    }
}

// MARK: - Delegates
extension LevelDisplayScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        moveableNode.position.x = -scrollView.contentOffset.x
    }
}

// MARK: - Page Setter
extension LevelDisplayScrollView {
    func goToPage(number: Int) {
        setContentOffset(CGPoint(x: frame.size.width * CGFloat(number - 1), y: 0), animated: true)
    }
}
