
import UIKit

/// The minimal requirements for an input field segment
public protocol CodeInputFieldSegment: UIView {
    var value: Digit? { get set }
    var isSelected: Bool { get set }
}
