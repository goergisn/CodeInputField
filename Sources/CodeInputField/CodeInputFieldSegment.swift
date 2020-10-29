//
//  CodeInputFieldSegment.swift
//  CodeInputField
//
//  Created by Alex Guretzki on 27/10/2020.
//  Copyright © 2020 Goergisn. All rights reserved.
//

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
