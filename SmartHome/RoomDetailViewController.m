//
//  RoomDetailViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "RoomDetailViewController.h"

@interface RoomDetailViewController ()

@end

@implementation RoomDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataSource];
    
    
    
}

- (void)initDataSource {
    _deviceTypes = [NSMutableArray arrayWithArray:[SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID]];//设备大类];
    
    if (_deviceTypes.count >0) {
        _deviceSubTypes = [NSMutableArray arrayWithArray:[SQLManager getDeviceTypeName:self.roomID subTypeName:_deviceTypes[0]]];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
