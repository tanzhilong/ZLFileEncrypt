//
//  ZLFileEncrypt.h
//  ZLFileEncrypt
//  文件加解密类
//  Created by 小陌雨 on 2018/9/27.
//  Copyright © 2018年 小陌雨Moyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZLFileEncrypt : NSObject

#pragma mark - 类方法

/**
 *  加密本地文件（异步，适合于大文件）
 *
 *  @param filePath         需要加密的文件
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否加密成功, param2:加密后的数据）
 */
+ (void)encryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *encryptedData))completionHandle;

/**
 *  加密数据（异步，适合于大数据）
 *
 *  @param sourceData       需要加密的数据
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否加密成功, param2:加密后的数据）
 */
+ (void)encryptData:(NSData *)sourceData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *encryptedData))completionHandle;

/**
 *  加密本地文件（同步，适合于小文件）
 *
 *  @param filePath 需要加密的文件
 *  @param password 密码
 *
 *  @return 是否加密成功
 */
+ (BOOL)encryptFile:(NSString *)filePath withPassword:(NSString *)password;

/**
 *  加密数据（同步，适合于小数据）
 *
 *  @param sourceData 需要加密的数据
 *  @param password   密码
 *
 *  @return 加密后的数据
 */
+ (NSData *)encryptData:(NSData *)sourceData withPassword:(NSString *)password;

/**
 *  解密本地文件（异步，适合于大文件）
 *
 *  @param encryptedData    需要解密的数据
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否解密成功, param2:解密后的数据）
 */
+ (void)decryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle;

/**
 *  解密数据（异步，适合于大数据）
 *
 *  @param encryptedData    需要解密的数据
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否解密成功, param2:解密后的数据）
 */
+ (void)decryptData:(NSData *)encryptedData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle;

/**
 *  解密本地文件（同步，适合小文件）
 *
 *  @param filePath 需要解密的文件
 *  @param password 密码
 *
 *  @return 解密后的数据（密码不对的话返回空）
 */
+ (NSData *)decryptFile:(NSString *)filePath withPassword:(NSString *)password;

/**
 *  解密数据（同步，适合于小数据）
 *
 *  @param encryptedData 需要解密的数据
 *  @param password      密码
 *
 *  @return 解密后的数据
 */
+ (NSData *)decryptData:(NSData *)encryptedData withPassword:(NSString *)password;


#pragma mark - 实例方法

/**
 *  加密本地文件（异步，适合于大文件）
 *
 *  @param filePath         需要加密的文件
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否加密成功, param2:加密后的数据）
 */
- (void)encryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *encryptedData))completionHandle;

/**
 *  加密数据（异步，适合于大数据）
 *
 *  @param sourceData       需要加密的数据
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否加密成功, param2:加密后的数据）
 */
- (void)encryptData:(NSData *)sourceData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *encryptedData))completionHandle;

/**
 *  加密本地文件（同步，适合于小文件）
 *
 *  @param filePath 需要加密的文件
 *  @param password 密码
 *
 *  @return 是否加密成功
 */
- (BOOL)encryptFile:(NSString *)filePath withPassword:(NSString *)password;

/**
 *  加密数据（同步，适合于小数据）
 *
 *  @param sourceData 需要加密的数据
 *  @param password   密码
 *
 *  @return 加密后的数据(加密失败返回nil)
 */
- (NSData *)encryptData:(NSData *)sourceData withPassword:(NSString *)password;

/**
 *  解密本地文件（异步，适合于大文件）
 *
 *  @param encryptedData    需要解密的数据
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否解密成功, param2:解密后的数据）
 */
- (void)decryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle;

/**
 *  解密数据（异步，适合于大数据）
 *
 *  @param encryptedData    需要解密的数据
 *  @param password         密码
 *  @param completionHandle 加密完成后的操作（param1:是否解密成功, param2:解密后的数据）
 */
- (void)decryptData:(NSData *)encryptedData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle;

/**
 *  解密本地文件（同步，适合小文件）
 *
 *  @param filePath 需要解密的文件
 *  @param password 密码
 *
 *  @return 解密后的数据（密码不对或者解密失败返回nil）
 */
- (NSData *)decryptFile:(NSString *)filePath withPassword:(NSString *)password;

/**
 *  解密数据（同步，适合于小数据）
 *
 *  @param encryptedData 需要解密的数据
 *  @param password      密码
 *
 *  @return 解密后的数据（密码不对或者解密失败返回nil）
 */
- (NSData *)decryptData:(NSData *)encryptedData withPassword:(NSString *)password;

@end
