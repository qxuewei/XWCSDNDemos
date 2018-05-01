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
