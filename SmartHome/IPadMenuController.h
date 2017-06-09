//
//  IPadMenuController.h
//  SmartHome
//
//  Created by Brustar on 2017/5/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPadMenuController : UITableViewController

@property (nonatomic) int typeID;

@property (nonatomic) int roomID;

@property (nonatomic,strong) NSArray *types;

@end
