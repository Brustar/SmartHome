//
//  CKCircleView.m
//  CKCircleWidget
//
//  Created by Aileen Nielsen on 11/18/15.
//  Copyright © 2015 SunnysideProductions. All rights reserved.
//

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

#import "CKCircleView.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+Badge.h"

typedef NS_ENUM(NSInteger, DeliveryType) {
    Circle_Start = 0,//开始
    Circle_End // 结束
};

@interface CKCircleView () <UIGestureRecognizerDelegate>
@property CGPoint trueCenter;
@property UILabel *numberLabel;
@property int currentNum;
@property double angle;
//开始拨号键
@property (nonatomic,strong) UIImageView *circle;
//结束拨号键
@property (nonatomic,strong) UIImageView *circle2;
@property (nonatomic,assign) int    Circle_type;//拨动的是开始按钮，还是结束按钮.
@property (nonatomic,assign)double circle_angle;
@property (nonatomic,assign)double circle_angle2;
@end

@implementation CKCircleView

# pragma mark view appearance setup

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        // overall view settings
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        // setting default values
        self.minNum = 0;
        self.maxNum = 100;
        self.currentNum = self.minNum;
        self.units = @"";
        
        // determine true center of view for calculating angle and setting up arcs
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        self.trueCenter = CGPointMake(width/2, height/2);
        
        // radii settings
        self.dialRadius = 20;//改变图标的大小
        self.arcRadius = 50;
        self.outerRadius = MIN(width, height)/2;
        self.arcThickness = 20.0;
        CGRect  rect = CGRectMake((width - self.dialRadius*2)/2, height*.25, self.dialRadius*2, self.dialRadius*2);
        self.circle = [[UIImageView alloc] initWithFrame:rect];
        self.circle.image = [UIImage imageNamed:@"schedule_pointer"];
        self.circle.userInteractionEnabled = YES;
        
        [self addSubview: self.circle2];
        [self addSubview: self.circle];
        // number label tracks progress around the circle
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, height/2 - width/6, width*.8, width/3)];
        self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
        self.numberLabel.center = self.trueCenter;
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.labelFont =[ UIFont fontWithName:@"Arial" size:10.0];
        self.numberLabel.font = self.labelFont;
        [self addSubview:self.numberLabel];
        
        // pan gesture detects circle dragging
        UIPanGestureRecognizer *pv = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        UIPanGestureRecognizer *pv2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
//        [self addGestureRecognizer:pv];
        [self.circle addGestureRecognizer:pv];
        [self.circle2 addGestureRecognizer:pv2];
        
        self.Circle_type = Circle_Start;
        self.arcColor = [UIColor redColor];
        self.backColor = [UIColor yellowColor];
        self.dialColor = [UIColor blueColor];
        self.dialColor2 = [UIColor lightGrayColor];
        self.labelColor = [UIColor blackColor];

    }
    
    return self;
}

- (void) drawRect:(CGRect)rect {
    UIColor *color = self.arcColor;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
//    UIBezierPath *path = [self createArcPathWithAngle:self.angle atPoint:self.trueCenter withRadius:self.arcRadius];
    UIBezierPath *path = [self createArcPathWithStartAngle:self.circle_angle2 endAngle:self.circle_angle atPoint:self.trueCenter withRadius:self.arcRadius];
    path.lineWidth = self.arcThickness;
//    NSLog(@"self.angle:%f",self.angle);
    if(self.angle > 1){
      [path stroke];
    }
    
}

- (void) willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    
    self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
    
    // background circle
    self.layer.cornerRadius = self.outerRadius;
    self.backgroundColor = self.backColor;
    
    // dial
    self.circle.frame =  CGRectMake((self.frame.size.width - self.dialRadius*2)/2, self.frame.size.height*.25, self.dialRadius, self.dialRadius*2);
    self.circle.layer.cornerRadius = self.dialRadius;
    self.circle.backgroundColor = self.dialColor;
    
    // dial2
//    self.circle2.frame =  self.circle.frame;
    self.circle2.layer.cornerRadius = self.dialRadius;
    self.circle2.backgroundColor = self.dialColor2;
    
    // label
    self.numberLabel.font = self.labelFont;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
    self.numberLabel.textColor = self.labelColor;
    self.numberLabel.hidden = YES;
    
    [self moveCircleToAngle:0];
    [self setNeedsDisplay];
    
}

