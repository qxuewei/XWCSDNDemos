import UIKit
import Foundation

class Suject {
    var name: String
    init(_ name: String) {
        self.name = name
    }
}
class Teacher {
    var name: String
    var subject: Suject
    init(_ name: String, subject: String) {
        self.name = name
        self.subject = Suject(subject)
    }
    func teach() {
        print("\(name)讲\(subject.name)课")
    }
}
let james = Teacher("james", subject: "数学")
james.teach()
let davis = Teacher("davis", subject: "英语")
davis.teach()

class MathTeacher: Teacher {
    override func teach() {
        print("\(name)讲数学课")
    }
}
class EnglishTeacher: Teacher {
    override func teach() {
        print("\(name)讲英语课")
    }
}

