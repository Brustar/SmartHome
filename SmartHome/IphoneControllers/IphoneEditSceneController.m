//
//  IphoneEditSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneEditSceneController.h"
#import "IphoneRoomView.h"
#import "SQLManager.h"


@interface IphoneEditSceneController ()<IphoneRoomViewDelegate>
@property (weak, nonatomic) IBOutlet IphoneRoomView *subTypeView;
@property (weak, nonatomic) IBOutlet IphoneRoomView *deviceTypeView;
@property (weak, nonatomic) IBOutlet UIView *detailView;

//设备大类
@property (nonatomic,strong) NSArray *typeArr;
//设备子类
@property(nonatomic,strong) NSArray *devicesTypes;

@property (nonatomic, assign) int typeIndex;
@end

@implementation IphoneEditSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.typeArr = [SQLManager getSubTydpeBySceneID:self.sceneID];
    
    self.devicesTypes = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[0]];
    [self setupSubTypeView];
    
}

-(void)setupSubTypeView
{
    self.subTypeView.dataArray = self.typeArr;
    self.subTypeView.delegate = self;
    [self.subTypeView setSelectButton:0];
    
}
-(void)setupdDeviceTypeView
{
    self.deviceTypeView.dataArray = self.devicesTypes;
    self.deviceTypeView.delegate = self;
    
}
-(void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    if(view == self.subTypeView)
    {
        self.typeIndex = index;
        self.devicesTypes = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[index]];
        [self setupdDeviceTypeView];
    }else{
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}



@end
