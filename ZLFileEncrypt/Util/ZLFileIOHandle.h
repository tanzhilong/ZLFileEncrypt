//
//  ZLFileIOHandle.h
//  ZLFileEncrypt
//  文件管理工具
//  Created by 小陌雨 on 2018/9/27.
//  Copyright © 2018年 小陌雨Moyu. All rights reserved.
//

/*
 1.Documents
 ①存放内容
 我们可以将应用程序的数据文件保存在该目录下。不过这些数据类型仅限于不可再生的数据，可再生的数据文件应该存放在Library/Cache目录下。
 ②会被iTunes同步
 
 2.Documents/Inbox
 ①存放内容
 该目录用来保存由外部应用请求当前应用程序打开的文件。
 比如我们的应用叫A，向系统注册了几种可打开的文件格式，B应用有一个A支持的格式的文件F，并且申请调用A打开F。由于F当前是在B应用的沙盒中，我们知道，沙盒机制是不允许A访问B沙盒中的文件，因此苹果的解决方案是讲F拷贝一份到A应用的Documents/Inbox目录下，再让A打开F。
 ②会被iTunes同步
 
 3.Library
 ①存放内容
 苹果建议用来存放默认设置或其它状态信息。
 ②会被iTunes同步,但是要除了Caches子目录外
 
 4.Library/Preferences
 ①存放内容
 应用程序的偏好设置文件。我们使用NSUserDefaults写的设置数据都会保存到该目录下的一个plist文件中，这就是所谓的写到plist中！
 ②会被iTunes同步
 
 5.tmp
 ①存放内容
 各种临时文件，保存应用再次启动时不需要的文件。而且，当应用不再需要这些文件时应该主动将其删除，因为该目录下的东西随时有可能被系统清理掉，目前已知的一种可能清理的原因是系统磁盘存储空间不足的时候。
 ②会被iTunes同步
 */

#import <Foundation/Foundation.h>

/** 系统预置文件夹名字 */
typedef enum{
    ZLFileDirectoryTypeHome = 101, //!< 沙盒根目录
    ZLFileDirectoryTypeDocuments, //!< Documents目录,应用中用户数据可以放在这里，iTunes同步时会备份此目录
    ZLFileDirectoryTypeLibrary, //!< Library目录,iTunes同步时会备份此目录
    ZLFileDirectoryTypeCaches, //!< Library/Caches目录,iTunes同步不会备份此目录,此目录下文件不会在应用退出后删除
    ZLFileDirectoryTypeTmp //!< tmp目录，存放临时文件,iTunes不会备份此目录,此目录下文件可能会在应用退出后删除,重启后即全部删除
}ZLFileDirectoryType;

/** 文件夹权限 */
typedef enum{
    ZLFileDirectoryJurisdictionTypeDefault = 101, //!< 默认权限
    ZLFileDirectoryJurisdictionTypeWrite, //!< 写
    ZLFileDirectoryJurisdictionTypeRead, //!< 读
    ZLFileDirectoryJurisdictionTypeRun //!< 执行
}ZLFileDirectoryJurisdictionType;

@interface ZLFileIOHandle : NSObject

/**
 *  获取沙盒中某个系统预置文件夹的路径
 *
 *  @param directoryType 系统文件夹的名字
 *
 *  @return 路径
 */
+ (NSString *)getDirectoryPathWithType:(ZLFileDirectoryType)directoryType;

/**
 *  创建文件（同步操作，在主线程完成）
 *
 *  @param fileName      文件名
 *  @param content       文件内容(NSString、NSDictionary、NSArray、NSData、NSNumber)
 *  @param directoryPath 文件夹路径
 *
 *  @return 是否成功
 */
+ (BOOL)createFileByFileName:(NSString *)fileName content:(id)content directoryPath:(NSString *)directoryPath;

/**
 *  创建文件（异步操作，写入操作在子线程完成）
 *
 *  @param fileName         文件名
 *  @param content          文件内容(NSString、NSDictionary、NSArray、NSData、NSNumber)
 *  @param directoryPath    文件夹路径
 *  @param completionHandle 写入结果回调Block
 *
 *  @return 预留扩展接口，一般情况不用
 */
