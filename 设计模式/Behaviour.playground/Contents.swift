import UIKit
// 行为型

// 解释器模式
class Interpreter {
    static func handler(string: String) {
        let proto = string.components(separatedBy: "://")
        if let pro = proto.first {
            print("路由协议: \(pro)")
            if proto.count > 1, let last = proto.last {
                let path = last.split(separator: "?", maxSplits: 2, omittingEmptySubsequences: true)
                if let pathFirst = path.first {
                    print("路由路径: \(pathFirst)")
                    if path.count > 1, let param = path.last {
                        print("路由参数: \(param)")
                    }
                }
            }
        }
    }
}
Interpreter.handler(string: "http://www.xxx.com?key=value")

// 备忘录模式
//protocol MementoProtocol {
//    func allKeys() -> [String]
//    func valueForKey(key: String) -> Any
//    func setValue(value: Any, key: String)
//}
//class Setting: MementoProtocol {
//    var setting1 = false
//    var setting2 = false
//    func allKeys() -> [String] {
//        return ["setting1", "setting2"]
//    }
//
//    func valueForKey(key: String) -> Any {
//        switch key {
//        case "setting1":
//            return setting1
//        case "setting2":
//            return setting2
//        default:
//            return ""
//        }
//    }
//
//    func setValue(value: Any, key: String) {
//        switch key {
//        case "setting1":
//            setting1 = value as? Bool ?? false
//        case "setting2":
//            setting2 = value as? Bool ?? false
//        default:
//            print("key: \(key) 设置错误")
//        }
//    }
//    func show() {
//        print("setting1: \(setting1) ++ setting2: \(setting2)")
//    }
//}
//class MementoManager {
//    var dictionary = [String: [String: Any]]()
//    func saveState(obj: MementoProtocol, stateName: String) {
//        var dict = [String: Any]()
//        for key in obj.allKeys() {
//            dict[key] = obj.valueForKey(key: key)
//        }
//        dictionary[stateName] = dict
//    }
//    func resetState(obj: MementoProtocol, stateName: String) {
//        if let dict = dictionary[stateName] {
//            for kv in dict {
//                obj.setValue(value: kv.value, key: kv.key)
//            }
//        }
//    }
//}
//var setting = Setting()
//let manager = MementoManager()
//setting.setting1 = true
//setting.setting2 = true
//manager.saveState(obj: setting, stateName: "vip")
//setting.setting2 = false
//manager.saveState(obj: setting, stateName: "super")
//setting.show()
//manager.resetState(obj: setting, stateName: "vip")
//setting.show()
//manager.resetState(obj: setting, stateName: "super")
//setting.show()


// 访问者模式
//struct Ticket {
//    var name: String
//}
//protocol Visitor {
//    func visit(ticket: Ticket)
//}
//class Tourist: Visitor {
//    func visit(ticket: Ticket) {
//        print("游客购买\(ticket.name)")
//    }
//}
//class Guard: Visitor {
//    func visit(ticket: Ticket) {
//        print("检票员检查了\(ticket.name)")
//    }
//}
//let ticket = Ticket(name: "公园门票")
//let tourist = Tourist()
//tourist.visit(ticket: ticket)
//let guarder = Guard()
//guarder.visit(ticket: ticket)

// 迭代器
//protocol Iterator {
//    associatedtype ObjectType
//    var cursor: Int { get }
//    func next() -> ObjectType?
//    func reset()
//}
//class School: Iterator {
//    private var teachers = [String]()
//    typealias ObjectType = String
//    var cursor: Int = 0
//    func next() -> String? {
//        if cursor < teachers.count {
//            let teacher = teachers[cursor]
//            cursor += 1
//            return teacher
//        } else {
//            return nil
//        }
//    }
//
//    func reset() {
//        cursor = 0
//    }
//
//    func addTeacher(name: String) {
//        teachers.append(name)
//    }
//}
//let school = School()
//school.addTeacher(name: "学伟")
//school.addTeacher(name: "小王")
//school.addTeacher(name: "乔布斯")
//while let teacher = school.next() {
//    print(teacher)
//}
//print("遍历完成")

