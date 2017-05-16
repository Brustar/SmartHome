//
//  ECMessage.h
//  SmartHome
//
//  Created by Brustar on 2017/5/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECMessage : NSObject

@property(nonatomic,copy) NSString *descr;
@property(nonatomic) int readed;
@property(nonatomic,copy) NSString *atime;
@property(nonatomic) int MID;

@end
