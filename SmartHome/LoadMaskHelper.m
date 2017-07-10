//
//  LoadMaskHelper.m
//
//
//  Created by KobeBryant on 17/6/23.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "LoadMaskHelper.h"
#import "SingleMaskView.h"

#import "UIView+SetRect.h"



#define MaskVersiomKey       @"MaskVersiomKey"

#define HomePageKey          @"HomePage2.3.5"          // 主页 可用资产
#define RealIncomeKey        @"RealIncome2.3.5"        // ISM完成期详情 实际收益
#define StockTimesharingKey  @"StockTimesharing2.3.5"  // 股票分时图


@implementation LoadMaskHelper

+ (void)showMaskWithType:(PageTye)pageType onView:(UIView*)view delay:(NSTimeInterval)delay delegate:(id)delegate{
       NSString *isDemo = [UD objectForKey:IsDemo];
    
    // 处理是否加载蒙版
    switch (pageType) {
            
        case HomePageChatBtn:  // 个人主页
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageChatBtn];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
            
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageChatBtn];
                [UD synchronize];
            
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
            
            }
        
        }
           
        break;
            
        case HomePageEnterChat: // 进入聊天
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageEnterChat];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageEnterChat];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }

            break;
            
            
        case HomePageEnterFamily: // 进入家庭
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageEnterFamily];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageEnterFamily];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
        case HomePageScene:  // 主页场景
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageScene];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageScene];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
        case HomePageDevice:  // 主页设备
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageDevice];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageDevice];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
        case HomePageCloud:  // 主页云
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageCloud];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageCloud];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
        case ChatView: // 聊天页面
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewChatView];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewChatView];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
        case FamilyHome: // 家庭首页
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewFamilyHome];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHome];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
        case FamilyHomeDetail: // 家庭详情页面
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewFamilyHomeDetail];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHomeDetail];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
          
            
        case SceneHome: // 场景首页
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewScene];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewScene];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
        case SceneHomeAdd: // 场景添加
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewSceneAdd];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneAdd];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
        case SceneDetail: // 场景详情
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewSceneDetail];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneDetail];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
        case DeviceHome: // 设备首页
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewDevice];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewDevice];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
        case DeviceAir: // 设备---空调
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewDeviceAir];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewDeviceAir];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
        case LeftView: // 侧滑页面
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewLeftView];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewLeftView];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
        case SettingView: // 设置页面
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewSettingView];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewSettingView];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
        case AccessControl: // 权限控制页面
        {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewAccessControl];
            if(KeyStr.length <=0 && [isDemo isEqualToString:@"YES"])
            {
                
                [UD setObject:@"haveShownMask" forKey:ShowMaskViewAccessControl];
                [UD synchronize];
                
            }else{
                
                // 测试用，让蒙版再次显示，开发完工后注释掉下面代码
                //[UD setObject:@"" forKey:ShowMaskView];
                //[UD synchronize];
                return;
                
            }
            
        }
            
            break;
            
            
            
        default:
          break;
    }

    
    
    
    
    
    /*
     以下 项目真实使用案例
     */
    
    
    
    SingleMaskView *maskView = [SingleMaskView new];
    maskView.delegate = delegate;
    maskView.pageType = pageType;
    
    // 加载蒙版
    switch (pageType) {
        
          // 主页
        case HomePageChatBtn:
        {
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask1"] withFrame:CGRectMake(view.width/2+30, UI_SCREEN_HEIGHT*0.5+20, 148, 123)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(view.width/2-40, UI_SCREEN_HEIGHT*2/3-50, 70, 70) withRadius:10];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(view.width/2-40, UI_SCREEN_HEIGHT*2/3-50, 70, 70) tag:1];//聊天按钮
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask1pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH-512/2-150, UI_SCREEN_HEIGHT/2-20, 512/2, 204/2)];
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH-142, UI_SCREEN_HEIGHT/2+17, 45, 45) withRadius:10];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH-142, UI_SCREEN_HEIGHT/2+17, 45, 45) tag:1];//聊天按钮
            }
            
        }
            break;
       
            
            
        // 进入聊天
        case HomePageEnterChat:
        {
            
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask2"] withFrame:CGRectMake(view.width/2-10, UI_SCREEN_HEIGHT-240, 188, 100)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(0, UI_SCREEN_HEIGHT-130, UI_SCREEN_WIDTH, 60) withRadius:1];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(0, UI_SCREEN_HEIGHT-130, UI_SCREEN_WIDTH, 60) tag:2];//进入聊天按钮
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask2pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-604/2, UI_SCREEN_HEIGHT/2+90, 604/2, 132/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake((UI_SCREEN_WIDTH-UI_SCREEN_WIDTH/4)/2, UI_SCREEN_HEIGHT/2+15, UI_SCREEN_WIDTH/4, 60) withRadius:1];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-UI_SCREEN_WIDTH/4)/2, UI_SCREEN_HEIGHT/2+15, UI_SCREEN_WIDTH/4, 60) tag:2];//进入聊天按钮
            }
            
        }
            break;
            
        // 进入家庭
        case HomePageEnterFamily:
        {
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask4"] withFrame:CGRectMake(10, 70, 170, 148)];
                // 添加蒙版透明区(圆)
                [maskView addTransparentOvalRect:CGRectMake(50, 130, UI_SCREEN_WIDTH*3/4, UI_SCREEN_WIDTH*3/4)];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(50, 130, UI_SCREEN_WIDTH*3/4, UI_SCREEN_WIDTH*3/4) tag:3];//大圆按钮
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask4pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-359/2-50, UI_SCREEN_HEIGHT/2-100, 359/2, 400/2)];
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake((UI_SCREEN_WIDTH-120)/2, UI_SCREEN_HEIGHT/2, 120, 180) withRadius:4];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-120)/2, UI_SCREEN_HEIGHT/2, 120, 180) tag:3];//门按钮
            }
        }
            
            break;
            
            
            // 进入场景
        case HomePageScene:
        {
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask9"] withFrame:CGRectMake(UI_SCREEN_WIDTH-170, UI_SCREEN_HEIGHT-188, 160, 118)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH-20-(UI_SCREEN_WIDTH-20*2)/3, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-20*2)/3, 50) withRadius:20];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH-20-(UI_SCREEN_WIDTH-20*2)/3, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-20*2)/3, 50) tag:4];// 场景按钮
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask13pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-676/2+70, UI_SCREEN_HEIGHT-102/2-30, 676/2, 102/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH/2+(UI_SCREEN_WIDTH-600)/3*0.5, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-600)/3, 50) withRadius:20];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/2+(UI_SCREEN_WIDTH-600)/3*0.5, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-600)/3, 50) tag:4];// 场景按钮
            }
        }
            
            break;
            
            // 进入设备
        case HomePageDevice:
        {
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask17"] withFrame:CGRectMake(30, UI_SCREEN_HEIGHT-180, 148, 108)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(20, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-20*2)/3, 50) withRadius:20];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(20, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-20*2)/3, 50) tag:5];// 设备按钮
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask19pad"] withFrame:CGRectMake(300+(UI_SCREEN_WIDTH-600)/3, UI_SCREEN_HEIGHT-102/2-30, 600/2, 102/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(300, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-600)/3, 50) withRadius:20];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(300, UI_SCREEN_HEIGHT-70, (UI_SCREEN_WIDTH-600)/3, 50) tag:5];// 设备按钮
            }
        }
            
            break;
            
            // 主页--点击云icon打开侧滑页面
        case HomePageCloud:
        {
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask23"] withFrame:CGRectMake(50, 50, 463/2, 274/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(25, 30, 30, 30) withRadius:10];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(25, 30, 30, 30) tag:6];// 云按钮
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask24pad"] withFrame:CGRectMake(50, 50, 560/2, 340/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(25, 30, 30, 30) withRadius:10];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(25, 30, 30, 30) tag:6];// 云按钮
            }
        }
            
            break;
          
            
        // 聊天页面
        case ChatView:
        {
            // 添加蒙版图片
            [maskView addImage:[UIImage imageNamed:@"mask3"] withFrame:CGRectMake(UI_SCREEN_WIDTH-270, 40, 199, 104)];
            
            // 添加蒙版透明区
            [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH-55, 26, 30, 30) withRadius:1];
            //透明按钮
            [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH-55, 26, 30, 30) tag:1];// 下拉列表按钮
        }
            break;
            
            
            // 家庭首页
        case FamilyHome:
        {
            if (ON_IPONE) {
                CGFloat width = 160;
                if (UI_SCREEN_WIDTH == 414) {
                    width = 190;
                }
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"maskFamily"] withFrame:CGRectMake(5, 70, width, width)];
                
                CGFloat ori_y = 240;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_y = 260;
                }
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask5"] withFrame:CGRectMake(30, ori_y, 99, 131)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask6"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2+40, ori_y-30, 142, 174)];
                
                CGFloat width2 = 112;
                if (UI_SCREEN_WIDTH == 414) {
                    width2 = 132;
                }
                // 添加蒙版透明区
                [maskView addTransparentOvalRect:CGRectMake(UI_SCREEN_WIDTH/2+48, 92, width2, width2)];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/2+50, 90, width2, width2) tag:1];// 表盘按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"maskFamily"] withFrame:CGRectMake(20, 310, 160, 160)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask6pad"] withFrame:CGRectMake(180, 130, 781/2, 188/2)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask5pad"] withFrame:CGRectMake(180, 130+188/2+120, 518/2, 182/2)];
                // 添加蒙版图片4
                [maskView addImage:[UIImage imageNamed:@"mask7pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-80, UI_SCREEN_HEIGHT/2+75, 698/2, 182/2)];
                // 添加蒙版图片5
                [maskView addImage:[UIImage imageNamed:@"mask8pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-186/2-90, UI_SCREEN_HEIGHT/2+130, 186/2, 35/2)];

                
                // 添加蒙版透明区
                [maskView addTransparentOvalRect:CGRectMake(45, 135, 112, 112)];
                // 透明按钮
                [maskView addTransparentBtn:CGRectMake(45, 135, 112, 112) tag:1];// 表盘按钮
            }
            
        }
            break;
            
            
            // 家庭详情
        case FamilyHomeDetail:
        {
            if (ON_IPONE) {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask8"] withFrame:CGRectMake(80, 120, 237, 68)];
                
                CGFloat ori_y = UI_SCREEN_HEIGHT/2+95;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_y = UI_SCREEN_HEIGHT/2+60;
                }
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask7"] withFrame:CGRectMake(72, ori_y, 220, 75)];
                
                
                // 添加蒙版透明区1
                [maskView addTransparentRect:CGRectMake(20, 70, UI_SCREEN_WIDTH-40, 60) withRadius:2];
                
                CGFloat ori_y2 = UI_SCREEN_HEIGHT/2+55;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_y2 = UI_SCREEN_HEIGHT/2+20;
                }
                // 添加蒙版透明区2
                [maskView addTransparentRect:CGRectMake(10, ori_y2, UI_SCREEN_WIDTH-20, 50) withRadius:0];
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(20, 70, (UI_SCREEN_WIDTH-40)/3, 60) tag:1];// 柔和按钮
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-40)/3+20, 70, (UI_SCREEN_WIDTH-40)/3, 60) tag:2];// 正常按钮
                //透明按钮3
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-40)/3*2+20, 70, (UI_SCREEN_WIDTH-40)/3, 60) tag:3];// 明亮按钮
                //透明按钮4
                [maskView addTransparentBtn:CGRectMake(10, UI_SCREEN_HEIGHT/2+55, UI_SCREEN_WIDTH-20, 50) tag:4];// 设备按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask9pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH-60, UI_SCREEN_HEIGHT/3+59, 46/1.2, 46/1.2)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask10pad"] withFrame:CGRectMake(50, 130, 636/2, 186/2)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask11pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2+80, 230, 756/2, 186/2)];
                // 添加蒙版图片4
                [maskView addImage:[UIImage imageNamed:@"mask12pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-50, UI_SCREEN_HEIGHT/2+20, 552/2, 305/2)];
                
                
                // 添加蒙版透明区1
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH/4 + 20, 70, UI_SCREEN_WIDTH*3/4-40, 60) withRadius:4];
                
                // 添加蒙版透明区2
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH/4 + 20, UI_SCREEN_HEIGHT/2-70, UI_SCREEN_WIDTH*3/4-30, 130) withRadius:0];
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/4 + 20, 70, (UI_SCREEN_WIDTH*3/4-200)/3, 60) tag:1];// 柔和按钮
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH/4 + 20 + (UI_SCREEN_WIDTH*3/4-200)/3) + 80, 70, (UI_SCREEN_WIDTH*3/4-200)/3, 60) tag:2];// 正常按钮
                //透明按钮3
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/4 + 20 + (UI_SCREEN_WIDTH*3/4-200)/3*2 + 160, 70, (UI_SCREEN_WIDTH*3/4-200)/3, 60) tag:3];// 明亮按钮
                //透明按钮4
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/4 + 20, UI_SCREEN_HEIGHT/2, UI_SCREEN_WIDTH*3/4-30, 130) tag:4];// 设备按钮
            }
        }
            break;

            
            // 场景首页
        case SceneHome:
        {
            
            if (ON_IPONE) {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask13"] withFrame:CGRectMake((UI_SCREEN_WIDTH-187)/2, 70, 187, 131)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask12"] withFrame:CGRectMake((UI_SCREEN_WIDTH-200)/2, UI_SCREEN_HEIGHT-225, 200, 38)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask10"] withFrame:CGRectMake(10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                // 添加蒙版图片4
                [maskView addImage:[UIImage imageNamed:@"mask11"] withFrame:CGRectMake(UI_SCREEN_WIDTH-93-10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(42, 130, UI_SCREEN_WIDTH-90, UI_SCREEN_HEIGHT-350) withRadius:1];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(42, 130, UI_SCREEN_WIDTH-90, UI_SCREEN_HEIGHT-350) tag:1];// 场景首页场景按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask14pad"] withFrame:CGRectMake(100, 120, 696/2, 209/2)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask15pad"] withFrame:CGRectMake((UI_SCREEN_WIDTH-462/2)/2, UI_SCREEN_HEIGHT/2-88/2/2-40, 462/2, 88/2)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask10"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-462/2/2-93-10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                // 添加蒙版图片4
                [maskView addImage:[UIImage imageNamed:@"mask11"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2+462/2/2+10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake((UI_SCREEN_WIDTH-(UI_SCREEN_WIDTH/2-50))/2, 130, UI_SCREEN_WIDTH/2-50, UI_SCREEN_WIDTH/2-120) withRadius:0];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-(UI_SCREEN_WIDTH/2-50))/2, 130, UI_SCREEN_WIDTH/2-50, UI_SCREEN_WIDTH/2-120) tag:1];// 场景首页场景按钮
            }
        }
            break;
            
            // 场景添加
        case SceneHomeAdd:
        {
            
            if (ON_IPONE) {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"maskSceneAdd"] withFrame:CGRectMake((UI_SCREEN_WIDTH-(622/2+50))/2, 130, 622/2+50, 761/2+50)];
                
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask16"] withFrame:CGRectMake((UI_SCREEN_WIDTH-336/2)/2+70, 70, 336/2, 246/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake((UI_SCREEN_WIDTH-(622/2+50))/2, 130, 622/2+50, 761/2-50) withRadius:1];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-(622/2+50))/2, 130, 622/2+50, 761/2-50) tag:2];// 场景首页场景添加按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"AddScene-ImageView"] withFrame:CGRectMake((UI_SCREEN_WIDTH-(UI_SCREEN_WIDTH/2-50))/2, 180, UI_SCREEN_WIDTH/2-50, UI_SCREEN_WIDTH/2-120)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"AddSceneBtn"] withFrame:CGRectMake((UI_SCREEN_WIDTH-96)/2, (UI_SCREEN_HEIGHT-96)/2, 96, 96)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask18pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-354/2/2, 80, 354/2, 323/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake((UI_SCREEN_WIDTH-(UI_SCREEN_WIDTH/2-50))/2, 180, UI_SCREEN_WIDTH/2-50, UI_SCREEN_WIDTH/2-120) withRadius:0];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-(UI_SCREEN_WIDTH/2-50))/2, 180, UI_SCREEN_WIDTH/2-50, UI_SCREEN_WIDTH/2-120) tag:2];// 场景首页添加场景按钮
            }
        }
            break;
            
            // 设备首页
        case  DeviceHome:
        {
            if (ON_IPONE) {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask20"] withFrame:CGRectMake((UI_SCREEN_WIDTH-170)/2, 70, 170, 131)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask19"] withFrame:CGRectMake((UI_SCREEN_WIDTH-200)/2, UI_SCREEN_HEIGHT-225, 200, 38)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask10"] withFrame:CGRectMake(10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                // 添加蒙版图片4
                [maskView addImage:[UIImage imageNamed:@"mask11"] withFrame:CGRectMake(UI_SCREEN_WIDTH-93-10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(42, 130, UI_SCREEN_WIDTH-90, UI_SCREEN_HEIGHT-350) withRadius:1];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(42, 130, UI_SCREEN_WIDTH-90, UI_SCREEN_HEIGHT-350) tag:1];// 设备首页设备按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask20pad"] withFrame:CGRectMake(100, 120, 719/2, 187/2)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask21pad"] withFrame:CGRectMake((UI_SCREEN_WIDTH-462/2)/2, UI_SCREEN_HEIGHT/2-88/2/2-40, 462/2, 88/2)];
                // 添加蒙版图片3
                [maskView addImage:[UIImage imageNamed:@"mask10"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-462/2/2-93-10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                // 添加蒙版图片4
                [maskView addImage:[UIImage imageNamed:@"mask11"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2+462/2/2+10, UI_SCREEN_HEIGHT/2-50, 93, 14)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake((UI_SCREEN_WIDTH-(UI_SCREEN_WIDTH/2-50))/2, 130, UI_SCREEN_WIDTH/2-50, UI_SCREEN_WIDTH/2-120) withRadius:0];
                //透明按钮
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-(UI_SCREEN_WIDTH/2-50))/2, 130, UI_SCREEN_WIDTH/2-50, UI_SCREEN_WIDTH/2-120) tag:1];// 设备首页按钮
            }
        }
            break;
            
            
            // 场景详情
        case SceneDetail:
        {
            if (ON_IPONE) {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask15"] withFrame:CGRectMake(80, 120, 237, 68)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask14"] withFrame:CGRectMake(72, UI_SCREEN_HEIGHT/2-40, 229, 95)];
                
                
                // 添加蒙版透明区1
                [maskView addTransparentRect:CGRectMake(10, 70, UI_SCREEN_WIDTH-20, 60) withRadius:2];
                
                // 添加蒙版透明区2
                [maskView addTransparentRect:CGRectMake(10, UI_SCREEN_HEIGHT/2, UI_SCREEN_WIDTH-20, 100) withRadius:0];
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(10, 70, (UI_SCREEN_WIDTH-20)/3, 60) tag:1];// 柔和按钮
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-20)/3+10, 70, (UI_SCREEN_WIDTH-20)/3, 60) tag:2];// 正常按钮
                //透明按钮3
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-20)/3*2+10, 70, (UI_SCREEN_WIDTH-20)/3, 60) tag:3];// 明亮按钮
                //透明按钮4
                [maskView addTransparentBtn:CGRectMake(10, UI_SCREEN_HEIGHT/2, UI_SCREEN_WIDTH-20, 100) tag:4];// 设备按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask16pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/4, 100, 673/2, 171/2)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask17pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/4+20, UI_SCREEN_HEIGHT/2-130, 705/2, 123/2)];
                
                
                // 添加蒙版透明区1
                [maskView addTransparentRect:CGRectMake(0, 125, UI_SCREEN_WIDTH/4, 67) withRadius:2];
                
                // 添加蒙版透明区2
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH/4+20, UI_SCREEN_HEIGHT/2-200, UI_SCREEN_WIDTH*3/4-40, 100) withRadius:0];
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(0, 125, UI_SCREEN_WIDTH/4, 65) tag:1];//菜单按钮
                
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/4+20, UI_SCREEN_HEIGHT/2-150, UI_SCREEN_WIDTH*3/4-40, 100) tag:2];// 设备按钮
            }
        }
            break;
            
        case DeviceAir:
        {
            if (ON_IPONE) {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask22"] withFrame:CGRectMake((UI_SCREEN_WIDTH-537/2)/2, 110, 537/2, 131/2)];
                
                CGFloat ori_x = 30;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_x = 60;
                }
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask21"] withFrame:CGRectMake(ori_x, UI_SCREEN_HEIGHT/2+30, 325/2, 356/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(0, 64, UI_SCREEN_WIDTH/4, 50) withRadius:2];
                
                CGFloat ori_y = UI_SCREEN_HEIGHT/2-90;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_y = UI_SCREEN_HEIGHT/2-120;
                }
                // 添加蒙版圆透明区
                [maskView addTransparentOvalRect:CGRectMake((UI_SCREEN_WIDTH-230)/2, ori_y, 230, 230)];
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(0, 64, UI_SCREEN_WIDTH/4, 50) tag:1];// 制冷按钮
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-230)/2, UI_SCREEN_HEIGHT/2-90, 230, 230) tag:2];// 圆按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask22pad"] withFrame:CGRectMake(100, 140, 670/2, 187/2)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask23pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2-90, UI_SCREEN_HEIGHT/2+30, 691/2, 233/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH/4-20, 100, UI_SCREEN_WIDTH/2+40, 50) withRadius:2];
                // 添加蒙版圆透明区
                [maskView addTransparentOvalRect:CGRectMake((UI_SCREEN_WIDTH-230)/2, UI_SCREEN_HEIGHT/2-130, 230, 230)];
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/4, 100, UI_SCREEN_WIDTH/2, 50) tag:1];// 制冷按钮
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake((UI_SCREEN_WIDTH-230)/2, UI_SCREEN_HEIGHT/2-130, 230, 230) tag:2];// 圆按钮
            }
            
        }
            break;
            
        case LeftView:
        {
            if (ON_IPONE) {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask25"] withFrame:CGRectMake(UI_SCREEN_WIDTH/2, 70, 238/2, 131/2)];
                
                CGFloat ori_y2 = UI_SCREEN_HEIGHT-60-243/2;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_y2 = UI_SCREEN_HEIGHT-130-243/2;
                }
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask24"] withFrame:CGRectMake(30, ori_y2, 289/2, 243/2)];
                
                
                CGFloat ori_x = 90;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_x = 110;
                }
                // 添加蒙版圆透明区
                [maskView addTransparentOvalRect:CGRectMake(ori_x, 60, 100, 100)];//头像
                
                CGFloat ori_y = UI_SCREEN_HEIGHT-55;
                if (UI_SCREEN_WIDTH == 414) {
                    ori_y = UI_SCREEN_HEIGHT-125;
                }
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(40, ori_y, 50, 20) withRadius:2];//设置
                
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(ori_x, 60, 100, 100) tag:1];// 头像按钮
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake(40, ori_y, 50, 20) tag:2];// 设置按钮
            }else {
                // 添加蒙版图片1
                [maskView addImage:[UIImage imageNamed:@"mask25pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH/4-70, 70, 312/2, 181/2)];
                // 添加蒙版图片2
                [maskView addImage:[UIImage imageNamed:@"mask26pad"] withFrame:CGRectMake(30, UI_SCREEN_HEIGHT-160-335/2, 327/2, 335/2)];
                
                
                // 添加蒙版圆透明区
                [maskView addTransparentOvalRect:CGRectMake(80, 60, 100, 100)];//头像
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(40, UI_SCREEN_HEIGHT-155, 50, 20) withRadius:2];//设置
                
                
                //透明按钮1
                [maskView addTransparentBtn:CGRectMake(90, 60, 100, 100) tag:1];// 头像按钮
                //透明按钮2
                [maskView addTransparentBtn:CGRectMake(40, UI_SCREEN_HEIGHT-160, 50, 20) tag:2];// 设置按钮
            }
        }
            break;
            
        case SettingView:
        {
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask26"] withFrame:CGRectMake(UI_SCREEN_WIDTH-464/2-10, 236, 464/2, 217/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(0, 208, UI_SCREEN_WIDTH, 44) withRadius:1];
                
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(0, 208, UI_SCREEN_WIDTH, 44) tag:1];
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask27pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH-617/2-30, 200, 617/2, 276/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH/4+10, 165, UI_SCREEN_WIDTH*3/4, 44) withRadius:1];
                
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/4+10, 165, UI_SCREEN_WIDTH*3/4, 44) tag:1];
            }
            
        }
            break;
            
            
        case AccessControl:
        {
            if (ON_IPONE) {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask27"] withFrame:CGRectMake(UI_SCREEN_WIDTH-454/2-10, 216, 454/2, 165/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(0, 172, UI_SCREEN_WIDTH, 54) withRadius:1];
                
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(0, 172, UI_SCREEN_WIDTH, 54) tag:1];
            }else {
                // 添加蒙版图片
                [maskView addImage:[UIImage imageNamed:@"mask28pad"] withFrame:CGRectMake(UI_SCREEN_WIDTH-619/2-80, 110, 619/2, 237/2)];
                
                // 添加蒙版透明区
                [maskView addTransparentRect:CGRectMake(UI_SCREEN_WIDTH/4+10, 200, UI_SCREEN_WIDTH*3/4, 50) withRadius:1];
                
                //透明按钮
                [maskView addTransparentBtn:CGRectMake(UI_SCREEN_WIDTH/4+10, 200, UI_SCREEN_WIDTH*3/4, 50) tag:1];
            }
        }
            break;
            
            
        default:
            break;
    }
    
    
    // GCD 延时，非阻塞主线程 延时时间：delay
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        [maskView showMaskViewInView:view];
        
    });
        
    
   
    
   


}


// 由于每一版app蒙版不一样，新版app自己删除旧版app蒙版代码，即可不用下面的方法
+ (void)checkAPPVersion{

    
    /*
     
     
    // 启动时候检测，版本升级   (在app delegate 调用此类的方法);
     
    NSString *KeyStr = [[NSUserDefaults standardUserDefaults] objectForKey:MaskVersiomKey];
    if (KeyStr.length <=0) {
        
        // 头一次安装
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        [[NSUserDefaults standardUserDefaults] setObject:appVersion forKey:MaskVersiomKey];
        
        return;
    }else{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
        if ([KeyStr isEqualToString:appVersion])
        {
            return;
            
        }else{
            // 版本升级的情况
            [[NSUserDefaults standardUserDefaults] setObject:appVersion forKey:MaskVersiomKey];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:HomePageKey];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:VtSIAIKey];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:VtISMKey];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:VtSIAIKeyListKey];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:VtISMKeyListKey];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SIAIInstructionKey];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ISMInstructionKey];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:StockCurveKey];
            
        }
        
    }
    
     
     
     */


}
@end
