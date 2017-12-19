 //
//  GuardController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "GuardController.h"
#import "EntranceGuard.h"
#import "Scene.h"
#import "SceneManager.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SQLManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "UnlockViewController.h"

#define guardType @"智能门锁"

@interface GuardController ()

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSMutableArray *guardNames;
@property (nonatomic,strong) NSMutableArray *guardIDs;
@property (weak, nonatomic) IBOutlet UIButton *switcher;

@end

@implementation GuardController

-(NSMutableArray *)guardIDs
{
    if(!_guardIDs)
    {
        _guardIDs = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *guard = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < guard.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[guard[i] intValue]];
                if([typeName isEqualToString:guardType])
                {
                    [_guardIDs addObject:guard[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_guardIDs addObject:[SQLManager singleDeviceWithCatalogID:doorclock byRoom:self.roomID]];
        }else{
            [_guardIDs addObject:self.deviceid];
        }
    }
    return _guardIDs;
    
    
}
-(NSMutableArray *)guardNames
{
    if(!_guardNames)
    {
        
        _guardNames = [NSMutableArray array];
        
        for(int i = 0; i < self.guardIDs.count; i++)
        {
            int guardId = [self.guardIDs[i] intValue];
            [_guardNames addObject:[SQLManager deviceNameByDeviceID:guardId]];
        }

    }
    return _guardNames;
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    //iOS8.0后才支持指纹识别接口
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        return;
    }else{
        
        [self evaluateAuthenticate];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - %@",roomName,guardType]];
    
    self.deviceid = [SQLManager singleDeviceWithCatalogID:doorclock byRoom:self.roomID];
    
    [self.switcher setImage:[UIImage imageNamed:@"clock_open_pressed"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [[self.switcher rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         NSData *data = [[DeviceInfo defaultManager] toogle:0x01 deviceID:self.deviceid];
         SocketManager *sock=[SocketManager defaultManager];
         [sock.socket writeData:data withTimeout:1 tag:1];
     }];

    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
- (void)evaluateAuthenticate
{
    //创建LAContext
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    NSString* result = @"请验证已有指纹";
        context.localizedFallbackTitle = @"";
    //    context.localizedCancelTitle = @"6666";
    
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                //验证成功，主线程处理UI
                
            }
            
            else if (error)
            {
                if (error.code == -2) {//点击了取消按钮
                    NSLog(@"点击了取消按钮");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                    });
                }else if (error.code == -3){//点输入密码按钮
                    NSLog(@"点输入密码按钮");
                    dispatch_async(dispatch_get_main_queue(), ^{

                        UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
                        UnlockViewController * unlockVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"UnlockViewController"];
                       [self.navigationController pushViewController:unlockVC animated:YES];

                    });
                    
                  
                    
                }else if (error.code == -1){//连续三次指纹识别错误
                    NSLog(@"连续三次指纹识别错误");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                    });
                    
                }else if (error.code == -4){//按下电源键
                    NSLog(@"按下电源键");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                    });
                }else if (error.code == -8){//Touch ID功能被锁定，下一次需要输入系统密码
                    NSLog(@"Touch ID功能被锁定，下一次需要输入系统密码");

                    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"通过Home键验证已有手机指纹" reply:^(BOOL success, NSError * _Nullable error) {
                        
                    }];
                }
                
            }
            else
            {
                NSLog(@"error.localizedDescription:%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        //系统取消授权，如其他APP切入
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        //授权失败
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        //系统未设置密码
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        //设备Touch ID不可用，例如未打开
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        //设备Touch ID不可用，用户未录入
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码，切换主线程处理
                            
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
            }
        }];
    }
    else
    {
        //不支持指纹识别，LOG出错误详情
        NSLog(@"不支持指纹识别");
        
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01){
        //self.switchView.on = proto.action.state;
    }
    if (tag==0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            //self.switchView.on=proto.action.state;
        }
    }
}
    
#pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     id theSegue = segue.destinationViewController;
     [theSegue setValue:self.deviceid forKey:@"deviceid"];
 }

@end
