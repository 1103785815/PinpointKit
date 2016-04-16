//
//  PinpointKit+ShakePresentation.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 4/16/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

/**
 *  Extends `PinpointKit` to present itself on the application's root view controller as the result
 *  of a shake event.
 */
extension PinpointKit: ShakeDetectingWindowDelegate {

    // MARK: - ShakeDetectingWindowDelegate

    public func shakeDetectingWindowDidDetectShake(shakeDetectingWindow: ShakeDetectingWindow) {
        guard let rootViewController = shakeDetectingWindow.rootViewController else {
            print("PinpointPresentingShakeDetectingWindowDelegate couldn't find a root view controller to present on.")
            return
        }

        self.show(fromViewController: rootViewController)
    }
}