
import UIKit

/// The minimal requirements for an input field segment
public protocol CodeInputFieldSegment: UIView {
    
    /**
     Update the value and focussed state
     
     - parameters:
        - value: The new value to show
        - isFocussed:flag indicating whether or not the segment should show as focussed
     */
    func update(value: Digit?, isFocussed: Bool)
}
