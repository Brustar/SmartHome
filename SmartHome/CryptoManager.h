//
//  CryptoManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "MF_Base64Additions.h"

@interface NSString (CryptoExtensions)

- (NSString *) md5;
//加密
- (NSString *)encryptWithText:(NSString *)key;
- (NSString *)decryptWithText:(NSString *)key;

@end
