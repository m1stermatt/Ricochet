//
//  Extensions.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-10.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

public extension Int {
    
    /// Returns a random Int point number between 0 and Int.max.
    static var random: Int {
        return Int.random(n: Int.max)
    }
    
    /// Random integer between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random Int point number between 0 and n max
    static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    ///  Random integer between min and max
    ///
    /// - Parameters:
    ///   - min:    Interval minimun
    ///   - max:    Interval max
    /// - Returns:  Returns a random Int point number between 0 and n max
    static func random(min: Int, max: Int) -> Int {
        return Int.random(n: max - min + 1) + min
        
    }
}

// MARK: Double Extension

public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

// MARK: CGFloat Extension

public extension CGFloat {
    
    /// Randomly returns either 1.0 or -1.0.
    static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: CGFloat {
        return random(in: 0.0 ... 1.0)
    }
    
    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}

extension CGPoint {
    
    func calcDistanceTo(p: CGPoint) -> CGFloat {
        return sqrt(pow(x-p.x, 2) + pow(y-p.y, 2))
    }
    
    func calcAngleTo(p: CGPoint) -> CGFloat {
        let dx = x - p.x
        let dy = y - p.y
        return correctAngle(angle: CGFloat(atan(dy/dx)), dx: dx, dy: dy)
    }
    
    func calcAngleTo(p: CGPoint, dx: CGFloat, dy: CGFloat) -> CGFloat {
        return correctAngle(angle: CGFloat(atan(dy/dx)), dx: dx, dy: dy)
    }
    
    func dot(p: CGPoint) -> CGFloat {
        return x * p.x + y * p.y
    }
    
    func add(p: CGPoint) -> CGPoint {
        return CGPoint(x: x + p.x, y: y + p.y)
    }
    
    func subtract(p: CGPoint) -> CGPoint {
        return CGPoint(x: x - p.x, y: y - p.y)
    }
    
    func rotatePoint(origin: CGPoint, angle: CGFloat) -> CGPoint {
        return CGPoint(
            x: cos(angle) * (x-origin.x) - sin(angle) * (y-origin.y) + origin.x,
            y: sin(angle) * (x-origin.x) + cos(angle) * (y-origin.y) + origin.y
        )
    }
    
    private func correctAngle(angle: CGFloat, dx: CGFloat, dy: CGFloat) -> CGFloat {
        let pi = CGFloat(Double.pi)
        if dx < 0 && dx < 0 {
            return angle + pi
        }
        if dx < 0 {
            return angle + pi
        }
        if dy < 0 {
            return angle + 2 * pi
        }
        return angle
    }

}

extension SKLabelNode {
    func multilined() -> SKLabelNode {
        let substrings: [String] = self.text!.components(separatedBy: "\n")
        return substrings.enumerated().reduce(SKLabelNode()) {
            let label = SKLabelNode(fontNamed: self.fontName)
            label.text = $1.element
            label.fontColor = self.fontColor
            label.fontSize = self.fontSize
            label.position = self.position
            label.horizontalAlignmentMode = self.horizontalAlignmentMode
            label.verticalAlignmentMode = self.verticalAlignmentMode
            let y = CGFloat($1.offset - substrings.count / 2) * self.fontSize
            label.position = CGPoint(x: 0, y: -y)
            $0.addChild(label)
            return $0
        }
    }
}
