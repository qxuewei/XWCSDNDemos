# Swift-Realm数据库的使用详解

![mobileDB_realm](http://p95ytk0ix.bkt.clouddn.com/2018-05-28-mobileDB_realm.png)

## 1. 概述
[Realm](https://github.com/realm/realm-cocoa/) 是一个跨平台的移动数据库引擎，其性能要优于 Core Data 和 FMDB - [移动端数据库性能比较](https://realm.io/blog/introducing-realm/#fast), 我们可以在 [Android 端 realm-java](https://github.com/realm/realm-java)，iOS端:[Realm-Cocoa](https://github.com/realm/realm-cocoa/)，同时支持 OC 和 Swift两种语言开发。其使用简单，免费，性能优异，跨平台的特点广受程序员GG喜爱。

[Realm 中文文档](https://realm.io/cn/docs/swift/latest/)

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
本文将结合一些实战演练讲解 Realm 的用法，干货满满！

### 2.0 定义模型
``` objective-c
import UIKit
import RealmSwift

class Book: Object {
    @objc dynamic var name = ""
    @objc dynamic var author = ""
    
    /// LinkingObjects 反向表示该对象的拥有者
    let owners = LinkingObjects(fromType: Student.self, property: "books")
}

class Student: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 18
    @objc dynamic var weight = 156
    @objc dynamic var id = 0
    @objc dynamic var address = ""
    @objc dynamic var birthday : NSDate? = nil
    @objc dynamic var photo : NSData?  = nil
    
    //重写 Object.primaryKey() 可以设置模型的主键。
    //声明主键之后，对象将被允许查询，更新速度更加高效，并且要求每个对象保持唯一性。
    //一旦带有主键的对象被添加到 Realm 之后，该对象的主键将不可修改。
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //重写 Object.ignoredProperties() 可以防止 Realm 存储数据模型的某个属性
    override static func ignoredProperties() -> [String] {
        return ["tempID"]
    }
    
    //重写 Object.indexedProperties() 方法可以为数据模型中需要添加索引的属性建立索引，Realm 支持为字符串、整型、布尔值以及 Date 属性建立索引。
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
    //List 用来表示一对多的关系：一个 Student 中拥有多个 Book。
    let books = List<Book>()
}

```

##### 需要注意的是：在使用Realm中存储的数据模型都要是 `Object` 类的子类。

#### 1) 设置主键 - primaryKey
重写 Object.primaryKey() 可以设置模型的主键。
声明主键之后，对象将被允许查询，更新速度更加高效，并且要求每个对象保持唯一性。
一旦带有主键的对象被添加到 Realm 之后，该对象的主键将不可修改。

```objective-c
    override static func primaryKey() -> String? {
        return "id"
    }
```
#### 2) 忽略属性 - ignoredProperties
重写 Object.ignoredProperties() 可以防止 Realm 存储数据模型的某个属性。Realm 将不会干涉这些属性的常规操作，它们将由成员变量(var)提供支持，并且您能够轻易重写它们的 setter 和 getter。

```objective-c
    override static func ignoredProperties() -> [String] {
        return ["tempID"]
    }
```

#### 3）索引属性 - indexedProperties
重写 Object.indexedProperties() 方法可以为数据模型中需要添加索引的属性建立索引，Realm 支持为字符串、整型、布尔值以及 Date 属性建立索引。

```objective-c
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
```

#### 4）使用List实现一对多关系 - indexedProperties
List 用来表示一对多的关系：一个 Student 中拥有多个 Book。
List 中可以包含简单类型的 Object，表面上和可变的 Array 非常类似,所用的方法和访问数据的方式（索引和下标）都相同，并且所包含的所有对象都应该是相同类型的。声明前面不可加 dynamic ，因为在 Objective-C 运行时无法表示泛型属性。
注意：List 只能够包含 Object 类型，不能包含诸如String之类的基础类型。

```objective-c
    //List 用来表示一对多的关系：一个 Student 中拥有多个 Book。
    let books = List<Book>()
```
#### 5）反向关系 - LinkingObjects
通过反向关系(也被称为反向链接(backlink))，您可以通过一个特定的属性获取和给定对象有关系的所有对象。 Realm 提供了“链接对象 (linking objects)” 属性来表示这些反向关系。借助链接对象属性，您可以通过指定的属性来获取所有链接到指定对象的对象。
例如：一个 Book 对象可以拥有一个名为 owners 的链接对象属性，这个属性中包含了某些 Student 对象，而这些 Student 对象在其 books 属性中包含了这一个确定的 Book 对象。您可以将 owners 属性设置为 LinkingObjects 类型，然后指定其关系，说明其当中包含了其拥有者 Student 对象。


```objective-c
  let owners = LinkingObjects(fromType: Student.self, property: "books")
```


### 1 增

#### 1.1 需求： 插入 1 名学生信息到本地数据库？

```objective-c
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
   
    public class func insertStudent(by student : Student) -> Void {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(student)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
}
```

##### 测试代码

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
        
        XWStudentRealmTool.insertStudent(by: stu)
    }
```

通过 [Realm Browser](https://itunes.apple.com/cn/app/realm-browser/id1007457278?mt=12) 查看刚才保存的数据
通过 `print(realm.configuration.fileURL ?? "")` 打印数据路径

效果：
![Snip20180529_13](http://p95ytk0ix.bkt.clouddn.com/2018-05-29-Snip20180529_13.png)

#### 1.2 需求: 测试在数据库中插入一个拥有多本书并且有头像的学生对象

###### 测试代码
```objective-c
//测试在数据库中插入一个拥有多本书并且有头像的学生对象
    func testInsertStudentWithPhotoBook() {
        let stu = Student()
        stu.name = "极客学伟_有头像_有书"
        stu.weight = 151;
        stu.age = 26
        stu.id = 3;
        // 头像
        stu.setPhotoWitName("cat")

        let bookFubaba = Book.init(name: "富爸爸穷爸爸", author: "[美]罗伯特.T.清崎")
        let bookShengmingbuxi = Book.init(name: "生命不息, 折腾不止", author: "罗永浩")
        let bookDianfuzhe = Book(value: ["颠覆着: 周鸿祎自传","周鸿祎"])
        stu.books.append(bookFubaba);
        stu.books.append(bookShengmingbuxi);
        stu.books.append(bookDianfuzhe);
        
        XWStudentRealmTool.insertStudent(by: stu)
    }
```
运行结果：
会自动创建数据库并新建两个表 Student 和 Book, 并将两者进行关联
![Snip20180530_17](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_17.png)
![Snip20180530_18](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_18.png)

#### 1.3 需求: 测试在数据库中插入44个的学生对象

保存方法

```objective-c
/// 保存一些Student
    public class func insertStudents(by students : [Student]) -> Void {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(students)
        }
        print(defaultRealm.configuration.fileURL ?? "")
    }
```
###### 测试代码

```objective-c
    //测试在数据库中插入多个拥有多本书并且有头像的学生对象
    func testInsertManyStudent() {
        var stus = [Student]()
        
        for i in 100...144 {
            let stu = Student()
            stu.name = "极客学伟_\(i)"
            stu.weight = 151;
            stu.age = 26
            stu.id = i;
            // 头像
            stu.setPhotoWitName("cat")
            let birthdayStr = "1993-06-10"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            stu.birthday = dateFormatter.date(from: birthdayStr)! as NSDate
            stus.append(stu)
        }
        
        XWStudentRealmTool.insertStudents(by: stus)
    }
```
演示结果：
![Snip20180530_22](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_22.png)


### 2 查
#### 2.1 普通查询： 查询数据库中所有学生模型并输出姓名，图片，所拥有的书信息

```objective-c
  /// 获取 所保存的 Student
    public class func getStudents() -> Results<Student> {
        let defaultRealm = self.getDB()
        return defaultRealm.objects(Student.self)
    }
```
###### 测试代码

```objective-c
     let stus = XWStudentRealmTool.getStudents()
        for stu in stus {
            print(stu.name)
            if stu.photo != nil {
                self.imageV.image = stu.getPhotoImage()
            }
            if stu.books.count > 0 {
                for book in stu.books {
                    print(book.name + "+" + book.author)
                }
            }
        }
```
演示结果：
输出姓名和书籍信息
![Snip20180530_20](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_20.png)

将获取的头像为imageView赋值
![Snip20180530_21](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_21.png)

#### 2.2 主键查询： 查询数据库中id 为 110 的学生模型并输出姓名

```objective-c
    /// 获取 指定id (主键) 的 Student
    public class func getStudent(from id : Int) -> Student? {
        let defaultRealm = self.getDB()
        return defaultRealm.object(ofType: Student.self, forPrimaryKey: id)
    }
```

###### 测试代码

```objective-c
 // 通过主键查询
    func testSearchStudentByID(){
        let student = XWStudentRealmTool.getStudent(from: 110)
        if let studentL = student {
            print(studentL.name)
        }
    }
```

演示结果：
![Snip20180530_24](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_24.png)

对应数据库中：
![Snip20180530_26](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_26.png)

#### 2.2 主键查询： 查询数据库中id 为 110 的学生模型并输出姓名

```objective-c
    /// 获取 指定条件 的 Student
    public class func getStudentByTerm(_ term: String) -> Results<Student> {
        let defaultRealm = self.getDB()
        print(defaultRealm.configuration.fileURL ?? "")
        let predicate = NSPredicate(format: term)
        let results = defaultRealm.objects(Student.self)
        return  results.filter(predicate)
    }
```

###### 测试代码

```objective-c
    // 条件查询
    func testSearchTermStudent()  {
        let students = XWStudentRealmTool.getStudentByTerm("name = '极客学伟_110'")
        if students.count == 0 {
            print("未查询到任何数据")
            return
        }
        for student in students {
            print(student.name,student.weight)
        }
    }
```
输出结果：
![Snip20180530_27](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_27.png)

#### 升序/降序 查询

``` objective-c
// 根据名字升序查询
let stus = realm.objects(Student.self).sorted(byKeyPath: "id")

// 根据名字降序序查询
let stus = realm.objects(Student.self).sorted(byKeyPath: "id", ascending: false)

```

### 3 改

#### 3.1 主键更新 - 更新单个学生
```objective-c
    /// 更新单个 Student
    public class func updateStudent(student : Student) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(student, update: true)
        }
    }
