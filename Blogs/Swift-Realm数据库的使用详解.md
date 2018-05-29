# Swift-Realm数据库的使用详解

![mobileDB_realm](http://p95ytk0ix.bkt.clouddn.com/2018-05-28-mobileDB_realm.png)

## 1. 概述
[Realm](https://github.com/realm/realm-cocoa/) 是一个跨平台的移动数据库引擎，其性能要优于 Core Data 和 FMDB - [移动端数据库性能比较](https://realm.io/blog/introducing-realm/#fast), 我们可以在 [Android 端 realm-java](https://github.com/realm/realm-java)，iOS端:[Realm-Cocoa](https://github.com/realm/realm-cocoa/)，同时支持 OC 和 Swift两种语言开发。其使用简单，免费，性能优异，跨平台的特点广受程序员GG喜爱。

### Realm 支持如下属性的存储

* Int，Int8，Int16，Int32 和 Int64
* Boolean 、 Bool
* Double 、 Float
* String
* NSDate 、 Date(精度到秒)
* NSData 、 Data
* 继承自 Object 的类 => 作为一对一关系（Used for One-to-one relations）
* List => 作为一对多关系（Used for one-to-many relations）

如下表是在代码中声明的实例：

| 类型 | 非可选值形式 | 可选值形式 |
| :------------ |---------------:| -----:|
| Bool  |	dynamic var value = false          | let value = RealmOptional<Bool>()|
| Int   |	dynamic var value = 0              | let value = RealmOptional<Int>() |
| Float |	dynamic var value: Float = 0.0     |let value = RealmOptional<Float>()|
| Double|  dynamic var value: Double = 0.0    |let value = RealmOptional<Double>()|
| String|  dynamic var value = ""             |dynamic var value: String? = nil|
| Data  |  dynamic var value = NSData()       |dynamic var value: NSData? = nil|
| Date  |	dynamic var value = NSDate()       |dynamic var value: NSDate? = nil|
| Object|必须是可选值	|dynamic var value: Class?|
| List  |	let value = List<Class>() |必须是非可选值 |
| LinkingObjects|	let value = LinkingObjects(fromType: Class.self, property: "property") |	必须是非可选值|


### Realm 安装 - 使用 CocoaPods

`pod 'RealmSwift'`
`pod 'Realm'`

## 2. Realm 使用

### 2.0 首先定义模型
``` objective-c
import UIKit
import RealmSwift

class Student: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 18
    @objc dynamic var weight = 156
    @objc dynamic var id = 0
    @objc dynamic var address = ""
    @objc dynamic var birthday : NSDate? = nil
    @objc dynamic var photo : NSData?  = nil
}

extension Student {
    /// 头像赋值
    public func setPhotoWitName(_ imageName : String) -> Void {
        let image = UIImage(named: imageName);
        guard image == nil else {
            self.photo = (UIImagePNGRepresentation(image!)! as NSData)
            return
        }
    }
    
    /// 获取头像
    public func getPhotoImage() -> UIImage? {
        return UIImage(data: self.photo! as Data);
    }
}
```

需要注意的是：
##### 在使用Realm中存储的数据模型都要是 `Object` 类的子类。

### 2.1 增

#### 需求： 插入 1 名学生信息到本地数据库？

```objective-c
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
   
    public class func insertStudent(by student : Student) -> Void {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(student)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
}
```
 
#### 测试在数据库中插入一条普通数据
```objective-c
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
```

通过 [Realm Browser](https://itunes.apple.com/cn/app/realm-browser/id1007457278?mt=12) 查看刚才保存的数据
通过 `print(realm.configuration.fileURL ?? "")` 打印数据路径

效果：
![Snip20180529_13](http://p95ytk0ix.bkt.clouddn.com/2018-05-29-Snip20180529_13.png)

#### 测试在数据库中插入一条带头像数据的模型


#### 2.2 查



