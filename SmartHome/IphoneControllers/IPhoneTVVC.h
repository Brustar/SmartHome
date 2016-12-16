//
//  IPhoneTVVC.h
//  SmartHome
//
//  Created by zhaona on 2016/12/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPhoneTVVC : UIViewController
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;
@property (strong, nonatomic) IBOutlet UISwitch *switchView;
@property (nonatomic,strong) Scene * scene;
@end
