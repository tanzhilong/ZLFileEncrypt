//
//  NSObject+Encrypt.h
//  ZLFileEncrypt
//
//  Created by TanZhilong on 16/10/14.
//  Copyright © 2016年 TZL. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  文件加密的分类(与第三方库的耦合分类)
 */
@interface NSObject (Encrypt)

/**
 *  加密数据（同步）
 *
 *  @param data     需要加密的数据
 *  @param password 密码
 *  @param error    错误信息
 *
 *  @return 加密后的数据
 */
+ (id)u_encryptData:(NSData *)data withPassword:(NSString *)password error:(NSError **)error;

/**
 *  解密数据（同步）
 *
 *  @param data     需要解密的数据
 *  @param password 密码
 *  @param error    错误信息
 *
 *  @return 解密后的数据
 */
+ (id)u_decryptData:(NSData *)data withPassword:(NSString *)password error:(NSError **)error;

/**
 *  加密数据（异步）
 *
 *  @param data             需要加密的数据
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:加密后的数据，param2:错误信息）
 */
+ (void)u_encryptData:(NSData *)data withPassword:(NSString *)password completionHandle:(void(^)(id encryptedData, NSError *error))completionHandle;

/**
 *  解密数据（异步）
 *
 *  @param data             需要解密的数据
 *  @param password         密码
 *  @param completionHandle 解密完成后的操作（param1:解密后的数据，param2:错误信息）
 */
+ (void)u_decryptData:(NSData *)data withPassword:(NSString *)password completionHandle:(void(^)(id decryptedData, NSError *error))completionHandle;

@end