# pragma mark move circle in response to pan gesture
- (void) moveCircleToAngle: (double)angle{
    NSLog(@"---%f",angle);
    self.angle = self.circle_angle - self.circle_angle2;
    [self setNeedsDisplay];
 
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGPoint newCenter = CGPointMake(width/2, height/2);

    newCenter.y += self.arcRadius * sin(M_PI/180 * (angle - 90));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (angle - 90));
    if (self.Circle_type == Circle_Start) {
        self.circle.center = newCenter;//第一个拨号键的中心点
        [self.circle sliderRotate:angle];
    }else{
        //第二个拨号键的中心点
        self.circle2.center = newCenter;
        [self.circle2 sliderRotate:angle];
    }
    self.currentNum = self.minNum + (self.maxNum - self.minNum)*(self.angle/360.0);
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
}
- (UIBezierPath *)createArcPathWithStartAngle:(double)starAngle
                                     endAngle:(double)endAngle
                                      atPoint: (CGPoint) point withRadius: (float) radius
{
    float mystartAngle = (float)(((int)starAngle + 270 + 1)%360);
    float myendAngle = (float)(((int)endAngle + 270 + 1)%360);
    
    int startNum = self.minNum + (self.maxNum - self.minNum)*(self.angle/360.0);
    int endNum = self.minNum + (self.maxNum - self.minNum)*(self.circle_angle2/360.0);
//    NSLog(@"startNum :%d",startNum);
//    NSLog(@"endNum :%d",endNum);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(startTextChange:)]) {
            [self.delegate startTextChange:[NSString stringWithFormat:@"%d:00",startNum]];
        }
        if ([self.delegate respondsToSelector:@selector(endTextChange:)]) {
            [self.delegate endTextChange:[NSString stringWithFormat:@"%d:00",endNum]];
        }
    }
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:point
                                                         radius:radius
                                                     startAngle:DEGREES_TO_RADIANS(mystartAngle)
                                                       endAngle:DEGREES_TO_RADIANS(myendAngle)
                                                      clockwise:YES];
    return aPath;
}
# pragma mark detect pan and determine angle of pan location vs. center of circular revolution

- (void) handlePan:(UIPanGestureRecognizer *)pv {
    self.Circle_type = Circle_Start;
    
    CGPoint translation = [pv locationInView:self];
    CGFloat x_displace = translation.x - self.trueCenter.x;
    CGFloat y_displace = -1.0*(translation.y - self.trueCenter.y);
    double radius = pow(x_displace, 2) + pow(y_displace, 2);
    radius = pow(radius, .5);
    double angle = 180/M_PI*asin(x_displace/radius);
    
    if (x_displace > 0 && y_displace < 0){
        angle = 180 - angle;
    }
    else if (x_displace < 0){
        if(y_displace > 0){
            angle = 360.0 + angle;
        }
        else if(y_displace <= 0){
            angle = 180 + -1.0*angle;
        }
    }
//    angle = angle - self.circle_angle2;
    self.circle_angle = angle;
//    NSLog(@"self.circle_angle:%f",self.circle_angle);
    [self moveCircleToAngle:angle];
}
- (void) handlePan2:(UIPanGestureRecognizer *)pv {
    self.Circle_type = Circle_End;
    
    CGPoint translation = [pv locationInView:self];
    CGFloat x_displace = translation.x - self.trueCenter.x;
    CGFloat y_displace = -1.0*(translation.y - self.trueCenter.y);
    double radius = pow(x_displace, 2) + pow(y_displace, 2);
    radius = pow(radius, .5);
    double angle = 180/M_PI*asin(x_displace/radius);
    
    if (x_displace > 0 && y_displace < 0){
        angle = 180 - angle;
    }
    else if (x_displace < 0){
        if(y_displace > 0){
            angle = 360.0 + angle;
        }
        else if(y_displace <= 0){
            angle = 180 + -1.0*angle;
        }
    }
//    angle = self.circle_angle - angle;
    self.circle_angle2 = angle;
    [self moveCircleToAngle:angle];
}

#pragma mark -- lazy load
-(UIImageView *)circle2{
    if (!_circle2) {
        CGFloat width = self.frame.size.width;
//        CGFloat height = self.frame.size.height;//(height - self.dialRadius*2)
         CGRect  rect = CGRectMake((width - self.dialRadius*2)/2, 10, self.dialRadius, self.dialRadius*2);
        _circle2 = [[UIImageView alloc] init];
//        _circle2.backgroundColor = [UIColor redColor];
        _circle2.image = [UIImage imageNamed:@"schedule_pointer"];
        _circle2.frame = rect;
         _circle2.userInteractionEnabled = YES;
    }
    return _circle2;
}
@end
