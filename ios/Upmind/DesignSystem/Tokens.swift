import SwiftUI

// MARK: - Spacing

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Radii

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 22
    static let pill: CGFloat = 999
}

// MARK: - HIG tap-target

enum MinTapTarget {
    /// HIG minimum for iOS touch targets.
    static let size: CGFloat = 44
}

// MARK: - Motion

enum Motion {
    static let pageTransition: Animation = .easeInOut(duration: 0.48)
    static let cardPress: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let countUp: Animation = .easeInOut(duration: 0.6)
    static let answerFlash: Animation = .easeInOut(duration: 0.18)
    static let answerAdvance: TimeInterval = 0.6
}
