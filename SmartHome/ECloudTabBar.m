//
//  ECloudTabBar.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define bgColour [UIColor colorWithRed:248/255.0 green:248/255.0 blue:250/255.0 alpha:1]
#define ECloudTabBarItemCount  8


#import "ECloudTabBar.h"
#import "ECloudButton.h"
#import "ECloudMoreView.h"
#import "Room.h"
#import "SQLManager.h"
#import "IbeaconManager.h"

@interface ECloudTabBar () <ECloudMoreViewDelegate>
@property (nonatomic, weak) UIView *rightView;

@property (nonatomic, weak) UIView *leftView;

@property (nonatomic, weak) UIView *separatorLine;

@property (nonatomic, strong) ECloudMoreView *moreView;

@property (nonatomic,strong) NSArray *rooms;

@property (nonatomic,assign) int roomId;

@end

@implementation ECloudTabBar

- (instancetype)init
{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        DeviceInfo *device=[DeviceInfo defaultManager];
        [device addObserver:self forKeyPath:@"beacons" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
        IbeaconManager *beaconManager=[IbeaconManager defaultManager];
        [beaconManager start:device];

        [self setUpView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedType:) name: @"tabBar" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(goToMyMsg:) name:@"myMsg" object:nil];
    return self;
}
-(void)didSelectedType:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    [self selectTabBarWithType:[dic[@"type"] intValue ]subType:[dic[@"subType"] intValue]];
}
-(void)goToMyMsg:(NSNotification *)notification
{
     NSDictionary *dic = notification.userInfo;
    [self selectTabBarWithType:[dic[@"type"] intValue ]subType:[dic[@"subType"] intValue]];
}

- (ECloudMoreView *)moreView
{
    if (_moreView == nil) {
        _moreView = [[ECloudMoreView alloc] init];
        _moreView.delegate = self;
    }
    return _moreView;
}

-(void)setUpView{
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = bgColour;
    self.leftView = leftView;
    self.leftView.userInteractionEnabled = YES;
    [self addSubview:_leftView];
    [self setUpLeftView];
    
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    self.separatorLine = separatorLine;
    [self addSubview:_separatorLine];
    
    
    UIView *rightView = [[UIView alloc]init];
    rightView.backgroundColor = bgColour;
    self.rightView = rightView;;
    [self addSubview: _rightView];
    [self setUpRightView];
}

-(void)setUpLeftView
{
    self.rooms = [SQLManager getAllRoomsInfo];

    for (int i = 0; i < self.rooms.count; i++) {
        Room *room = self.rooms[i];
        ECloudButton *button = [[ECloudButton alloc] initWithTitle:room.rName  normalImage:room.imgUrl selectImage:room.imgUrl];
        
        button.highlighted = YES;
        if (3 == i) {
            self.selectButton = button;
            self.selectButton.selected = YES;
        }
        button.type = 0;
        button.subType = room.rId;
        
        [self setUpButtonParams:button];
        
        if (i == ECloudTabBarItemCount - 1 && self.rooms.count > 8) {
            ECloudButton *lastButton = [[ECloudButton alloc] initWithTitle:@"更多" normalImage:@"more" selectImage:@"more"];
            [lastButton setTitleColor:[UIColor colorWithRed:97/255.0 green:176/255.0 blue:162/255.0 alpha:1] forState:UIControlStateNormal];
            lastButton.titleLabel.font = [UIFont systemFontOfSize:16];
            
            [lastButton addTarget:self action:@selector(moreButtonOnClick) forControlEvents:UIControlEventTouchUpInside];
            
            [self.leftView addSubview:lastButton];
            
            [self.moreView addItemWith:button];
            continue;
        }
        else if (i >= ECloudTabBarItemCount){
            [self.moreView addItemWith:button];
            continue;
        }
        
        [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftView addSubview:button];
    }
}
-(void)setUpButtonParams:(UIButton *)button
{
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)moreViewDidSelectWithType:(NSInteger)type subType:(NSInteger)subType
{
    if ([self.delegate respondsToSelector:@selector(tabBarDidSelectButtonWithType:subType:)]) {
        [self.delegate tabBarDidSelectButtonWithType:type subType:subType];
    }
}

