//
//  main.cpp
//  ArithmeticDemo
//
//  Created by 邱学伟 on 2018/6/27.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#include <iostream>

struct ActList {
    ActList * next;
};

ActList * reverseList(ActList * head) {
    
    if (head == NULL || head -> next == NULL) {
        // 少于两个节点无需反转
        return head;
    }
    
    ActList * p;
    ActList * q;
    ActList * r;
    
    p = head;
    q = head -> next;
    head -> next = NULL;
    
    while (q) {
        r = q -> next;
        q -> next = p;
        
        p = q;
        q = r;
    }
    
    head = p;
    
    return head;
}

ActList * reverseList3 (ActList * head) {
    if (head == NULL || head -> next == NULL) {
        // 少于两个节点无需反转
        return head;
    }
    
    ActList *pre = NULL;
    ActList *next = NULL;
    while (head != NULL) {
        next = head -> next;
        head -> next = pre;
        
        pre = head;
        head = next;
    }
    
    return pre;
}

ActList * reverseList4 (ActList * head) {
    if (head == NULL || head -> next == NULL) {
        // 少于两个节点无需反转
        return head;
    }
    ActList *newHead = reverseList4(head -> next);
    
    head -> next -> next = head;
    head -> next = NULL;
    
    return newHead;
}


int main(int argc, const char * argv[]) {
    
    
    
    
    return 0;
}

