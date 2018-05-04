//
//  RuntimeDemoTests.m
//  RuntimeDemoTests
//
//  Created by 邱学伟 on 2018/4/27.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "People.h"
#import <objc/runtime.h>

@protocol PeopleProcol <NSObject>
@end

@interface RuntimeDemoTests : XCTestCase

@end

@implementation RuntimeDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testBlock {
    IMP imp = imp_implementationWithBlock(^(id obj, NSString *str) {
        NSLog(@"testBlock - %@",str);
    });
    class_addMethod(<#Class  _Nullable __unsafe_unretained cls#>, <#SEL  _Nonnull name#>, <#IMP  _Nonnull imp#>, <#const char * _Nullable types#>)
}

- (void)testImage {
    NSLog(@"获取指定类所在动态库");
    NSLog(@"UIView's Framework: %s", class_getImageName(NSClassFromString(@"UIView")));
    NSLog(@"获取指定库或框架中所有类的类名");
    unsigned int outCount;
    const char ** classes = objc_copyClassNamesForImage(class_getImageName(NSClassFromString(@"UIView")), &outCount);
    for (int i = 0; i < outCount; i++) {
        NSLog(@"class name: %s", classes[i]);
    }
}


- (void)testCommonMethod {
//    for (int i = 0; i < 10000; i++) {
//        [self logMethod:i];
//    }
    //执行时长: Test Case '-[RuntimeDemoTests testCommonMethod]' passed (2.311 seconds).
    
//    if ([self respondsToSelector:@selector(logMethod:)]) {
//        [self performSelector:@selector(logMethod:) withObject:[NSNumber numberWithInt:10086]];
//    }
    
    People * people = [[People alloc] init];
    [people performSelector:@selector(people3log)];
}

- (void)testRuntimeMethod {
    void(*logM)(id, SEL, int);
    IMP imp = [self methodForSelector:@selector(logMethod:)];
    logM = (void(*)(id, SEL, int))imp;
    for (int i = 0; i < 10000; i++) {
        logM(self, @selector(logMethod:), i);
    }
    //执行时长: Test Case '-[RuntimeDemoTests testRuntimeMethod]' passed (2.199 seconds).
}

- (void)logMethod:(int)i {
    NSLog(@"%d",i);
}

- (void)testMethod {
    /*
    // 调用指定方法的实现
    id method_invoke (id receiver, Method m, ...);
    
    // 调用返回一个数据结构的方法的实现
    void method_invoke_stret (id receiver, Method m, ...);
    
    // 获取方法名
    SEL method_getName (Method m);
    
    // 获取方法的实现
    IMP method_getImplementation (Method m);
    
    // 获取描述方法参数和返回值类型的字符串
    const char * method_getTypeEncoding (Method m);
    
    // 获取方法的返回值类型的字符串
    char * method_copyReturnType ( Method m );
    
    // 获取方法的指定位置参数的类型字符串
    char * method_copyArgumentType ( Method m, unsigned int index );
    
    // 通过引用返回方法的返回值类型字符串
    void method_getReturnType ( Method m, char *dst, size_t dst_len );
    
    // 返回方法的参数的个数
    unsigned int method_getNumberOfArguments ( Method m );
    
    // 通过引用返回方法指定位置参数的类型字符串
    void method_getArgumentType ( Method m, unsigned int index, char *dst, size_t dst_len );
    
    // 返回指定方法的方法描述结构体
    struct objc_method_description * method_getDescription ( Method m );
    
    // 设置方法的实现
    IMP method_setImplementation ( Method m, IMP imp );
    
    // 交换两个方法的实现
    void method_exchangeImplementations ( Method m1, Method m2 );
     */
}


- (void)testCoder {
    NSString *key = @"peopleKey";
    People * people = [[People alloc] init];
    people.name = @"邱学伟";
    people.age = @18;
    NSData *peopleData = [NSKeyedArchiver archivedDataWithRootObject:people];
    [[NSUserDefaults standardUserDefaults] setObject:peopleData forKey:key];
    
    NSData *testData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    People *testPeople = [NSKeyedUnarchiver unarchiveObjectWithData:testData];
    NSLog(@"%@",testPeople.name);
}

- (void)testCreteInstance {
    id testInstance = class_createInstance([NSString class], sizeof(unsigned));
    id str1 = [testInstance init];
    NSLog(@"%@",[str1 class]);
    id str2 = @"Test";
    NSLog(@"%@",[str2 class]);
}

- (void)testAddClass {
    Class TestClass = objc_allocateClassPair([NSObject class], "myClass", 0);
    if (class_addIvar(TestClass, "myIvar", sizeof(NSString *), sizeof(NSString *), "@")) {
        NSLog(@"Add Ivar Success");
    }
    class_addMethod(TestClass, @selector(method1:), (IMP)method0, "v@:");
    // 注册这个类到runtime才可使用 ARC 失效
//    objc_registerClassPair(TestClass);
    
    // 生成一个实例化对象
    id myObjc = [[TestClass alloc] init];
    NSString *str = @"qiuxuewei";
    //给刚刚添加的变量赋值
    //object_setInstanceVariable(myobj, "myIvar", (void *)&str);在ARC下不允许使用
    [myObjc setValue:str forKey:@"myIvar"];
    [myObjc method1:10086];
}
- (void)method1:(int)a {
}
void method0(id self, SEL _cmd, int a) {
    Ivar v = class_getInstanceVariable([self class], "myIvar");
    id o = object_getIvar(self, v);
    NSLog(@"%@ \n int a is %d", o,a);
}

- (void)testVersion {
    int version = class_getVersion([People class]);
    NSLog(@"version %d",version);
    
    class_setVersion([People class], 10086);
    
    int nerVersion = class_getVersion([People class]);
    NSLog(@"nerVersion %d",nerVersion);
}

- (void)testProtocol {
    // 添加协议
    Protocol *p = @protocol(PeopleProcol);
    if (class_addProtocol([People class], p)) {
        NSLog(@"Add Protoclol Success");
    }else{
        NSLog(@"Add protocol Fail");
    }
    if (class_conformsToProtocol([People class], p)) {
        NSLog(@"实现了 PeopleProcol 协议");
    }else{
        NSLog(@"没有实现 PeopleProcol 协议");
    }
    unsigned int outCount;
    Protocol *__unsafe_unretained *protocolList = class_copyProtocolList([People class], &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Protocol *p = protocolList[i];
        const char *protocolName = protocol_getName(p);
        NSLog(@"协议名称: %s",protocolName);
    }
}

- (void)testProperty {
    objc_property_attribute_t attribute1 = {"T", "@\"NSString\""};
    objc_property_attribute_t attribute2 = {"C", ""};
    objc_property_attribute_t attribute3 = {"N", ""};
    objc_property_attribute_t attribute4 = {"V", "_addProperty"};
    objc_property_attribute_t attributesList[] = {attribute1, attribute2, attribute3, attribute4};
    BOOL isSuccessAddProperty = class_addProperty([People class], "addProperty", attributesList, 4);
    if (isSuccessAddProperty) {
        NSLog(@"Add Property Success");
    }else{
        NSLog(@"Add Property Error");
    }
    unsigned int outCount;
    objc_property_t * propertyList = class_copyPropertyList([People class], &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        objc_property_t property = propertyList[i];
        const char *propertyName = property_getName(property);
        const char *attribute = property_getAttributes(property);
        NSLog(@"propertyName: %s, attribute: %s", propertyName, attribute);
        unsigned int attributeCount;
        objc_property_attribute_t *attributeList = property_copyAttributeList(property, &attributeCount);
        for (unsigned int i = 0; i < attributeCount; i++) {
            objc_property_attribute_t attribute = attributeList[i];
            const char *name = attribute.name;
            const char *value = attribute.value;
            NSLog(@"attribute name: %s, value: %s",name,value);
        }
    }
}

//成员变量
- (void)testIvar {
    BOOL isSuccessAddIvar = class_addIvar([NSString class], "_phone", sizeof(id), log2(sizeof(id)), "@");
    if (isSuccessAddIvar) {
        NSLog(@"Add Ivar success");
    }else{
        NSLog(@"Add Ivar error");
    }
    unsigned int outCount;
    Ivar *ivarList = class_copyIvarList([People class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivarList[i];
        const char *ivarName = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        NSLog(@"ivar:%s, offset:%zd, type:%s", ivarName, offset, type);
    }
}

@end
