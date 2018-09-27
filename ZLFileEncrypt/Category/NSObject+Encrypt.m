//
//  NSObject+Encrypt.m
//  ZLFileEncrypt
//  
//  Created by TanZhilong on 16/10/14.
//  Copyright © 2016年 TZL. All rights reserved.
//

#import "NSObject+Encrypt.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

@implementation NSObject (Encrypt)

+ (id)u_encryptData:(NSData *)data withPassword:(NSString *)password error:(NSError **)error {
    return [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:error];
}

+ (id)u_decryptData:(NSData *)data withPassword:(NSString *)password error:(NSError **)error {
    return [RNDecryptor decryptData:data withPassword:password error:error];
}

+ (void)u_encryptData:(NSData *)data withPassword:(NSString *)password completionHandle:(void(^)(id encryptedData, NSError *error))completionHandle
{
    if (completionHandle) {
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *anError = nil;
            NSData *encryptedData = [weakSelf u_encryptData:data withPassword:password error:&anError];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle(encryptedData, anError);
            });
        });
    }
}

+ (void)u_decryptData:(NSData *)data withPassword:(NSString *)password completionHandle:(void(^)(id decryptedData, NSError *error))completionHandle
{
    if (completionHandle) {
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *anError = nil;
            NSData *decryptedData = [weakSelf u_decryptData:data withPassword:password error:&anError];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle(decryptedData, anError);
            });
        });
    }
}


@end
