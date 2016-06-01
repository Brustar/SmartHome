//
//  TouchImage.h
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define REAL_IMAGE 1
#define PLANE_IMAGE 2

@interface TouchImage : UIImageView

@property (nonatomic) int viewFrom;

@property (nonatomic) int count;

@property (strong,nonatomic) id delegate;

@end
