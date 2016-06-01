//
//  SceneList.h
//  SmartHome
//
//  Created by Brustar on 16/5/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SceneList : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *scenes;

@end
