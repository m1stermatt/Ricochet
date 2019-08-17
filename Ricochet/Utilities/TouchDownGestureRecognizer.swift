//
//  TouchDownGestureRecognizer.swift
//  Ricochet
//
//  Created by Matthew Nam on 2018-06-12.
//  Copyright © 2018 WamDev. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class TouchGestureRecognizer : UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .possible
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .recognized
    }
}
