// 结构型设计模式
import UIKit

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
struct User {
    var name: String
    var age: Int
}
struct UserV2 {
    var nickName: String
    var age: Int
    var address: String
}
struct UserAdapter {
    static func toUserV2(user: User) -> UserV2 {
        return UserV2(nickName: user.name, age: user.age, address: "")
    }
}
let user = User(name: "学伟", age: 18)
let userV2 = UserAdapter.toUserV2(user: user)
print(userV2)
