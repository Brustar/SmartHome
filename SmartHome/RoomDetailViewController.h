//
//  RoomDetailViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLManager.h"



@interface RoomDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *deviceTypeTableView;
@property (weak, nonatomic) IBOutlet UITableView *deviceSubTypeTableView;

@property(nonatomic, strong) NSMutableArray *deviceTypes;
@property(nonatomic, strong) NSMutableArray *deviceSubTypes;
@property(nonatomic, assign) int roomID;

@end
