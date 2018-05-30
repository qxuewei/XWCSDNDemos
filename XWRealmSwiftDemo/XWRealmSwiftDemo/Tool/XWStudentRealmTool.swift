//
//  XWStudentRealmTool.swift
//  XWRealmSwiftDemo
//
//  Created by 邱学伟 on 2018/5/30.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

import UIKit
import RealmSwift

class XWStudentRealmTool: Object {
    private class func getDB() -> Realm {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/defaultDB.realm")
        /// 传入路径会自动创建数据库
        let defaultRealm = try! Realm(fileURL: URL.init(string: dbPath)!)
        return defaultRealm
    }
}

/// 增
extension XWStudentRealmTool {
    /// 保存一个Student
    public class func insertStudent(by student : Student) -> Void {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(student)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
    /// 保存一些Student
    public class func insertStudents(by students : [Student]) -> Void {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(students)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
    
}

/// 查
extension XWStudentRealmTool {
    /// 获取 所保存的 Student
    public class func getStudents() -> Results<Student> {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(Student.self)
    }
    
    /// 获取 指定id (主键) 的 Student
    public class func getStudent(from id : Int) -> Student? {
        let defaultRealm = self.getDB()
        return defaultRealm.object(ofType: Student.self, forPrimaryKey: id)
    }
    
    /// 获取 指定条件 的 Student
    public class func getStudentByTerm(_ term: String) -> Results<Student> {
        let defaultRealm = self.getDB()
        print(defaultRealm.configuration.fileURL ?? "")
        let predicate = NSPredicate(format: term)
        let results = defaultRealm.objects(Student.self)
        return  results.filter(predicate)
    }
    
    /// 获取 学号升降序 的 Student
    public class func getStudentByIdSorted(_ isAscending: Bool) -> Results<Student> {
        let defaultRealm = self.getDB()
        print(defaultRealm.configuration.fileURL ?? "")
        let results = defaultRealm.objects(Student.self)
        return  results.sorted(byKeyPath: "id", ascending: isAscending)
    }
}

/// 改
extension XWStudentRealmTool {
    /// 更新单个 Student
    public class func updateStudent(student : Student) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(student, update: true)
        }
    }
    
    /// 更新多个 Student
    public class func updateStudent(students : [Student]) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(students, update: true)
        }
    }
    
    /// 更新多个 Student
    public class func updateStudentAge(age : Int) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            let students = defaultRealm.objects(Student.self)
            students.setValue(age, forKey: "age")
        }
    }
    
}

/// 删
extension XWStudentRealmTool {
    /// 删除单个 Student
    public class func deleteStudent(student : Student) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.delete(student)
        }
    }
    
    /// 删除多个 Student
    public class func deleteStudent(students : Results<Student>) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.delete(students)
        }
    }
}
