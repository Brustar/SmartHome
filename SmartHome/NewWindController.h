//
//  NewWindController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/9/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "PackManager.h"

@interface NewWindController : CustomViewController<TcpRecvDelegate>


@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *highSpeedBtn;
@property (weak, nonatomic) IBOutlet UIButton *middleSpeedBtn;
@property (weak, nonatomic) IBOutlet UIButton *lowSpeedBtn;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (nonatomic,assign) int roomID;
@property (nonatomic, strong) NSString *deviceID;



- (IBAction)powerBtnClicked:(id)sender;
- (IBAction)highSpeedBtnClicked:(id)sender;
- (IBAction)middleSpeedBtnClicked:(id)sender;
- (IBAction)lowSpeedBtnClicked:(id)sender;
@end
