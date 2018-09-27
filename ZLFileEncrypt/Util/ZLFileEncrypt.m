//
//  ZLFileEncrypt.m
//  ZLFileEncrypt
//  
//  Created by 小陌雨 on 2018/9/27.
//  Copyright © 2018年 小陌雨Moyu. All rights reserved.
//

#import "ZLFileEncrypt.h"
#import "NSObject+Encrypt.h" // 加解密分类（与第三方库的耦合接口）
#import "ZLFileIOHandle.h"   // 文件处理类

#define kEncryptedFileExtensionName @"zlency" //!< 加密文件的后缀名

@implementation ZLFileEncrypt

#pragma mark - 类方法

/** 加密本地文件（异步，适合于大文件）*/
+ (void)encryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *encryptedData))completionHandle {
    return [[self alloc] encryptFile:filePath withPassword:password completionHandle:completionHandle];
}

/** 加密数据（异步，适合于大数据）*/
+ (void)encryptData:(NSData *)sourceData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *encryptedData))completionHandle {
    return [[self alloc] encryptData:sourceData withPassword:password completionHandle:completionHandle];
}

/** 加密本地文件（同步，适合于小文件）*/
+ (BOOL)encryptFile:(NSString *)filePath withPassword:(NSString *)password {
    return [[self alloc] encryptFile:filePath withPassword:password];
}

/** 加密数据（同步，适合于小数据）*/
+ (NSData *)encryptData:(NSData *)sourceData withPassword:(NSString *)password {
    return [[self alloc] encryptData:sourceData withPassword:password];
}

/** 解密本地文件（异步，适合于大文件）*/
+ (void)decryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle {
    return [[self alloc] decryptFile:filePath withPassword:password completionHandle:completionHandle];
}

/** 解密数据（异步，适合于大数据）*/
+ (void)decryptData:(NSData *)encryptedData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle {
    return [[self alloc] decryptData:encryptedData withPassword:password completionHandle:completionHandle];
}

/** 解密本地文件（同步，适合小文件）*/
+ (NSData *)decryptFile:(NSString *)filePath withPassword:(NSString *)password {
    return [[self alloc] decryptFile:filePath withPassword:password];
}

/** 解密数据（同步，适合于小数据）*/
+ (NSData *)decryptData:(NSData *)encryptedData withPassword:(NSString *)password {
    return [[self alloc] decryptData:encryptedData withPassword:password];
}

#pragma mark - 实例方法

/** 加密本地文件（异步，适合于大文件）*/
- (void)encryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void (^)(BOOL, NSData *))completionHandle
{
    NSData *contentData = [NSData dataWithContentsOfFile:filePath];
    if (!contentData) {
        NSLog(@"文件不存在或者文件已经加密过!");
        return;
    } else {
        // 从路径中获得完整的文件名（带后缀）
        NSString *sourceFileNameWithExtension = [filePath lastPathComponent];
        // 获得文件名（不带后缀）
        NSString *sourceFileName = [sourceFileNameWithExtension stringByDeletingPathExtension];
        // 加密后的文件的文件名（带后缀）
        NSString *encryptFileNameWithExtension = [NSString stringWithFormat:@"%@.%@",sourceFileName, kEncryptedFileExtensionName];
        // 加密后的文件所在的文件夹
        NSString *encryptFileDirectoryPath = [filePath stringByDeletingLastPathComponent];
        
        // 生成加密文件并删除源文件
        [self encryptData:contentData withPassword:password completionHandle:^(BOOL isSuccess, NSData *encryptedData) {
            if (isSuccess == NO) {
                if (completionHandle) {
                    completionHandle(isSuccess, encryptedData);
                }
            } else {
                // 创建加密后的文件
                [ZLFileIOHandle createFileByFileName:encryptFileNameWithExtension content:encryptedData directoryPath:encryptFileDirectoryPath completionHandle:^(BOOL success, NSString *encryptedPath) {
                    if (success) {
                        // 删除源文件
                        [ZLFileIOHandle deleteFileOrDirectoryWithPath:filePath completionHandle:nil];
                        if (completionHandle) {
                            completionHandle(success, encryptedData);
                        }
                    } else {
                        NSLog(@"创建加密文件失败!");
                        if (completionHandle) {
                            completionHandle(NO, encryptedData);
                        }
                    }
                }];
            }
        }];
    }
}

/** 加密数据（异步，适合于大数据）*/
- (void)encryptData:(NSData *)sourceData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *encryptedData))completionHandle
{
    if (completionHandle) {
        [[self class] u_encryptData:sourceData withPassword:password completionHandle:^(id encryptedData, NSError *error) {
            BOOL success = error ? NO : YES;
            completionHandle(success, encryptedData);
        }];
    }
}

