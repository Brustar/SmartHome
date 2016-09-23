//
//  IphoneDeviceListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//



#import "IphoneDeviceListController.h"
#import "SQLManager.h"
#import "RoomManager.h"
#import "Room.h"
#import "LightController.h"
#import "CurtainController.h"
#import "IphoneTVController.h"
#import "DVDController.h"
#import "NetvController.h"
#import "FMController.h"
#import "IphoneAirController.h"
#import "PluginViewController.h"
#import "CameraController.h"
#import "GuardController.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
#import "IphoneRoomView.h"
#import "MBProgressHUD+NJ.h"
#import "AmplifierController.h"
#import "WindowSlidingController.h"
#import "BgMusicController.h"
@interface IphoneDeviceListController ()<IphoneRoomViewDelegate>


@property (nonatomic,strong) NSArray *deviceSubTypes;
@property (nonatomic,strong) NSArray *deviceTypes;
@property (weak, nonatomic) IBOutlet UIView *detailView;

@property (nonatomic,strong) UIButton *typeSelectedBtn;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *rooms;
@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet IphoneRoomView *iphoneRoomView;
@property (nonatomic, assign) int roomIndex;
@property (weak, nonatomic) IBOutlet IphoneRoomView *deviceTypeView;

@end

@implementation IphoneDeviceListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rooms = [SQLManager getAllRoomsInfo];
    
    [self setUpRoomScrollerView];
    //   [self setUpScrollerView];
    
}


-(void)setUpScrollerView
{
    self.deviceTypeView.dataArray = self.deviceTypes;
    
    self.deviceTypeView.delegate = self;
    
    [self.deviceTypeView setSelectButton:0];
    
    [self iphoneRoomView:self.deviceTypeView didSelectButton:0];
}
-(void)setUpRoomScrollerView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (Room *room in self.rooms) {
        NSString *roomName = room.rName;
        [roomNames addObject:roomName];
    }
    self.iphoneRoomView.dataArray = roomNames;
    
    self.iphoneRoomView.delegate = self;
    
    [self.iphoneRoomView setSelectButton:0];
    
    [self iphoneRoomView:self.iphoneRoomView didSelectButton:0];
}


- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    if (view == self.iphoneRoomView) {
        self.roomIndex = index;
        Room *room = self.rooms[index];
        self.deviceTypes = [SQLManager deviceSubTypeByRoomId:room.rId];
        [self setUpScrollerView];
    } else {
        if (self.deviceTypes.count < 1) {
            [MBProgressHUD showError:@"该房间没有设备"];
            if (self.currentViewController != nil) {
                [self.currentViewController.view removeFromSuperview];
                [self.currentViewController removeFromParentViewController];
            }
            return;
        }
        
        [self selectedType:self.deviceTypes[index]];
        
        
    }
}


-(void)selectedType:(NSString *)typeName
{
    Room *room = self.rooms[self.roomIndex];
    int roomID = room.rId;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    if([typeName isEqualToString:@"网络电视"])
    {
        IphoneTVController *tVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneTVController"];
        tVC.roomID = roomID;
        
        [self addViewAndVC:tVC];
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        ligthVC.roomID = roomID;
        
        [self addViewAndVC:ligthVC];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
        curtainVC.roomID = roomID;
        
        [self addViewAndVC:curtainVC];
        
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
        DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
        dvdVC.roomID = roomID;
        
        [self addViewAndVC:dvdVC];
        
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
        fmVC.roomID = roomID;
        [self addViewAndVC:fmVC];
        
    }else if([typeName isEqualToString:@"空调"])
    {
        IphoneAirController *airVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneAirController"];
        airVC.roomID = roomID;
        [self addViewAndVC:airVC];
        
    }else if([typeName isEqualToString:@"机顶盒"]){
        NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
        netVC.roomID = roomID;
        
        [self addViewAndVC:netVC];
        
    }else if([typeName isEqualToString:@"摄像头"]){
        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
        camerVC.roomID = roomID;
        
        [self addViewAndVC:camerVC];
        
    }else if([typeName isEqualToString:@"智能门锁"]){
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.roomID = roomID;
        
        [self addViewAndVC:guardVC];
        
    }else if([typeName isEqualToString:@"幕布"]){
        ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
        screenCurtainVC.roomID = roomID;
        
        [self addViewAndVC:screenCurtainVC];
        
        
    }else if([typeName isEqualToString:@"投影"])
    {
        ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
        projectVC.roomID = roomID;
        
        [self addViewAndVC:projectVC];
    }else if([typeName isEqualToString:@"功放"]){
        AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
        amplifierVC.roomID = roomID;
        [self addViewAndVC:amplifierVC];
       
    }else if([typeName isEqualToString:@"智能推窗器"])
    {
        WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
        windowSlidVC.roomID = roomID;
        [self addViewAndVC:windowSlidVC];
    }else if([typeName isEqualToString:@"背景音乐"]){
        BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
        bgMusicVC.roomID = roomID;
        [self addViewAndVC:bgMusicVC];
        
    }else {
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
        pluginVC.roomID = roomID;
        
        [self addViewAndVC:pluginVC];
    }
    
}
-(void )addViewAndVC:(UIViewController *)vc
{
    if (self.currentViewController != nil) {
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
    }
    
    vc.view.frame = CGRectMake(0, 0, self.detailView.bounds.size.width, self.detailView.bounds.size.height);
    [self.detailView addSubview:vc.view];
    [self addChildViewController:vc];
    self.currentViewController = vc;
}

-(void)selectedRoom:(UIButton *)btn
{
    self.selectedRoomBtn.selected = NO;
    btn.selected = YES;
    self.selectedRoomBtn = btn;
    [self.selectedRoomBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    self.deviceTypes = [SQLManager deviceSubTypeByRoomId:btn.tag]
    ;
    
    [self setUpScrollerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
