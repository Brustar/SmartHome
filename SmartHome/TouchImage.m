//
//  TouchImage.m
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TouchImage.h"
#import "planeScene.h"

@implementation TouchImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    int x = point.x;
    int y = point.y;
    NSLog(@"touch (x, y) is (%d, %d)", x, y);
    if (self.viewFrom==REAL_IMAGE) {
        [self realHandle:point];
    }
    
    if (self.viewFrom==PLANE_IMAGE) {
        [self planeHandle:point];
    }
    
}

-(void) realHandle:(CGPoint)point
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"realScene" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *rectstr=dic[@"rects"][0][@"rect"];
    CGRect rect=CGRectFromString(rectstr);
    NSArray *imgs=[NSArray arrayWithObjects:@"real",dic[@"rects"][0][@"image"], nil];
    if (CGRectContainsPoint(rect,point)) {
        _count++;
        self.image=[UIImage imageNamed:imgs[_count%2]];
    }
}

-(void) planeHandle:(CGPoint)point
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"planeScene" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    for (NSDictionary *rect in dic[@"rects"]) {
        NSString *rectstr=rect[@"rect"];
        CGRect rt=CGRectFromString(rectstr);
        if (CGRectContainsPoint(rt,point)) {
            ((planeScene *)self.delegate).deviceID=[rect[@"deviceID"] intValue];
        }
    }
    
    [self.delegate performSegueWithIdentifier:@"" sender:self.delegate];
}

@end
