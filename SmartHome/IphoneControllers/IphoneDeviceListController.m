//
//  IphoneDeviceListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//



#import "IphoneDeviceListController.h"
#import "DeviceManager.h"
#import "RoomManager.h"
#import "Room.h"
#import "LightController.h"
#import "CurtainController.h"
#import "TVController.h"
#import "DVDController.h"
#import "NetvController.h"
#import "FMController.h"
#import "AirController.h"
#import "PluginViewController.h"
#import "CameraController.h"
#import "GuardController.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
@interface IphoneDeviceListController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) NSArray *deviceSubTypes;
@property (nonatomic,strong) NSArray *deviceTypes;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIScrollView *roomScrollView;
@property (nonatomic,strong) UIButton *typeSelectedBtn;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *rooms;
@property (weak, nonatomic) UIViewController *currentViewController;
@end

@implementation IphoneDeviceListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rooms = [RoomManager getAllRoomsInfo];
    
    [self setUpRoomScrollerView];
    [self setUpScrollerView];
    
}


-(void)setUpScrollerView
{
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    CGFloat widthBtn;
    if(self.deviceTypes.count > 4)
    {
        widthBtn = self.scrollView.frame.size.width / 4.0;
    }else{
        widthBtn = self.scrollView.frame.size.width / self.deviceTypes.count;
    }
    for(int i = 0; i < self.deviceTypes.count; i++)
    {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(widthBtn * i, 0, widthBtn, self.scrollView.bounds.size.height)];
        [button setTitle:self.deviceTypes[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectedType:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        if(i == 0)
        {
            button.selected = YES;
            [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            self.typeSelectedBtn = button;
            [self selectedType:button];
        }
        [self.scrollView addSubview:button];
        
    }
    self.scrollView.contentSize = CGSizeMake(widthBtn * self.deviceSubTypes.count, self.scrollView.bounds.size.height);
}
-(void)setUpRoomScrollerView
{
    
    self.roomScrollView.bounces= NO;
    self.roomScrollView.showsHorizontalScrollIndicator = NO;
    self.roomScrollView.showsVerticalScrollIndicator = NO;
    self.roomScrollView.backgroundColor = [UIColor lightGrayColor];
    CGFloat widthBtn;
    if(self.rooms.count > 4)
    {
        widthBtn = self.roomScrollView.frame.size.width / 4.0;
    }else{
        widthBtn = self.roomScrollView.frame.size.width / self.rooms.count;
    }
    
    for(int i = 0 ; i < self.rooms.count; i++)
    {
        UIButton *button =  [[UIButton alloc]init];
        button.frame = CGRectMake(widthBtn * i, 0, widthBtn, self.roomScrollView.frame.size.height);
        Room *room = self.rooms[i];
        button.tag = room.rId;
        [button setTitle:room.rName forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectedRoom:) forControlEvents:UIControlEventTouchUpInside];
        if(i == 0)
        {
            button.selected = YES;
            [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            self.selectedRoomBtn = button;
            self.deviceSubTypes = [DeviceManager getSubTypeNameByRoomID:(int)self.selectedRoomBtn.tag];
            [self selectedRoom:button];
        }
        [self.roomScrollView addSubview:button];
    }
    
    self.roomScrollView.contentSize = CGSizeMake(widthBtn * self.rooms.count, self.roomScrollView.bounds.size.height);
}


-(void)selectedType:(UIButton *)btn
{
    self.typeSelectedBtn.selected = NO;
    btn.selected = YES;
    self.typeSelectedBtn = btn;
    [self.typeSelectedBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    NSString *typeName  = self.deviceTypes[btn.tag];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if([typeName isEqualToString:@"网络电视"])
    {
        TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
        tVC.roomID = (int)self.selectedRoomBtn.tag;
        
        [self addViewAndVC:tVC];
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        ligthVC.roomID = (int)self.selectedRoomBtn.tag;
       
        [self addViewAndVC:ligthVC];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
        curtainVC.roomID = (int)self.selectedRoomBtn.tag;
        
        [self addViewAndVC:curtainVC];
        
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
        DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
        dvdVC.roomID = (int)self.selectedRoomBtn.tag;
        
        [self addViewAndVC:dvdVC];
        
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
        fmVC.roomID = (int)self.selectedRoomBtn.tag;
        [self addViewAndVC:fmVC];
        
    }else if([typeName isEqualToString:@"空调"])
    {
        AirController *airVC = [storyBoard instantiateViewControllerWithIdentifier:@"AirController"];
        airVC.roomID = (int)self.selectedRoomBtn.tag;
       
    }else if([typeName isEqualToString:@"机顶盒"]){
        NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
        netVC.roomID = (int)self.selectedRoomBtn.tag;
       
        [self addViewAndVC:netVC];
        
    }else if([typeName isEqualToString:@"摄像头"]){
        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
        camerVC.roomID = (int)self.selectedRoomBtn.tag;
        
        [self addViewAndVC:camerVC];
        
    }else if([typeName isEqualToString:@"智能门锁"]){
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.roomID = (int)self.selectedRoomBtn.tag;
        
        [self addViewAndVC:guardVC];
        
    }else if([typeName isEqualToString:@"幕布"]){
        ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
        screenCurtainVC.roomID = (int)self.selectedRoomBtn.tag;
        
        [self addViewAndVC:screenCurtainVC];
        
        
    }else if([typeName isEqualToString:@"投影"])
    {
        ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
        projectVC.roomID = (int)self.selectedRoomBtn.tag;
        
        [self addViewAndVC:projectVC];
    }else{
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
        pluginVC.roomID = (int)self.selectedRoomBtn.tag;
        
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
    self.deviceTypes = [DeviceManager deviceSubTypeByRoomId:btn.tag]
    ;

    [self setUpScrollerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   }


@end
