//
//  CodeInputField+DefaultSegment.swift
//  CodeInputField
//
//  Created by Alex Guretzki on 27/10/2020.
//  Copyright © 2020 Goergisn. All rights reserved.
//

import UIKit

public extension CodeInputField {
    /// A rounded rect segment showing an outline when focussed
    class DefaultSegment: UIView, CodeInputFieldSegment {
        
        // MARK: - UI Elements
        
        private let label: UILabel = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 26)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.baselineAdjustment = .alignCenters
            return label
        }()
        
        // MARK: - Public Accessors
        
        public func update(value: Digit?, isFocussed: Bool) {
            guard self.value != value || self.isFocussed != isFocussed else { return }
            
            self.value = value
            self.isFocussed = isFocussed
            
            label.text = text(for: value)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                self.update()
            })
        }
        
        public var inputFont: UIFont {
            get {
                return label.font
            }
            set {
                label.font = newValue
            }
        }
        
        public var inputColor: UIColor {
            didSet {
                update()
            }
        }
        
        /// The color of the segment when it has a value
        public var nonEmptyBackgroundColor: UIColor = .clear {
            didSet {
                update()
            }
        }
        
        public var cornerRadius: CGFloat = 16 {
            didSet {
                update()
            }
        }
        
        public var borderWidth: CGFloat = 3 {
            didSet {
                update()
            }
        }
        
        override public var tintColor: UIColor? {
            didSet {
                update()
            }
        }
        
        // MARK: - Privates
        
        private var value: Digit?
        
        private var isFocussed: Bool = false
        
        private var inputOverride: String?
        
        /**
         Applies the `inputOverride` if provided. Otherwise returns the string representation off the value
         
         - parameters:
            - value: the value we want to have a String representation for.
         */
        private func text(for value: Digit?) -> String? {
            if let value = value {
                return inputOverride ?? "\(value.rawValue)"
            } else {
                return nil
            }
        }
        
        /// Making sure the corner radius isn't larger than 0.5 x the shortest side
        private var sanitizedCornerRadius: CGFloat {
            return min(min(bounds.size.width * 0.5, bounds.size.height * 0.5), cornerRadius)
        }
        
        private func update() {
            layer.borderWidth = isFocussed ? borderWidth : 0
            layer.borderColor = tintColor?.cgColor
            label.alpha = value != nil ? 1 : 0
            label.textColor = inputColor
            label.backgroundColor = value != nil ? nonEmptyBackgroundColor : .clear
        }
        
        // MARK: - UIView
        
        override public func sizeThatFits(_ size: CGSize) -> CGSize {
            return .init(width: min(size.width, intrinsicContentSize.width), height: intrinsicContentSize.height)
        }
        
        override public func layoutSubviews() {
            super.layoutSubviews()
            let size = self.bounds.size
            
            label.bounds = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
            label.center = CGPoint.init(x: size.width*0.5, y: size.height*0.5)
            
            layer.cornerRadius = sanitizedCornerRadius
            
            update()
        }
        
        /**
         Creates the segment with an optional inputOverride
         
         - parameters:
            - inputOverride: Changes how the entered value is shown. This can be used to obfuscate/hide the input
         */
        public init(inputOverride: String? = nil) {
            self.inputOverride = inputOverride
            self.inputColor = Self.defaultInputColor
            
            super.init(frame: .zero)

            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            self.inputOverride = nil
            self.inputColor = Self.defaultInputColor
            
            super.init(coder: aDecoder)
            
            setup()
        }
    }
}

private extension CodeInputField.DefaultSegment {
    func setup() {
        clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            backgroundColor = .secondarySystemBackground
        } else {
            backgroundColor = .lightGray
        }
        
        addSubview(label)
        
        isUserInteractionEnabled = false
        
        update()
    }
    
    class var defaultInputColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
}

