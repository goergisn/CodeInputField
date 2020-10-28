
import UIKit

public class CodeInputField: UIControl, UIKeyInput, UITextInputTraits {
    
    // MARK: Public Accessors
    
    public var input: String {
        get {
            return values.map { (value) -> String in
                return "\(String(describing: value))"
            }.joined(separator: "")
        }
    }
    
    public var shouldClearInputWhenBecomingFirstResponder: Bool = false
    
    public var preferredSegmentSize = CGSize(width: 50, height: 70) {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    public var segmentSpacing: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var values: [Digit?] {
        didSet {
            updateSegments()
        }
    }
    
    func clearInput() {
        values = Array(repeating: nil, count: numberOfDigits)
        selectedIndex = 0
    }
    
    // MARK: Private Vars
    
    private var segments: [CodeInputFieldSegment]
    
    private var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            
            if selectedIndex == highestIndex {
                sendActions(for: .editingDidEnd)
            } else {
                sendActions(for: .editingChanged)
            }
            
            UIView.transition(with: self, duration: 0.1, options: [.transitionCrossDissolve]) {
                self.updateSegments()
            }
        }
    }
    
    override public var tintColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    // MARK: - UIControl
    
    override public var isEnabled: Bool {
        didSet {
            if !isEnabled {
                self.endEditing(true)
            }
            
            updateColors()
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted && !isFirstResponder ? 0.5 : 1.0
        }
    }
    
    override public var canBecomeFirstResponder: Bool {
        return isEnabled
    }
    
    public override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    
    @discardableResult override public func becomeFirstResponder() -> Bool {
        if isFirstResponder { return true }
        
        if shouldClearInputWhenBecomingFirstResponder {
            clearInput() // Start from scratch...
        }
        
        return super.becomeFirstResponder()
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(paste(_:)) && shouldShowPasteMenu ? true : false
    }
    
    override public func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        return action == #selector(paste(_:)) ? self : nil
    }
    
    override public func paste(_ sender: Any?) {
        guard let values = pasteboardValues, values.count == numberOfDigits else { return }
        
        self.values = values
        selectedIndex = highestIndex
    }
    
    // MARK: - UIView
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        
        updateColors()
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return sizeThatFits(targetSize)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: min(size.width, intrinsicContentSize.width),
                     height: min(size.height, intrinsicContentSize.height))
    }
    
    public override var intrinsicContentSize: CGSize {
        let numberOfFields = CGFloat(numberOfDigits)
        return .init(width: numberOfFields * preferredSegmentSize.width + (numberOfFields-1) * segmentSpacing,
                     height: preferredSegmentSize.height)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        
        guard numberOfDigits > 0 else { return }
        
        let numberOfFields = CGFloat(numberOfDigits)
        let spacing = segmentSpacing
        let fieldSize = CGSize.init(width: (size.width-(numberOfFields-1)*spacing)/numberOfFields, height: size.height)
        
        segments.enumerated().forEach { (index, field) in
            field.frame = CGRect.init(x: (spacing+fieldSize.width)*CGFloat(index),
                                      y: 0,
                                      width: fieldSize.width,
                                      height: fieldSize.height)
        }
        
        updateSegments()
    }
    
    // MARK: - Init
    
    public init(segments: [CodeInputFieldSegment]) {
        self.values = Array(repeating: nil, count: segments.count)
        self.segments = segments
        
        super.init(frame: .zero)
        
        segments.forEach(self.addSubview)
        
        self.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(longPressRecognized(_:))))
        self.isUserInteractionEnabled = true
        
        updateSegments()
        updateColors()
        
        addTarget(self, action: #selector(fieldTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

// MARK: - UIKeyInput

extension CodeInputField {
    public var hasText: Bool { return self.input.count > 0 }
    
    public func insertText(_ text: String) {
        guard selectedIndex <= highestIndex, let intValue = Int(text) else { return }
        
        values[selectedIndex] = Digit(rawValue: intValue)
        selectedIndex = min(highestIndex, selectedIndex + 1)
    }
    
    public func deleteBackward() {
        let fieldWasEmpty = values[selectedIndex] == nil
        
        values[selectedIndex] = nil // Making sure the current field content is reset
        
        if selectedIndex < highestIndex || fieldWasEmpty {
            selectedIndex = max(0, selectedIndex - 1)
            values[selectedIndex] = nil // Making sure the newly selected field is reset
        }
    }
}

// MARK: - UITextInputTraits

extension CodeInputField {
    public var keyboardType: UIKeyboardType {
        get { return .numberPad }
        set { /* Ignoring... */ }
    }
}

// MARK: - Input

@objc private extension CodeInputField {
    func fieldTapped() {
        self.becomeFirstResponder()
    }
    
    func longPressRecognized(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if shouldShowPasteMenu && gestureRecognizer.state == .began {
            becomeFirstResponder()
            
            let menuController = UIMenuController.shared
            
            if #available(iOS 13.0, *) {
                menuController.showMenu(from: self, rect: self.bounds)
            } else {
                menuController.setTargetRect(self.bounds, in: self)
                menuController.setMenuVisible(true, animated: true)
            }
            
            setHighlighted(true, animated: true)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(menuControllerWillHideNotification(_:)),
                                                   name: UIMenuController.willHideMenuNotification,
                                                   object: nil)
            
        }
    }
    
    func menuControllerWillHideNotification(_ notification:NSNotification) {
        setHighlighted(false, animated: true)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIMenuController.willHideMenuNotification,
                                                  object: nil)
    }
}

// MARK: - Privates

private extension CodeInputField {
    func setHighlighted(_ isHighlighted:Bool, animated:Bool) {
        if animated {
            UIView.transition(with: self, duration: isHighlighted ? 0.15 : 0.25, options: .transitionCrossDissolve, animations: {
                self.isHighlighted = isHighlighted
            }, completion: nil)
        } else {
            self.isHighlighted = isHighlighted
        }
    }
    
    func updateSegments() {
        segments.enumerated().forEach { (index, segment) in
            segment.isSelected = (index == selectedIndex)
            segment.value = values[index]
        }
    }
    
    var pasteboardValues: [Digit]? {
        guard let string = UIPasteboard.general.string else { return nil }
        return Digit.valuesFrom(string)
    }
    
    var shouldShowPasteMenu: Bool {
        return pasteboardValues?.count == numberOfDigits
    }
    
    func updateColors() {
        alpha = isEnabled ? 1.0 : 0.5
    }
    
    private var highestIndex: Int {
        return numberOfDigits-1
    }
    
    private var numberOfDigits: Int {
        return values.count
    }
}