// 中介者
//class ServerA {
//    func handleClientA() {
//        print("ServerA 处理 ClientA 的请求")
//    }
//    func handleClientB() {
//        print("ServerA 处理 ClientB 的请求")
//    }
//}
//class ServerB {
//    func handleClientA() {
//        print("ServerB 处理 ClientA 的请求")
//    }
//    func handleClientB() {
//        print("ServerB 处理 ClientB 的请求")
//    }
//}
//class ClientA {}
//class ClientB {}
//class Mediator {
//    static func handler(client: AnyObject, server: AnyObject) {
//        if client is ClientA {
//            if server is ServerA {
//                ServerA().handleClientA()
//            } else {
//                ServerB().handleClientA()
//            }
//        } else {
//            if server is ServerA {
//                ServerA().handleClientB()
//            } else {
//                ServerB().handleClientB()
//            }
//        }
//    }
//}
//let clientA = ClientA()
//let clientB = ClientB()
//let serverA = ServerA()
//let serverB = ServerB()
//Mediator.handler(client: clientA, server: serverA)
//Mediator.handler(client: clientA, server: serverB)
//Mediator.handler(client: clientB, server: serverA)
//Mediator.handler(client: clientB, server: serverB)
//class ServerA {
//    func handleClientA() {
//        print("ServerA 处理 ClientA 的请求")
//    }
//    func handleClientB() {
//        print("ServerA 处理 ClientB 的请求")
//    }
//}
//class ServerB {
//    func handleClientA() {
//        print("ServerB 处理 ClientA 的请求")
//    }
//    func handleClientB() {
//        print("ServerB 处理 ClientB 的请求")
//    }
//}
//class ClientA {
//    func requestServerA() {
//        ServerA().handleClientA()
//    }
//    func requestServerB() {
//        ServerB().handleClientA()
//    }
//}
//class ClientB {
//    func requestServerA() {
//        ServerA().handleClientB()
//    }
//    func requestServerB() {
//        ServerB().handleClientB()
//    }
//}
//let clientA = ClientA()
//clientA.requestServerA()
//clientA.requestServerB()
//let clientB = ClientB()
//clientB.requestServerA()
//clientB.requestServerB()

// 观察者
//typealias XWNotificationCallback = (XWNotification) -> Void
//struct XWNotification {
//    var name: String
//    var data: String
//    var object: AnyObject?
//    func info() {
//        print("name: \(name), data: \(data), object: \(String(describing: object))")
//    }
//}
//struct XWObsever {
//    var object: AnyObject
//    var callback: XWNotificationCallback
//}
//class XWNotificationCenter {
//    static let shared = XWNotificationCenter()
//    private var observers = Dictionary<String, Array<XWObsever>>()
//    private init() {}
//    func addObserver(name: String, object: AnyObject, callback: @escaping XWNotificationCallback) {
//        let observer = XWObsever(object: object, callback: callback)
//        if var curObserver = observers[name] {
//            curObserver.append(observer)
//        } else {
//            observers[name] = [observer]
//        }
//    }
//    func removeObserver(name: String) {
//        observers.removeValue(forKey: name)
//    }
//    func postNotification(notification: XWNotification) {
//        if let array = observers[notification.name] {
//            var postNotification = notification
//            for observer in array {
//                postNotification.object = observer.object
//                observer.callback(postNotification)
//            }
//        }
//    }
//}
//let key = "KEY"
//XWNotificationCenter.shared.addObserver(name: key, object: "监听者A" as AnyObject) { noti in
//    noti.info()
//}
////XWNotificationCenter.shared.removeObserver(name: key)
//XWNotificationCenter.shared.postNotification(notification: XWNotification(name: key, data: "通知内容"))

// 状态模式
//class StateContent {
//    var currentState: State
//    init(_ currentState: State) {
//        self.currentState = currentState
//    }
//    func changeState(curState: State) {
//        self.currentState = curState
//    }
//}
//protocol State {
//    func info()
//    func doAction(content: StateContent)
//}
//class Open: State {
//    func info() {
//        print("开灯")
//    }
//    func doAction(content: StateContent) {
//        content.currentState = Open()
//    }
//}
//class Close: State {
//    func info() {
//        print("关灯")
//    }
//    func doAction(content: StateContent) {
//        content.currentState = Close()
//    }
//}
//class LightButton {
//    var stateContent: StateContent
//    init(state: State) {
//        self.stateContent = StateContent(state)
//    }
//    func change(state: State) {
//        self.stateContent.changeState(curState: state)
//    }
//    func log() {
//        stateContent.currentState.info()
//    }
//}
//let light = LightButton(state: Close())
//light.log()
//light.change(state: Open())
//light.log()

