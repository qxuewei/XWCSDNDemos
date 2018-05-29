//
//  XWRealmSwiftDemoTests.swift
//  XWRealmSwiftDemoTests
//
//  Created by 邱学伟 on 2018/5/29.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

import XCTest

@testable import XWRealmSwiftDemo

class XWRealmSwiftDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInsterStudent() {
        let stu = Student()
        stu.name = "极客学伟"
        stu.age = 26
        stu.id = 2;
        
        let birthdayStr = "1993-06-10"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        stu.birthday = dateFormatter.date(from: birthdayStr)! as NSDate
        
        stu.weight = 160
        stu.address = "回龙观"
        
        XWRealmTool.insertStudent(by: stu)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
