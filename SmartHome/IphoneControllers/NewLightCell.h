//
//  NewLightCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/20.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewLightCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *NewLightNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *NewLightPowerBtn;
@property (weak, nonatomic) IBOutlet UISlider *NewLightSlider;
@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) NSInteger roomID;
@property (strong, nonatomic) Scene *scene;
//@property (nonatomic,assign) NSInteger sceneID;
@property (weak, nonatomic) IBOutlet UIButton *AddLightBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LightConstraint;


@end