``` 

#### 3.2 主键更新 - 更新多个学生

```objective-c
    /// 更新多个 Student
    public class func updateStudent(students : [Student]) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            defaultRealm.add(students, update: true)
        }
    }
```

测试代码

```objective-c
    /// 批量更改
    func testUpdateStudents() {
        var stus = [Student]()
        for i in 100...144 {
            let stu = Student()
            stu.name = "极客学伟改名_\(i)"
            stu.weight = 148;
            stu.age = 27
            stu.id = i;
            stus.append(stu)
        }
        XWStudentRealmTool.updateStudent(students: stus)
    }
```
更新之前：
![Snip20180530_30](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_30.png)

更新之后：
![Snip20180530_31](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_31.png)


#### 3.3 键值更新 - 所有学生 年龄 改为 18

```objective-c
    /// 更新多个 Student
    public class func updateStudentAge(age : Int) {
        let defaultRealm = self.getDB()
        try! defaultRealm.write {
            let students = defaultRealm.objects(Student.self)
            students.setValue(age, forKey: "age")
        }
    }
```
测试代码：

```objective-c
    /// 批量更改年龄
    func testUpdateStudentsAge() {
        XWStudentRealmTool.updateStudentAge(age: 18)
    }
```

演示结果：
![Snip20180530_32](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_32.png)

### 4 删

```objective-c
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
```

测试代码：

```objective-c
    /// 删除id 为 3 的学生
    func testDeleteOneStudent() {
        let stu = XWStudentRealmTool.getStudent(from: 3)
        if stu != nil {
            XWStudentRealmTool.deleteStudent(student: stu!)
        }
    }
    
    /// 删除所有
    func testDeleteAllStudent() {
        let stus = XWStudentRealmTool.getStudents()
        XWStudentRealmTool.deleteStudent(students: stus)
    }
```

删除后的数据库：
![Snip20180530_33](http://p95ytk0ix.bkt.clouddn.com/2018-05-30-Snip20180530_33.png)
 
 
#### 空空如也

 文中所有演示代码 -> [XWRealmSwiftDemo In Github]()

