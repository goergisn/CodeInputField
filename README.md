# CodeInputField
An input field allowing the user to enter digits

## Usage
```Swift
// Ubfuscated input field that shows a 🔒 instead of the actual digits
let secureInputField = CodeInputField(segments: (0..<4).map { _ in
    let segment = CodeInputField.DefaultSegment(inputOverride: "🔒")
    segment.tintColor = .brown
    segment.inputColor = .white
    segment.backgroundColor = UIColor.brown.withAlphaComponent(0.3)
    segment.nonEmptyBackgroundColor = .brown
    return segment
}, shouldClearInputWhenBecomingFirstResponder: true)
```
    
```Swift
// Generic code input field with custom radius & font
let codeInputField = CodeInputField(segments: (0..<6).map { _ in
    let segment = CodeInputField.DefaultSegment()
    segment.cornerRadius = 8
    segment.inputFont = .monospacedDigitSystemFont(ofSize: 20, weight: .black)
    return segment
})
```