+ (id)createFileByFileName:(NSString *)fileName content:(id)content directoryPath:(NSString *)directoryPath completionHandle:(void(^)(BOOL success, NSString *filePath))completionHandle;

/**
 *  给文件写入内容（如果文件不存在，会自动创建）
 *
 *  @param filePath 文件路径
 *  @param content  要写入的内容
 *
 *  @return 是否成功
 */
+ (BOOL)writeContentToFileWithPath:(NSString *)filePath content:(id)content;

/**
 *  创建文件夹
 *
 *  @param path             路径
 *
 *  @return 是否成功
 */
+ (BOOL)createDirectoryAtPath:(NSString *)path;

/**
 *  获取某个目录下的所有子目录的相对路径（包括子文件夹以及子文件夹中的文件）
 *
 *  @param path             路径
 *  @param completionHandle 获取都结果后回调的Block
 *
 *  @return 预留扩展接口，一般情况不用
 */
+ (id)getAllSubPathAtPath:(NSString *)path completionHandle:(void(^)(NSArray *subPaths, NSError *error))completionHandle;

/**
 *  获取某个目录下的所有子目录的绝对路径（包括子文件夹以及子文件夹中的文件）
 *
 *  @param path             路径
 *  @param completionHandle 获取到结果后回调的Block
 *
 *  @return 预留扩展接口，一般情况不用
 */
+ (id)getAllSubFileOrDirectoryFullPathAtPath:(NSString *)path completionHandle:(void(^)(NSArray *fullPaths, NSError *error))completionHandle;

///**
// *  复制小文件/文件夹
// *
// *  @param sourceFilePath      源文件/文件夹路径
// *  @param destinationFilePath 目标文件/文件夹路径
// *
// *  @return 是否成功
// */
//+ (BOOL)copySmallFileOrDirectoryWithSourceFilePath:(NSString *)sourceFilePath destinationFilePath:(NSString *)destinationFilePath;

/**
 *  复制文件/文件夹
 *
 *  @param sourceFilePath      源文件/文件夹路径
 *  @param destinationFilePath 目标文件/文件夹路径
 *
 *  @return 是否成功
 */
+ (BOOL)copyFileOrDirectoryWithSourceFilePath:(NSString *)sourceFilePath destinationFilePath:(NSString *)destinationFilePath;

/**
 *  移动文件/文件夹
 *
 *  @param sourceFilePath      源文件/文件夹路径
 *  @param destinationFilePath 目标文件/文件夹路径
 *  @param completionHandle    操作完成后的回调Block
 *
 *  @return 预留扩展接口，一般情况不用
 */
+ (id)moveFileOrDirectoryWithSourceFilePath:(NSString *)sourceFilePath destinationFilePath:(NSString *)destinationFilePath completionHandle:(void(^)(BOOL success, NSError *error))completionHandle;

/**
 *  删除文件/文件夹
 *
 *  @param path             文件/文件夹路径
 *  @param completionHandle 操作完成后的回调Block
 *
 *  @return 预留扩展接口，一般情况不用
 */
+ (id)deleteFileOrDirectoryWithPath:(NSString *)path completionHandle:(void(^)(BOOL success, NSError *error))completionHandle;

/**
 *  根据路径判断文件/文件夹是否存在，并且判断该路径是文件还是文件夹
 *
 *  @param path        路径
 *  @param isDirectory 是否是文件夹(如果不需要判断，请输入NULL)
 *
 *  @return 存在与否
 */
+ (BOOL)judgeFileOrDirectoryExistWithPath:(NSString *)path isDirectory:(BOOL *)isDirectory;

/**
 *  获取某个文件的大小
 *
 *  @param path      文件路径
 *
 *  @return 空间大小(单位是bytes)
 */
+ (long long)diskStorageSizeOfFilePath:(NSString *)filePath;

/**
 *  获取某个文件夹的大小
 *
 *  @param directoryPath    文件夹路径
 *  @param completionHandle 获取到空间大小后返回的操作(空间大小的单位是bytes)
 *
 *  @return 预留扩展接口，一般情况不用
 */
+ (id)diskStorageSizeOfDirectoryPath:(NSString *)directoryPath completionHandle:(void(^)(long long totalSize))completionHandle;

@end
