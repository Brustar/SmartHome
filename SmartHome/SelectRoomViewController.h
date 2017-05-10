//
//  SelectRoomViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "SQLManager.h"
#import "Room.h"
#import "SelectDevicesOfRoomViewController.h"

@interface SelectRoomViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *roomArray;
@property(nonatomic, strong) UITableView *roomTableView;



@end
