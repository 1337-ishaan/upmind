import Foundation

enum NotificationCategory: String, CaseIterable, Identifiable, Sendable {
    case streakRescue
    case dailyDrill
    case weeklyRecap
    case premiumRenewal
    case premiumLapse

    var id: String { rawValue }

    var threadIdentifier: String { "upmind.\(rawValue)" }

    var userFacingTitle: String {
        switch self {
        case .streakRescue:    return "Don't break your streak"
        case .dailyDrill:      return "Your daily drill"
        case .weeklyRecap:     return "Weekly recap"
        case .premiumRenewal:  return "Premium renewal"
        case .premiumLapse:    return "Premium expired"
        }
    }

    var userFacingSubtitle: String {
        switch self {
        case .streakRescue:    return "We'll ping you at 8pm if you haven't played today."
        case .dailyDrill:      return "We'll send one reminder at your chosen time."
        case .weeklyRecap:     return "Sundays: a quick look at your progress."
        case .premiumRenewal:  return "Heads-up 3 days before your subscription renews."
        case .premiumLapse:    return "We'll let you know if your premium access ends."
        }
    }

    var defaultOptIn: Bool {
        switch self {
        case .streakRescue, .dailyDrill, .weeklyRecap: return true
        case .premiumRenewal, .premiumLapse: return true
        }
    }
}
