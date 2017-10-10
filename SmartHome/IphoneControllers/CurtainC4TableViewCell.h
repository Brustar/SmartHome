//
//  CurtainC4TableViewCell.h
//  SmartHome
//
//  Created by KobeBryant on 2017/9/29.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketManager.h"

@interface CurtainC4TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak,nonatomic) NSString *deviceid;
- (IBAction)closeBtnClicked:(id)sender;
- (IBAction)stopBtnClicked:(id)sender;
- (IBAction)openBtnClicked:(id)sender;

@end
