//
//  FirstViewController.h
//  
//
//  Created by zhaona on 2017/3/17.
//
//

#define BLUETOOTH_MUSIC false

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import <AFNetworking.h>

@interface FirstViewController : CustomViewController
@property (nonatomic, assign) NSInteger playState;//播放状态： 0:停止 1:播放
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;

@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, readonly) UIButton *naviMiddletBtn;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;
@property (weak, nonatomic) IBOutlet UIView *SupView;
@property (weak, nonatomic) IBOutlet UIView *CoverView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
