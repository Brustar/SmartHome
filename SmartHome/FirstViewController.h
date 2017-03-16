//
//  FirstViewController.h
//  
//
//  Created by zhaona on 2017/3/17.
//
//

#define BLUETOOTH_MUSIC false

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController
@property (nonatomic, assign) NSInteger playState;//播放状态： 0:停止 1:播放
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;

@end
