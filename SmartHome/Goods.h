//
//  Goods.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/30.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Goods : NSObject

@property(nonatomic, assign) NSInteger goods_id;//商品ID
@property(nonatomic, strong) NSString *goods_url;//url
@property(nonatomic, assign) NSInteger isVip;//是否是VIP商品
@property(nonatomic, strong) NSString *trade_type;//
@property(nonatomic, strong) NSString *notify_url;//
@property(nonatomic, strong) NSString *goods_tag;//
@property(nonatomic, assign) NSInteger total_fee;//商品价格
@property(nonatomic, strong) NSString *fee_type;//价格类型
@property(nonatomic, strong) NSString *attach;//附件
@property(nonatomic, strong) NSString *detail;//商品详情
@property(nonatomic, strong) NSString *body;//
@property(nonatomic, strong) NSString *goods_name;//商品名称

@end
