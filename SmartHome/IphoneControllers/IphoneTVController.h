//
//  IphoneTVController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneTVController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,assign) NSString *deviceid;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic,assign) NSString *deviceNumber;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) int retChannel;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;
@end
