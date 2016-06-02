//
//  CurtainController.h
//  SmartHome
//
//  Created by Brustar on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneManager.h"
#import "Curtain.h"
#import "CurtainTableViewCell.h"
@interface CurtainController : UIViewController

@property (strong, nonatomic) IBOutlet UISlider *openvalue;
@property (strong, nonatomic) IBOutlet CurtainTableViewCell *cell;
@end
