//
//  IPadDevicesView.h
//  SmartHome
//
//  Created by Brustar on 2017/6/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPadDevicesView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *menu;
@property (weak, nonatomic) IBOutlet UITableView *content;
@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *menus;
@property (nonatomic,strong) NSArray *devices;
@property (nonatomic,strong) NSArray *temp;
-(void)initData;

@end
