//
//  NetvController.h
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface NetvController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;

@end
