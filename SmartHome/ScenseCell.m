//
//  ScenseCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ScenseCell.h"

@interface ScenseCell ()
@property(nonatomic,strong)UILongPressGestureRecognizer *lpgr;

@end
@implementation ScenseCell
-(void)useLongPressGestureRecognizer
{
    self.lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.lpgr.minimumPressDuration = 1.0; //seconds	设置响应时间
    self.lpgr.delegate = self;
    [self addGestureRecognizer:self.lpgr];
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)lgr
{
   
    self.deleteBtn.hidden = NO;
}

-(void)unUserLongPressGestureRecognizer
{
    if(self.lpgr != nil)
        [self.lpgr removeTarget:self action:@selector(handleLongPressGesture:)];
}

-(void)dealloc
{
    [self unUserLongPressGestureRecognizer];
}

- (IBAction)doDeleteAction:(id)sender {
    [self.delegate delteSceneAction:self];
}



@end
