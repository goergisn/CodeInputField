# CodeInputField
An input field allowing the user to enter digits

## Usage
![Obfuscated Code Input Preview](https://github.com/goergisn/CodeInputField/blob/main/Resources/obfuscated_input.gif)

```Swift
// Ubfuscated input field that shows a 🔒 instead of the actual digits
let secureInputField = CodeInputField(segments: (0..<4).map { _ in
    let segment = CodeInputField.DefaultSegment(inputOverride: "🔒")
    segment.tintColor = .purple
    segment.inputColor = .white
    segment.backgroundColor = segment.tintColor?.withAlphaComponent(0.3)
    segment.nonEmptyBackgroundColor = .purple
    return segment
}, shouldClearInputWhenBecomingFirstResponder: true)
```
    
![Code Input Preview](https://github.com/goergisn/CodeInputField/blob/main/Resources/code_input.gif)
```Swift
// Generic code input field with custom radius & font
let codeInputField = CodeInputField(segments: (0..<6).map { _ in
    let segment = CodeInputField.DefaultSegment()
    segment.cornerRadius = 8
    segment.inputFont = .monospacedDigitSystemFont(ofSize: 20, weight: .black)
    return segment
})
```
