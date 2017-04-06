//
//  Keypad.h
//  SmartHome
//
//  Created by Brustar on 2017/4/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keypad : NSObject
//keypad id
@property (nonatomic) NSInteger keypadID;
//房间id
@property (nonatomic) NSInteger roomID;
//key列表
@property (strong,nonatomic) NSArray *keys;

@end
