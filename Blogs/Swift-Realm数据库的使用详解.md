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

### Realm 安装 - 使用 CocoaPods
Swift 语言:
`pod 'RealmSwift'`

Objective-C 语言：
`pod 'Realm'`

## 2. Realm 使用
### 2.1 增

#### 需求： 插入 4 名学生信息到本地数据库？

定义学生模型