// 责任链
//struct Requet {
//    enum Level {
//        case low
//        case middle
//        case high
//    }
//    var level: Level
//}
//protocol Handler {
//    var nextHandler: Handler? { get }
//    func handlerRequest(request: Requet)
//    func nextHanderDo(request: Requet)
//}
//extension Handler {
//    func nextHanderDo(request: Requet) {
//        if let nextHandler = nextHandler {
//            nextHandler.handlerRequest(request: request)
//        } else {
//            print("无法处理请求")
//        }
//    }
//}
//class HighHandler: Handler {
//    var nextHandler: Handler? = nil
//    func handlerRequest(request: Requet) {
//        if request.level == .high {
//            print("HighHandler 处理请求")
//        } else {
//            nextHanderDo(request: request)
//        }
//    }
//}
//class MiddleHandler: Handler {
//    var nextHandler: Handler? = HighHandler()
//    func handlerRequest(request: Requet) {
//        if request.level == .middle {
//            print("MiddleHandler 处理请求")
//        } else {
//            nextHanderDo(request: request)
//        }
//    }
//}
//class LowHandler: Handler {
//    var nextHandler: Handler? = MiddleHandler()
//    func handlerRequest(request: Requet) {
//        if request.level == .low {
//            print("LowHandler 处理请求")
//        } else {
//            nextHanderDo(request: request)
//        }
//    }
//}
//class Chain: Handler {
//    var nextHandler: Handler? = LowHandler()
//    func handlerRequest(request: Requet) {
//        nextHandler?.handlerRequest(request: request)
//    }
//}
//var request = Requet(level: .low)
//Chain().handlerRequest(request: request)
//request = Requet(level: .middle)
//Chain().handlerRequest(request: request)
//request = Requet(level: .high)
//Chain().handlerRequest(request: request)



// 命令模式
//struct Teacher {
//    var name: String
//    var subject: String
//    func log() {
//        print("\(name) + \(subject)")
//    }
//}
//class School {
//    var teachers = [Teacher]()
//    func addTeacher(name: String, subject: String) {
//        teachers.append(Teacher(name: name, subject: subject))
//    }
//    func deleteTeacher(name: String) {
//        teachers = teachers.filter {$0.name != name}
//    }
//    func show() {
//        for teacher in teachers {
//            teacher.log()
//        }
//    }
//}
//let school = School()
//school.addTeacher(name: "学伟", subject: "计算机")
//school.addTeacher(name: "张三", subject: "体育")
//school.addTeacher(name: "李四", subject: "数学")
//school.show()
//school.deleteTeacher(name: "李四")
//school.show()

//struct Teacher {
//    var name: String
//    var subject: String
//    func log() {
//        print("\(name) + \(subject)")
//    }
//}
//class SchoolCommand {
//    enum ActionType {
//        case add
//        case delete
//        case show
//    }
//    var type: ActionType
//    var name: String?
//    var subject: String?
//    init(type: ActionType, name: String? = nil, subject: String? = nil) {
//        self.type = type
//        self.name = name
//        self.subject = subject
//    }
//}
//class School {
//    var teachers = [Teacher]()
//    func runCommand(command: SchoolCommand) {
//        switch command.type {
//        case .add:
//            addTeacher(name: command.name!, subject: command.subject!)
//        case .delete:
//            deleteTeacher(name: command.name!)
//        case .show:
//            show()
//        }
//    }
//    private func addTeacher(name: String, subject: String) {
//        teachers.append(Teacher(name: name, subject: subject))
//    }
//    private func deleteTeacher(name: String) {
//        teachers = teachers.filter {$0.name != name}
//    }
//    private func show() {
//        for teacher in teachers {
//            teacher.log()
//        }
//    }
//}
//let school = School()
//school.runCommand(command: SchoolCommand(type: .add, name: "学伟", subject: "计算机"))
//school.runCommand(command: SchoolCommand(type: .add, name: "张三", subject: "体育"))
//school.runCommand(command: SchoolCommand(type: .add, name: "李四", subject: "数学"))
//school.runCommand(command: SchoolCommand(type: .show))
//school.runCommand(command: SchoolCommand(type: .delete,name: "李四"))
//school.runCommand(command: SchoolCommand(type: .show))


// 策略模式
//protocol Transport {
//    func toDestination()
//}
//class Taxi: Transport {
//    func toDestination() {
//        print("出租车")
//    }
//}
//class Bus: Transport {
//    func toDestination() {
//        print("公交车")
//    }
//}
//class Subway: Transport {
//    func toDestination() {
//        print("地铁")
//    }
//}
//class Action {
//    var destination: String
//    var transport: Transport
//    init(destination: String, transport: Transport) {
//        self.destination = destination
//        self.transport = transport
//    }
//    func go() {
//        self.transport.toDestination()
//    }
//}
//let action = Action(destination: "北京", transport: Subway())
//action.go()


// 模板方法
//class Management {
//    func clockIn() {
//        print("上班")
//    }
//    func working() {
//        print("工作")
//    }
//    func clockOut() {
//        print("下班")
//    }
//    func start() {
//        clockIn()
//        working()
//        clockOut()
//    }
//}
//class Engineer: Management {
//    override func working() {
//        print("软件设计")
//    }
//}

