//
//  TouchImage.m
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TouchImage.h"

#import "planeScene.h"
#import "SQLManager.h"


@interface TouchImage()
@property (nonatomic,assign) int deviceID;
@end
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
            self.deviceID = [rect[@"deviceID"] intValue];
             NSString *typeName = [SQLManager deviceTypeNameByDeviceID:self.deviceID];
            NSString *segue;
            if([typeName isEqualToString:@"灯光"]){
                segue = @"plane_Light";
            }else if([typeName isEqualToString:@"窗帘"]){
                segue = @"pane_Curtain";
            }else if([typeName isEqualToString:@"网络电视"]){
                segue = @"plane_TV";
            }else if([typeName isEqualToString:@"空调"]){
                segue = @"plane_Air";
            }else if([typeName isEqualToString:@"DVD"]){
                segue = @"DVD";
            }else if([typeName isEqualToString:@"FM"]){
                segue = @"plane_FM";
            }else if([typeName isEqualToString:@"摄像头"]){
                segue = @"plane_Camera";
            }else if([typeName isEqualToString:@"智能插座"]) {
                segue = @"plane_Plugin";
            }
            else if([typeName isEqualToString:@"机顶盒"])
            {
                segue = @"plane_NetTv";
                
            }else if([typeName isEqualToString:@"DVD"]){
                segue = @"plane_DVD";
                
            }else if([typeName isEqualToString:@"功放"]){
                segue = @"pane_amplifer";
               
            }else{
                segue = @"plane_Guard";

            }

            [self.delegate performSegueWithIdentifier:segue sender:self.delegate];

        }
    }
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    [theSegue setValue:[NSNumber numberWithInt:self.deviceID] forKey:@"deviceid"];
    
}
@end
