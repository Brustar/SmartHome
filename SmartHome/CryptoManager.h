//
//  CryptoManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import"GTMBase64.h"

#define DES_KEY @"ecloud88"

@interface NSString (CryptoExtensions)

- (NSString *) md5;
//加密
- (NSString *)encryptWithDes:(NSString *)key;
- (NSString *)decryptWithDes:(NSString *)key;

//编码
- (NSString *)encodeBase:(NSString *)data;
//解码
- (NSString *)decodeBase:(NSString *)data;

@end
