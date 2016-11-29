//
//  IphoneRealSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneRealSceneController.h"
#import "IphoneRoomListController.h"
#import "Room.h"
#import "SQLManager.h"
#import "SocketManager.h"
@interface IphoneRealSceneController ()<IphoneRoomListDelegate>
@property (strong, nonatomic) IBOutlet UIButton *titleButton;

@end

@implementation IphoneRealSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavi];
    self.realimg.image =[UIImage imageNamed:@"real.png"];
    self.realimg.userInteractionEnabled=YES;
    self.realimg.viewFrom=REAL_IMAGE;
   
    
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;

    
}

-(void)setNavi
{
    
    self.titleButton = [[UIButton alloc]init];
    self.titleButton.frame = CGRectMake(0, 0, 180, 40);
    NSArray *roomList = [SQLManager getAllRoomsInfo];
    Room *room = roomList[0];
    [self.titleButton setTitle:room.rName forState:UIControlStateNormal];

    [self.titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    
    
    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 160, 0, 0);
    
    [self.titleButton addTarget:self action:@selector(clickTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = self.titleButton;
}


-(void)clickTitleButton:(UIButton *)button
{
    [self performSegueWithIdentifier:@"roomListSegue" sender:self];
}

-(void)iphoneRoomListController:(IphoneRoomListController *)vc withRoomName:(NSString *)roomName
{
    [self.titleButton setTitle:roomName forState:UIControlStateNormal];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    IphoneRoomListController *roomVC = segue.destinationViewController;
    roomVC.delegate = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
