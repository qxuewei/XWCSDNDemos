//import Foundation

enum Color: String {
    case unknown
    case black
    case white
    case gray
    case blue
    case red
}
class Style {
    var backgroudColor = Color.black
    var textColor = Color.white
    func apply() {
        print("皮肤 - 背景色: \(self.backgroudColor), 文字颜色: \(self.textColor)")
    }
}
let baseStyle = Style()
baseStyle.apply()

class Custom1Style: Style {
    var buttonColor = Color.red
    override init() {
        super.init()
        backgroudColor = .gray
        textColor = .blue
    }
    override func apply() {
        print("皮肤 - 背景色: \(self.backgroudColor), 文字颜色: \(self.textColor), 按钮颜色: \(self.buttonColor)")
    }
}
let custom1Style = Custom1Style()
custom1Style.apply()

protocol StyleInterface {
    var backgroudColor: Color { get }
    var textColor: Color { get }
    var buttonColor: Color { get }
    func apply()
}
extension StyleInterface {
    var buttonColor: Color {
        get {
            return .unknown
        }
    }
}
class BaseStyle: StyleInterface {
    var backgroudColor: Color = .black
    var textColor: Color = .white
    func apply() {
        print("皮肤 - 背景色: \(self.backgroudColor), 文字颜色: \(self.textColor)")
    }
}
class Custom2Style: StyleInterface {
    var backgroudColor: Color = .gray
    var textColor: Color = .blue
    var buttonColor: Color = .red
    func apply() {
        print("皮肤 - 背景色: \(self.backgroudColor), 文字颜色: \(self.textColor), 按钮颜色: \(self.buttonColor)")
    }
}
let baseStyle2 = BaseStyle()
let custom2Style = Custom2Style()
baseStyle2.apply()
custom2Style.apply()


