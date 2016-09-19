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

@interface IphoneDeviceListController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;
@property (nonatomic,strong) NSArray *deviceSubTypes;
@property (nonatomic,strong) NSArray *deviceTypes;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIScrollView *roomScrollView;
@property (nonatomic,strong) UIButton *subTypeSelectedBtn;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *rooms;
@end

@implementation IphoneDeviceListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rooms = [RoomManager getAllRoomsInfo];
    
    [self setUpRoomScrollerView];
    [self setUpScrollerView];
    
}
-(void)setUpSegment
{
    self.deviceTypes = [DeviceManager getDeviceTypeName:(int)self.selectedRoomBtn.tag subTypeName:self.deviceSubTypes[self.subTypeSelectedBtn.tag]];
    if(self.deviceTypes == nil)
    {
        return;
    }
    [self.typeSegment removeAllSegments];
    for(int i = 0; i < self.deviceTypes.count; i++)
    {
        [self.typeSegment insertSegmentWithTitle:self.deviceTypes[i] atIndex:i animated:NO];
        
    }
    self.typeSegment.selectedSegmentIndex = 0;
}

-(void)setUpScrollerView
{
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    CGFloat widthBtn;
    if(self.deviceSubTypes.count > 4)
    {
        widthBtn = self.scrollView.frame.size.width / 4.0;
    }else{
        widthBtn = self.scrollView.frame.size.width / self.deviceSubTypes.count;
    }
    for(int i = 0; i < self.deviceSubTypes.count; i++)
    {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(widthBtn * i, 0, widthBtn, self.scrollView.bounds.size.height)];
        [button setTitle:self.deviceSubTypes[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectedSubType:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        if(i == 0)
        {
            button.selected = YES;
            [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            self.subTypeSelectedBtn = button;
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
        }
        [self.roomScrollView addSubview:button];
    }
    
    self.roomScrollView.contentSize = CGSizeMake(widthBtn * self.rooms.count, self.roomScrollView.bounds.size.height);
}


-(void)selectedSubType:(UIButton *)btn
{
    self.subTypeSelectedBtn.selected = NO;
    btn.selected = YES;
    self.subTypeSelectedBtn = btn;
    [self.subTypeSelectedBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self setUpSegment];
    
}
-(void)selectedRoom:(UIButton *)btn
{
    self.selectedRoomBtn.selected = NO;
    btn.selected = YES;
    self.selectedRoomBtn = btn;
    [self.selectedRoomBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    self.deviceSubTypes = [DeviceManager getSubTypeNameByRoomID:(int)self.selectedRoomBtn.tag];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   }


@end
