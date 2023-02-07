import Foundation

enum Foodtype {
    case a
    case b
}
enum Drink {
    case cola
    case juice
}
enum Staple {
    case hamburger
    case chickenRoll
}
class FoodPackage {
    var drink: Drink?
    var staple: Staple?
}
class BuildA {
    var foodPackage = FoodPackage()
    func build() -> FoodPackage {
        foodPackage.drink = .cola
        foodPackage.staple = .hamburger
        return foodPackage
    }
}
class BuildB {
    var foodPackage = FoodPackage()
    func build() -> FoodPackage {
        foodPackage.drink = .juice
        foodPackage.staple = .chickenRoll
        return foodPackage
    }
}
class FoodFactory {
    static func buildFood(type: Foodtype) -> FoodPackage {
        switch type {
        case .a:
            return BuildA().build()
        case .b:
            return BuildB().build()
        }
    }
}
let foodPackage = FoodFactory.buildFood(type: .a)
print(foodPackage.staple!)


enum Level {
    case low
    case high
}
protocol ComputerFactoryProtol {
    static func getComputer(level: Level) -> ComputerProtol
    static func getTV() -> TVProtol
}
protocol TVProtol {
    var name: String { get }
    func logName()
}
class TV: TVProtol {
    var name: String
    init(name: String) {
        self.name = name
    }
    func logName() {
        print(self.name)
    }
}
protocol ComputerProtol {
    var cpu: String { get }
    var host: String { get }
    var screen: String { get }
    var uuid: String { get }
    func logUUID()
}
class Computer: ComputerProtol {
    var cpu: String
    var host: String
    var screen: String
    var uuid: String
    init(cpu: String, host: String, screen: String) {
        self.cpu = cpu
        self.host = host
        self.screen = screen
        self.uuid = UUID().uuidString
    }
    func logUUID() {
        print(uuid)
    }
    func copy() -> Computer {
        return Computer(cpu: self.cpu, host: self.host, screen: self.screen)
    }
}
class ComputerFactory: ComputerFactoryProtol {
    static func getTV() -> TVProtol {
        return TV(name: "海尔")
    }
    static func getComputer(level: Level) -> ComputerProtol {
        switch level {
        case .low:
            return Computer(cpu: "Intel core i5 3300K", host: "GY088-GDF-10", screen: "1920 x 1080")
        case .high:
            return Computer(cpu: "Intel core i7 7700K", host: "GY088-GDF-60", screen: "3008 x 1692")
        }
    }
}
let computer1 = Computer(cpu: "Intel core i7 7700K", host: "GY088-GDF-60", screen: "3008 x 1692")
computer1.logUUID()
let computer2 = computer1.copy()
computer2.logUUID()
let computer3 = ComputerFactory.getComputer(level: .high)
computer3.logUUID()
let tv = ComputerFactory.getTV()
tv.logName()