- (void)moreButtonOnClick
{
    NSLog(@"moreButtonOnClick");
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    
    self.moreView.frame = [UIScreen mainScreen].bounds;
    
    [window addSubview:self.moreView];
}


-(void)setUpRightView
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    NSArray *str,*imgs;
    if ([device.db isEqualToString:SMART_DB]) {
        str = @[@"我的家", @"实景",@"平面图",@"我的"];
        imgs = @[@"myHome", @"objectPic",@"myHome",@"my"];
    }else{
        str = @[@"我的家", @"实景",@"平面图",@"我的"];
        imgs = @[@"myHome", @"objectPic",@"myHome",@"my"];
    }
    
    for (int i = 0; i < [str count]; i++) {
        ECloudButton *button = [[ECloudButton alloc] initWithTitle:str[i] normalImage:imgs[i] selectImage:imgs[i]];
        button.type = i + 1;
        
        
        [self setUpButtonParams:button];
        [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightView addSubview:button];
    }
    
}
- (void)buttonOnClick:(ECloudButton *)button
{
    if ([self.delegate respondsToSelector:@selector(tabBarDidSelectButtonWithType:subType:)]) {
        [self.delegate tabBarDidSelectButtonWithType:button.type subType:button.subType];
    }
    button.selected = YES;
    self.selectButton.selected = NO;
    self.selectButton = button;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = self.frame.size.height;
    CGFloat viewWidth = self.frame.size.width  - 300 - 2;
    CGFloat y = 0;
    
    CGFloat leftX = 0;
    self.leftView.frame = CGRectMake(leftX, y, viewWidth, height);
    for(int i = 0; i < self.leftView.subviews.count; i++)
    {
        UIButton *button = self.leftView.subviews[i];
        CGFloat buttonW = self.leftView.frame.size.width/self.leftView.subviews.count;
        CGFloat buttonX = i *buttonW;
        button.frame = CGRectMake(buttonX, y,buttonW, height);
    }
    
    CGFloat rightX = self.frame.size.width  - 300 ;
    self.rightView.frame = CGRectMake(rightX, y, 300, height);
    for(int i = 0 ;i < self.rightView.subviews.count ; i++)
    {
        UIButton *button = self.rightView.subviews[i];
        CGFloat buttonW = self.rightView.frame.size.width / self.rightView.subviews.count;
        CGFloat buttonX = i * buttonW;
        button.frame = CGRectMake(buttonX, y, buttonW, height);
    }
    self.separatorLine.frame = CGRectMake(self.leftView.frame.size.width, y, 2, height);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"beacons"])
    {
        int position=0;
        DeviceInfo *device=[DeviceInfo defaultManager];
        NSArray *beacons=[device valueForKey:@"beacons"];
        for (CLBeacon *beacon in beacons) {
            //NSString *str;
            switch (beacon.proximity) {
                case CLProximityNear:
                    //str = @"近";
                    position=[beacon.major intValue];
                    break;
                case CLProximityImmediate:
                    //str = @"超近";
                    position=[beacon.major intValue];
                    break;
                case CLProximityFar:
                    //str = @"远";
                    break;
                case CLProximityUnknown:
                    //str = @"不见了";
                    break;
                default:
                    break;
            }
            
        }
       
        if(position>0)
        {
            self.roomId = [SQLManager getRoomIDByBeacon:position];
            for(ECloudButton *btn in self.leftView.subviews)
            {
                if(btn.subType == self.roomId)
                {
                    [self buttonOnClick:btn];
                    return;
                }
                    
            }
        }
    }
    
    
}


- (void)selectTabBarWithType:(NSInteger)type subType:(NSInteger)subType {
    ECloudButton *button = nil;
    
    if (0 == type) {
        if (self.leftView.subviews.count<subType) {
            return;
        }
        button = self.leftView.subviews[subType -1];
    } else {
        button = self.rightView.subviews[type - 1];
    }
    
    [self buttonOnClick:button];
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"beacons" context:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