/** 加密本地文件（同步，适合于小文件）*/
- (BOOL)encryptFile:(NSString *)filePath withPassword:(NSString *)password
{
    NSData *contentData = [NSData dataWithContentsOfFile:filePath];
    if (!contentData) {
        NSLog(@"文件不存在或者文件已经加密过!");
    } else {
        // 从路径中获得完整的文件名（带后缀）
        NSString *sourceFileNameWithExtension = [filePath lastPathComponent];
        // 获得文件名（不带后缀）
        NSString *sourceFileName = [sourceFileNameWithExtension stringByDeletingPathExtension];
        // 加密后的文件的文件名（带后缀）
        NSString *encryptFileNameWithExtension = [NSString stringWithFormat:@"%@.%@",sourceFileName, kEncryptedFileExtensionName];
        // 加密后的文件所在的文件夹
        NSString *encryptFileDirectoryPath = [filePath stringByDeletingLastPathComponent];
        
        // 创建加密后的文件
        NSData *encryptData = [self encryptData:contentData withPassword:password];
        if (encryptData) {
            if (YES == [ZLFileIOHandle createFileByFileName:encryptFileNameWithExtension content:encryptData directoryPath:encryptFileDirectoryPath]) {
                // 删除源文件
                [ZLFileIOHandle deleteFileOrDirectoryWithPath:filePath completionHandle:nil];
                return YES;
            } else {
                NSLog(@"创建加密文件失败!");
            }
        }
    }
    
    return NO;
}

/** 加密数据（同步，适合于小数据）*/
- (NSData *)encryptData:(NSData *)sourceData withPassword:(NSString *)password
{
    NSError *error = nil;
    NSData *contentData = [[self class] u_encryptData:sourceData withPassword:password error:&error];
    return error ? nil : contentData;
}

/** 解密本地文件（异步，适合于大文件）*/
- (void)decryptFile:(NSString *)filePath withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle
{
    // 从路径中获得完整的文件名（带后缀）
    NSString *sourceFileNameWithExtension = [filePath lastPathComponent];
    // 获得文件后缀
    NSString *extensionName = [sourceFileNameWithExtension pathExtension];
    
    // 经过加密的文件的路径
    NSString *encryptedFilePath = nil;
    if ([extensionName isEqualToString:kEncryptedFileExtensionName]) {
        encryptedFilePath = filePath;
    } else {
        NSString *encryptedFileNameWithExtension = [sourceFileNameWithExtension stringByReplacingOccurrencesOfString:extensionName withString:kEncryptedFileExtensionName];
        encryptedFilePath = [filePath stringByReplacingOccurrencesOfString:sourceFileNameWithExtension withString:encryptedFileNameWithExtension];
    }
    
    [self decryptData:[NSData dataWithContentsOfFile:encryptedFilePath] withPassword:password completionHandle:completionHandle];
}

/** 解密数据（异步，适合于大数据）*/
- (void)decryptData:(NSData *)encryptedData withPassword:(NSString *)password completionHandle:(void(^)(BOOL isSuccess, NSData *decryptedData))completionHandle
{
    [[self class] u_decryptData:encryptedData withPassword:password completionHandle:^(id decryptedData, NSError *error) {
        if (completionHandle) {
            BOOL success = error ? NO : YES;
            completionHandle(success, decryptedData);
        }
    }];
}

/** 解密本地文件（同步，适合小文件）*/
- (NSData *)decryptFile:(NSString *)filePath withPassword:(NSString *)password
{
    // 从路径中获得完整的文件名（带后缀）
    NSString *sourceFileNameWithExtension = [filePath lastPathComponent];
    // 获得文件后缀
    NSString *extensionName = [sourceFileNameWithExtension pathExtension];
    
    // 经过加密的文件的路径
    NSString *encryptedFilePath = nil;
    if ([extensionName isEqualToString:kEncryptedFileExtensionName]) {
        encryptedFilePath = filePath;
    } else {
        NSString *encryptedFileNameWithExtension = [sourceFileNameWithExtension stringByReplacingOccurrencesOfString:extensionName withString:kEncryptedFileExtensionName];
        encryptedFilePath = [filePath stringByReplacingOccurrencesOfString:sourceFileNameWithExtension withString:encryptedFileNameWithExtension];
    }
    
    return [self decryptData:[NSData dataWithContentsOfFile:encryptedFilePath] withPassword:password];
}

/** 解密数据（同步，适合于小数据）*/
- (NSData *)decryptData:(NSData *)encryptedData withPassword:(NSString *)password
{
    NSError *error = nil;
    NSData *contentData = [[self class] u_decryptData:encryptedData withPassword:password error:&error];
    return error ? nil : contentData;
}

@end
