//
//  DeckHapticFeedbackGenerator.swift
//  DeckTransition
//
//  Created by Andreas Neusüß on 22.11.18.
//  Copyright © 2018 Harshil Shah. All rights reserved.
//

import AudioToolbox
import UIKit

/** This class is used to control the haptic feedback. It provides methods for configuring the style of the feedback. Currently, only impact-styled feedbacks are supported (with weight ```light```, ```medium``` or ```heavy```).
 
 This class uses a singleton for now. The downside of this approach is that only one kind of feedback can be performed.
 
 Please ensure to call ```DeckHapticFeedbackGenerator.shared.prepare()``` to power up the device's TapticEngine.
 */
final class DeckHapticFeedbackGenerator: NSObject {
    
    /// The singleton that should be used to trigger haptic feedback. Please ensure to call ```DeckHapticFeedbackGenerator.shared.prepare()``` to power up the device's TapticEngine.
    static let shared = DeckHapticFeedbackGenerator()
    
    /// The feedback style that should be performed.
    var style: UIImpactFeedbackGenerator.FeedbackStyle = .light {
        didSet {
            feedbackGenerator = createFeedbackGenerator(using: style)
        }
    }
    
    // Make the initializer unavailable for the public so that the shared instance is used.
    private override init() {
        super.init()
        feedbackGenerator = createFeedbackGenerator(using: style)
    }
    
    /// The internally used feedback generator. Must be held strongly in order to perform feedback. Make sure to call ```prepare``` prior to any feedback action.
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    
    /// This method constructs a UIImpactFeedbackGenerator from a given feedback style.
    ///
    /// - Parameter style: The style that should be used for the feedback.
    /// - Returns: The new UIImpactFeedbackGenerator.
    private func createFeedbackGenerator(using style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
        return UIImpactFeedbackGenerator(style: style)
    }

    
    /// This method prepares the device's TapticEngine. Call this method about one second before the haptic feedback should be performed`(if possible). The TapticEngine will stay powered on about one or two seconds.
    func prepare() {
        feedbackGenerator?.prepare()
    }
    
    /// This method performs the haptic feedback. Please call ```prepare``` about one second in advance. Only then it is save to coordinate UI interactions with the haptic feedback. It will use the style provided by a call to ```DeckHapticFeedbackGenerator`.shared.changeFeedbackStyle(to:)```.
    func perform() {
        // If not done already, a call to "prepare" poweres up the TapticEngine.
        prepare()
        
        feedbackGenerator?.impactOccurred()
        
        if UIDevice.current.useBasicHapticFeedback {
            switch style {
            case .light, .medium:
                AudioServicesPlaySystemSound(1519) // Peek
            case .heavy:
                AudioServicesPlaySystemSound(1520) // Pop
            @unknown default:
                return
            }
        }
    }
    
    
    /// This method changed the style of the haptic feedback.
    ///
    /// - Parameter style: The new style that should be used for the feedback.
    func changeFeedbackStyle(to style: UIImpactFeedbackGenerator.FeedbackStyle) {
        self.style = style
    }
}

extension UIDevice {
    var useBasicHapticFeedback: Bool {
        var sysinfo = utsname()
        uname(&sysinfo)
        let platform = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        switch platform {
        case "iPhone8,1", "iPhone8,2":
            return true // iPhone 6s, iPhone 6s Plus
        default:
            return false
        }
    }
}
