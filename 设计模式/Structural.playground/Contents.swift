// 结构型设计模式
import UIKit

// 组合
enum NodeType {
    case Folder
    case File
}
protocol FileNode {
    var type: NodeType { get }
    var name: String { get }
    func addNode(node: FileNode)
    func removeNode(node: FileNode)
    func getAllNode() -> [FileNode]
}
class file: FileNode {
    var type: NodeType
    var name: String
    var child = [FileNode]()
    init(type: NodeType, name: String) {
        self.type = type
        self.name = name
    }
    func addNode(node: FileNode) {
        self.child.append(node)
    }
    
    func removeNode(node: FileNode) {
        self.child = self.child.filter({ n in
            if node.name == n.name && node.type == n.type {
                return false
            }
            return true
        })
    }
    
    func getAllNode() -> [FileNode] {
        return self.child
    }    
}

// 享元模式
struct Place {
    var x: Int
    var y: Int
}
enum Color {
    case White
    case Black
}
class ChessPieceFlyweight {
    var color: Color
    var radius: Double
    init(color: Color, radius: Double) {
        self.color = color
        self.radius = radius
    }
}
class ChessPieceFlyweightFactory {
    static let white = ChessPieceFlyweight(color: .White, radius: 16.0)
    static let black = ChessPieceFlyweight(color: .Black, radius: 16.0)
    static func getChessPieceFlyweight(color: Color) -> ChessPieceFlyweight {
        switch color {
        case .White:
            return white
        case .Black:
            return black
        }
    }
}
class ChessPiece {
    var place: Place
    var chessPieceFlyweight: ChessPieceFlyweight
    init(place: Place, color: Color) {
        self.place = place
        self.chessPieceFlyweight = ChessPieceFlyweightFactory.getChessPieceFlyweight(color: color)
    }
}
//class ChessPiece {
//    var place: Place
//    var color: Color
//    var radius: Double
//    init(place: Place, color: Color, radius: Double) {
//        self.place = place
//        self.color = color
//        self.radius = radius
//    }
//}
//let chessPiece = ChessPiece(place: Place(x: 1, y: 2), color: .Black, radius: 16)
let chessPiece = ChessPiece(place: Place(x: 1, y: 2), color: .Black)
print("\(chessPiece.place)")


// 外观
struct User {
    var name: String
}
struct Goods {
    static func choseGoods(user: User) {
        print("\(user.name)选择商品")
    }
}
struct Cashier {
    static func pay(user: User) {
        print("\(user.name)付款")
    }
}
struct Package {
    static func packing(user: User) {
        print("\(user.name)打包")
    }
}
struct Store {
    static func shop(user: User) {
        Goods.choseGoods(user: user)
        Cashier.pay(user: user)
        Package.packing(user: user)
    }
}
let user = User(name: "学伟")
Store.shop(user: user)
//Goods.choseGoods(user: user)
//Cashier.pay(user: user)
//Package.packing(user: user)

// 装饰
protocol WallProtocol {
    func printInfo()
}
class Wall: WallProtocol {
    func printInfo() {
        print("墙面")
    }
}
class StickerDecorator: WallProtocol {
    var wall: Wall
    init(wall: Wall) {
        self.wall = wall
    }
    func printInfo() {
        print("贴纸装饰")
        self.wall.printInfo()
    }
}
let wall = Wall()
let stickerDecorator = StickerDecorator(wall: wall)
stickerDecorator.printInfo()

// 代理
class Patient {
    func describeCondition() -> String {
        let describe = "描述病情"
        print(describe)
        return describe
    }
}
class Doctor {
    func writPrescription(condition: String) -> String {
        let prescription = "依据病情: \(condition), 开的处方"
        print(prescription)
        return prescription
    }
}
class DoctorProxy {
    var patient: Patient
    init(patient: Patient) {
        self.patient = patient
    }
    func seeDoctor() {
        // 预约医生
        let doctor = reservation()
        // 病人描述病情
        let condition = self.patient.describeCondition()
        // 医生开处方
        doctor.writPrescription(condition: condition)
    }
    func reservation() -> Doctor {
        let doctor = Doctor()
        print("预约医生")
        return doctor
    }
}
let patient = Patient()
let doctorProxy = DoctorProxy(patient: patient)
doctorProxy.seeDoctor()


// 适配器
//struct User {
//    var name: String
//    var age: Int
//}
//struct UserV2 {
//    var nickName: String
//    var age: Int
//    var address: String
//}
//struct UserAdapter {
//    static func toUserV2(user: User) -> UserV2 {
//        return UserV2(nickName: user.name, age: user.age, address: "")
//    }
//}
//let user = User(name: "学伟", age: 18)
//let userV2 = UserAdapter.toUserV2(user: user)
//print(userV2)

// 桥接
//enum Color {
//    case red
//    case green
//}
//class Car {
//    var color: Color
//}
//class Saloon: Car {
//    print("我是轿车")
//}
//class Truck: Car {
//    print("我是卡车")
//}
//enum Color {
//    case red
//    case green
//}
//enum CarType {
//    case saloon
//    case truck
//    var name: String {
//        switch self {
//        case .saloon:
//            return "轿车"
//        case .truck:
//            return "卡车"
//        }
//    }
//}
//protocol CarProtocol {
//    var color: Color { get }
//    var carType: CarType { get }
//    func log()
//}
//extension CarProtocol {
//    func log() {
//        print("我是" + carType.name)
//    }
//}
//class Car: CarProtocol {
//    var color: Color
//    var carType: CarType
//    init(color: Color, carType: CarType) {
//        self.color = color
//        self.carType = carType
//    }
//}
//let car = Car(color: .red, carType: .saloon)
//car.log()

