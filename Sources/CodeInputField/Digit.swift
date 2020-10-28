
/// Allowed input
public enum Digit: Int {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case zero = 0
    
    static func valuesFrom(_ string: String) -> [Digit] {
        return string.compactMap {
            guard let intValue = Int(String($0)) else { return nil }
            return Digit(rawValue: intValue)
        }
    }
}
