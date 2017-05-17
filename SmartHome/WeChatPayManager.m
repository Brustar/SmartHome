//
//  WeChatPayManager.m
//  SmartHome
//
//  Created by KobeBryant on 2017/3/31.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "WeChatPayManager.h"
#import "CommonUtil.h"
#import "MBProgressHUD+NJ.h"

/**
 *  微信支付商户号
 */
NSString * const WXPartnerId = @"1445985002";

NSString * const WXAppId = @"wxc5cab7f2a6ed90b3";

NSString * const package = @"Sign=WXPay";

/** API密钥 去微信商户平台设置--->账户设置--->API安全， 参与签名使用 */
NSString * const WXAPIKey = @"e2a0b1c7dCloudSmartHome1z2y3x4qq";

@implementation WeChatPayManager

+ (instancetype)sharedInstance {
    static WeChatPayManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)doPayWithPrepayId:(NSString *)prepayId {
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = WXPartnerId;
    request.prepayId= prepayId;
    request.package = package;
    request.nonceStr= [self genNonceStr];// 随机数串
    NSString *timeStamp = [self genTimeStamp];
    request.timeStamp= [timeStamp intValue];
    
    
    // 这里要注意key里的值一定要填对， 微信官方给的参数名是错误的，不是第二个字母大写
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject: WXAppId               forKey:@"appid"];
    [signParams setObject: WXPartnerId           forKey:@"partnerid"];
    [signParams setObject: request.nonceStr      forKey:@"noncestr"];
    [signParams setObject: request.package       forKey:@"package"];
    [signParams setObject: timeStamp             forKey:@"timestamp"];
    [signParams setObject: request.prepayId      forKey:@"prepayid"];
    
    //生成签名
    NSString *sign = [self genSign:signParams];
    request.sign= sign;
    [WXApi sendReq:request];
}

#pragma mark - 签名
/** 签名 */
- (NSString *)genSign:(NSDictionary *)signParams
{
    // 排序, 因为微信规定 ---> 参数名ASCII码从小到大排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //生成 ---> 微信规定的签名格式
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [sign appendString:key];
        [sign appendString:@"="];
        [sign appendString:[signParams objectForKey:key]];
        [sign appendString:@"&"];
    }
    NSString *signString = [[sign copy] substringWithRange:NSMakeRange(0, sign.length - 1)];
    
    // 拼接API密钥
    NSString *result = [NSString stringWithFormat:@"%@&key=%@", signString, WXAPIKey];
    // 打印检查
    NSLog(@"result = %@", result);
    // md5加密
    NSString *signMD5 = [CommonUtil md5:result];
    // 微信规定签名英文大写
    signMD5 = signMD5.uppercaseString;
    // 打印检查
    NSLog(@"signMD5 = %@", signMD5);
    return signMD5;
}

#pragma mark - 生成各种参数

- (NSString *)genTimeStamp
{
    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
}

/**
 * 注意：商户系统内部的订单号,32个字符内、可包含字母,确保在商户系统唯一
 */
- (NSString *)genNonceStr
{
   return [CommonUtil md5:[NSString stringWithFormat:@"%d", arc4random() % 10000]];
}

#pragma mark - 支付结果回调
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                //发通知,调用查询API返回的结果再提示成功
                [NC postNotificationName:@"WeChatPaySuccess" object:nil];
                NSLog(@"支付成功");
                break;
            default:
                [NC postNotificationName:@"WeChatPayFailed" object:nil];
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}

#pragma mark - WeXinPay Request
- (void)weixinPayWithOrderID:(NSInteger)orderID {
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    NSString *url = [NSString stringWithFormat:@"%@/WxPay/weixin_pay.aspx", [IOManager httpAddr]];
    
    if (authorToken.length >0) {
        NSDictionary *dict = @{@"token":authorToken,
                               @"trade_type":@"APP",
                               @"id":@(orderID)
                               };
        
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

#pragma  mark -  Http Delegate
-(void)httpHandler:(id)responseObject tag:(int)tag {
    if (tag == 1) {
        if ([responseObject[@"result"] intValue] == 0)
        {
            NSString *prepayId = responseObject[@"prepay_id"];
            
            if (prepayId.length >0) {
                //调用微信支付
                [[WeChatPayManager sharedInstance] doPayWithPrepayId:prepayId];
            }else {
                [MBProgressHUD showError:@"支付失败"];
            }
            
        }else {
            NSLog(@"HTTP ERROR: %@", responseObject[@"msg"]);
        }
    }
}

@end
