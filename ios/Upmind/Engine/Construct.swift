import Foundation

/// The seven cognitive constructs. Order matters — this drives the
/// construct filter chip order in the catalog and the radar chart order
/// in the Today / Profile screens.
enum Construct: String, CaseIterable, Codable, Sendable, Hashable, Identifiable {
    case attention
    case memory
    case processing
    case numeracy
    case verbal
    case problem
    case executive

    var id: String { rawValue }

    var label: String {
        switch self {
        case .attention:  return "Attention"
        case .memory:     return "Memory"
        case .processing: return "Processing"
        case .numeracy:   return "Numeracy"
        case .verbal:     return "Verbal"
        case .problem:    return "Problem-Solving"
        case .executive:  return "Executive Function"
        }
    }
}
