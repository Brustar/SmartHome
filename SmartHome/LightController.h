//
//  Light.h
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRSampleColorPickerViewController.h"
#import "public.h"
#import "SceneManager.h"
#import "Light.h"
#import "ColourTableViewCell.h"
#import "DetailTableViewCell.h"
@interface LightController : UIViewController<HRColorPickerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UISlider *bright;
@property (strong, nonatomic) IBOutlet UISwitch *power;
@property (strong, nonatomic) IBOutlet ColourTableViewCell *cell;
@property (strong, nonatomic) IBOutlet DetailTableViewCell *detailCell;
@property (strong, nonatomic) IBOutlet HRColorPickerView *colorPickerView;

@property (nonatomic,weak) NSString *sceneid;

@property (strong, nonatomic) IBOutlet UIButton *favorite;
@property (strong, nonatomic) IBOutlet UIButton *remove;

@end
