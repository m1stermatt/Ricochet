//
//  CollisionEngine.swift
//  Ricochet
//
//  Created by Matthew Nam on 2017-12-22.
//  Copyright © 2017 WamDev. All rights reserved.
//

import Foundation
import SpriteKit

class CollisionEngine {
    
    private var intersection : Intersection?
    private var pi = CGFloat(Double.pi)
    
    private var newPos : CGPoint?
    private var newVel : CGPoint?
    
    private var collided : Bool = false
    
    init(ball: Ball, beam: Beam) {
        
        var A, C, start, end, topRight, bottomLeft : CGPoint
        
        let r = ball.getRadius()
        
        let hypo = beam.getDiagonal()
        let beta1 = beam.zRotation
        let beta2 = beam.getHAngle()
        let theta1 = beta1 + beta2
        let theta3 = beta1 + pi + beta2
        
        A = CGPoint(x: hypo * cos(theta1) + beam.position.x, y: hypo * sin(theta1) + beam.position.y)
        C = CGPoint(x: hypo * cos(theta3) + beam.position.x, y: hypo * sin(theta3) + beam.position.y)
        
        start = ball.position.subtract(p: ball.getVel())
        end = ball.position.rotatePoint(origin: start, angle: -beta1)
        topRight = A.rotatePoint(origin: start, angle: -beta1)
        bottomLeft = C.rotatePoint(origin: start, angle: -beta1)
        
        let deltaX = start.x - max(bottomLeft.x, min(start.x, topRight.x))
        let deltaY = start.y - max(bottomLeft.y, min(start.y, topRight.y))
        
        if deltaX * deltaX + deltaY * deltaY >= r * r {
            let bounds = Bounds(left: bottomLeft.x, top: topRight.y, right: topRight.x, bottom: bottomLeft.y)
            intersection = handleIntersection(bounds: bounds, start: start, end: end, radius: r)
        }
        
        if let inter = intersection {
            
            collided = true
            
            let c = inter.c.rotatePoint(origin: start, angle: beta1)
            let n = inter.n.rotatePoint(origin: CGPoint.zero, angle: beta1)
            
            let remainingTime = 1.0 - inter.time;
            let d = ball.getVel()
            let dot = d.dot(p: n)
            let nd = CGPoint(x: d.x - 2 * dot * n.x, y: d.y - 2 * dot * n.y)
            let new = CGPoint(x: c.x + nd.x * remainingTime, y: c.y + nd.y * remainingTime)
            
            let newDelta = new.subtract(p: c)
            let hypo = newDelta.calcDistanceTo(p: CGPoint.zero)
            let vel = CGPoint(x: ball.getSpeed() * (newDelta.x / hypo), y: ball.getSpeed() * (newDelta.y / hypo))
            
            newPos = new
            newVel = vel
        }
        
    }
    
