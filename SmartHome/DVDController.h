//
//  DVDController.h
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "public.h"

@interface DVDController : UIViewController

@property (nonatomic,weak) NSString *sceneid;

@property (strong, nonatomic) IBeacon *beacon;

@end
