//
//  IBeaconController.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "public.h"
#import "Light.h"
#import "AsyncUdpSocket.h"

@interface IBeaconController : UIViewController

@property (strong, nonatomic) IBeacon *beacon;
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;

@end
