//
//  XWRealmTool.swift
//  XWRealmSwiftDemo
//
//  Created by 邱学伟 on 2018/5/29.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

import UIKit
import RealmSwift
class XWRealmTool: Object {
    private class func getDB() -> Realm {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/defaultDB.realm")
        /// 传入路径会自动创建数据库
        let defaultRealm = try! Realm(fileURL: URL.init(string: dbPath)!)
        return defaultRealm
    }
}
/// 增
extension XWRealmTool {
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
extension XWRealmTool {
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
}