    private func handleIntersection(bounds: Bounds, start: CGPoint, end: CGPoint, radius: CGFloat) -> Intersection? {
        
        let L = bounds.left
        let T = bounds.top
        let R = bounds.right
        let B = bounds.bottom
        
        // AABB check
        if  (max(start.x, end.x) + radius < L) ||
            (min(start.x, end.x) - radius > R) ||
            (min(start.y, end.y) - radius > T) ||
            (max(start.y, end.y) + radius < B) {
            return nil
        }
        
        let d = CGPoint(x: end.x - start.x, y: end.y - start.y)
        let invd = CGPoint(x: d.x == 0.0 ? 0.0 : 1.0 / d.x, y: d.y == 0.0 ? 0.0 : 1.0 / d.y)
        var corner = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        
        // Calculate intersection times with each side's plane
        // Check each side's quadrant for single-side intersection
        // Calculate Corner
        
        /** Left Side **/
        if start.x - radius < L && end.x + radius > L {
            let ltime = ((L - radius) - start.x) * invd.x
            if ltime >= 0.0 && ltime <= 1.0 {
                let ly = d.y * ltime + start.y
                if ly >= B && ly <= T {
                    return Intersection(c: CGPoint(x: d.x * ltime + start.x, y: ly), time: ltime, n: CGPoint(x: -1, y: 0))
                }
            }
            corner.x = L
        }
        
        /** Right Side **/
        if start.x + radius > R && end.x - radius < R {
            let rtime = (start.x - (R + radius)) * -invd.x
            if rtime >= 0.0 && rtime <= 1.0 {
                let ry = d.y * rtime + start.y
                if ry >= B && ry <= T {
                    return Intersection(c: CGPoint(x: d.x * rtime + start.x, y: ry), time: rtime, n: CGPoint(x: 1, y: 0))
                }
            }
            corner.x = R
        }
        
        /** Top Side **/
        if start.y + radius > T && end.y - radius < T {
            let ttime = (start.y - (T + radius)) * -invd.y
            if ttime >= 0.0 && ttime <= 1.0 {
                let tx = d.x * ttime + start.x
                if tx >= L && tx <= R {
                    return Intersection(c: CGPoint(x: tx, y: d.y * ttime + start.y), time: ttime, n: CGPoint(x: 0, y: 1))
                }
            }
            corner.y = T
        }
        
        /** Bottom Side **/
        if start.y - radius < B && end.y + radius > B {
            let btime = ((B - radius) - start.y) * invd.y
            if btime >= 0.0 && btime <= 1.0 {
                let bx = d.x * btime + start.x
                if bx >= L && bx <= R {
                    return Intersection(c: CGPoint(x: bx, y: d.y * btime + start.y), time: btime, n: CGPoint(x: 0, y: -1))
                }
            }
            corner.y = B;
        }
        
        // No intersection at all!
        if corner.x == CGFloat.greatestFiniteMagnitude && corner.y == CGFloat.greatestFiniteMagnitude {
            return nil
        }
        
        // Account for the times where we don't pass over a side but we do hit it's corner
        if corner.x != CGFloat.greatestFiniteMagnitude && corner.y == CGFloat.greatestFiniteMagnitude {
            corner.y = d.y > 0.0 ? T : B
        }
        if corner.y != CGFloat.greatestFiniteMagnitude && corner.x == CGFloat.greatestFiniteMagnitude {
            corner.x = d.x > 0.0 ? R : L
        }
        
        let inverseRadius = 1.0 / radius
        let lineLength = d.calcDistanceTo(p: CGPoint.zero)
        let cornerd = CGPoint(x: corner.x - start.x, y: corner.y - start.y)
        let cornerDistance = sqrt(cornerd.x * cornerd.x + cornerd.y * cornerd.y)
        let innerAngle = acos((cornerd.x * d.x + cornerd.y * d.y) / (lineLength * cornerDistance))
        
        // If the circle is too close, no intersection.
        if cornerDistance < radius {
            return nil
        }
        
        // If inner angle is zero, it's going to hit the corner straight on.
        if innerAngle == 0.0 {
            let time = CGFloat((cornerDistance - radius) / lineLength)
            
            // If time is outside the boundaries, return null. This algorithm can
            // return a negative time which indicates a previous intersection, and
            // can also return a time > 1.0f which can predict a corner intersection.
            if time > 1.0 || time < 0.0 {
                return nil
            }
            
            let i = CGPoint(x: time * d.x + start.x, y: time * d.y + start.y)
            let n = CGPoint(x: cornerd.x / cornerDistance, y: cornerd.y / cornerDistance)
            
            return Intersection(c: i, time: time, n: n)
        }
        
        let innerAngleSin = sin(innerAngle)
        let angle1Sin = innerAngleSin * cornerDistance * inverseRadius
        
        // The angle is too large, there cannot be an intersection
        if abs(angle1Sin) > 1.0 {
            return nil
        }
        
        let angle1 = CGFloat(Double.pi) - asin(angle1Sin)
        let angle2 = CGFloat(Double.pi) - innerAngle - angle1
        let intersectionDistance = radius * sin(angle2) / innerAngleSin
        
        // Solve for time
        let time = CGFloat(intersectionDistance / lineLength)
        
        // If time is outside the boundaries, return null. This algorithm can
        // return a negative time which indicates a previous intersection, and
        // can also return a time > 1.0f which can predict a corner intersection.
        if time > 1.0 || time < 0.0 {
            return nil
        }
        
        // Solve the intersection and normal
        let i = CGPoint(x: time * d.x + start.x, y: time * d.y + start.y)
        let n = CGPoint(x: (i.x - corner.x) * inverseRadius, y: (i.y - corner.y) * inverseRadius)
        
        return Intersection(c: i, time: time, n: n)
        
    }
    
    private class Bounds {
        
        var left, top, right, bottom : CGFloat
        
        init(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
            
            self.left = left
            self.right = right
            self.top = top
            self.bottom = bottom
            
        }
        
    }
    
}

// MARK: Public Methods
extension CollisionEngine {
    func getIntersection() -> Intersection? {
        return intersection
    }
    
    func getNewPos() -> CGPoint? {
        return newPos
    }
    
    func getNewVel() -> CGPoint? {
        return newVel
    }
    
    func didCollide() -> Bool {
        return collided
    }
    
    static func checkBox(node: SKSpriteNode, radius: CGFloat, position: CGPoint) -> Bool {
        
        let topRight = CGPoint(x: node.position.x + node.size.width/2, y: node.position.y + node.size.height/2)
        let bottomLeft = CGPoint(x: node.position.x - node.size.width/2, y: node.position.y - node.size.height/2)
        
        let deltaX = position.x - max(bottomLeft.x, min(position.x, topRight.x))
        let deltaY = position.y - max(bottomLeft.y, min(position.y, topRight.y))
        
        if deltaX * deltaX + deltaY * deltaY >= radius * radius {
            return false
        }
        
        return true
        
    }
}

// MARK: Public Classes
extension CollisionEngine {
    class Intersection {
        
        var c, n : CGPoint
        var time : CGFloat
        
        init(c: CGPoint, time: CGFloat, n: CGPoint) {
            
            self.c = c
            self.n = n
            self.time = time
            
        }
        
    }
}
