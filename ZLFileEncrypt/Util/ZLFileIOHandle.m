//
//  ZLFileIOHandle.m
//  ZLFileEncrypt
//  
//  Created by 小陌雨 on 2018/9/27.
//  Copyright © 2018年 小陌雨Moyu. All rights reserved.
//

#import "ZLFileIOHandle.h"
#import <sys/stat.h>
#import <dirent.h>

/** 获取弱引用 */
#define kZLIOGetWeakSelf   __weak __typeof(self) weakSelf = self

/** 文件句柄类型 */
typedef enum{
    ZLFileHandleTypeWrite = 101, //!< 写句柄
    ZLFileHandleTypeRead, //!< 读句柄
    ZLFileHandleTypeUpdate //!< 更新句柄
}ZLFileHandleType;

static const NSInteger readFileSizePerTime = 5000; //!< 每次读取数据大小（bytes）

@implementation ZLFileIOHandle

#pragma mark - InterfaceMethods

/** 获取系统预置文件夹路径 */
+ (NSString *)getDirectoryPathWithType:(ZLFileDirectoryType)directoryType
{
    NSString *directoryPath = nil;
    switch (directoryType) {
        case ZLFileDirectoryTypeHome:
            directoryPath = NSHomeDirectory();
            break;
            
        case ZLFileDirectoryTypeDocuments:
            directoryPath = [self p_getFilePathWithDirectory:NSDocumentDirectory];
            break;
            
        case ZLFileDirectoryTypeTmp:
            directoryPath = NSTemporaryDirectory();
            break;
            
        case ZLFileDirectoryTypeLibrary:
            directoryPath = [self p_getFilePathWithDirectory:NSLibraryDirectory];
            break;
            
        case ZLFileDirectoryTypeCaches:
            directoryPath = [self p_getFilePathWithDirectory:NSCachesDirectory];
            break;
            
        default:
            break;
    }
    
    return directoryPath;
}

/** 创建文件(同步) */
+ (BOOL)createFileByFileName:(NSString *)fileName content:(id)content directoryPath:(NSString *)directoryPath
{
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    // 首先会判断文件是否存在，如果存在，直接写入内容；如果不存在，就创建文件并且写入内容
    id contentData = [content isKindOfClass:[NSData class]] ? content : [content dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:contentData attributes:nil];
}

/** 创建文件(异步) */
+ (id)createFileByFileName:(NSString *)fileName content:(id)content directoryPath:(NSString *)directoryPath completionHandle:(void (^)(BOOL, NSString *))completionHandle
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        // 首先会判断文件是否存在，如果存在，直接写入内容；如果不存在，就创建文件并且写入内容
        id contentData = [content isKindOfClass:[NSData class]] ? content : [content dataUsingEncoding:NSUTF8StringEncoding];
        BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:filePath contents:contentData attributes:nil];
        if (completionHandle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess ? completionHandle(isSuccess, filePath) : completionHandle(isSuccess, directoryPath);
            });
        }
    });
    return nil;
}

/** 写入内容 */
+ (BOOL)writeContentToFileWithPath:(NSString *)filePath content:(id)content
{
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (isSuccess) {
        NSData *contentData = nil;
        if (content == nil) {
            return YES;
        } else if ([content isKindOfClass:[NSData class]]) {
            contentData = content;
        } else {
            contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSFileHandle *fileHandle = [self p_fileHandleWithPath:filePath type:ZLFileHandleTypeWrite];
        [fileHandle writeData:contentData];
        [fileHandle closeFile];
    } else {
        return NO;
    }
    return YES;
}



/** 创建文件夹 */
+ (BOOL)createDirectoryAtPath:(NSString *)path
{
    NSError *error = nil;
    /*
     第二个参数：YES表示允许该文件夹已经存在
     第三个参数：nil表示权限默认：读/写/执行
     */
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
}

/** 获取某个目录下的所有子目录的相对路径（包括子文件夹以及子文件夹中的文件）*/
+ (id)getAllSubPathAtPath:(NSString *)path completionHandle:(void (^)(NSArray *, NSError *))completionHandle
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        NSArray *subPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:&error];
        if (completionHandle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle(subPaths, error);
            });
        }
    });
    
    return nil;
}

/** 获取某个目录下的所有子目录的绝对路径（包括子文件夹以及子文件夹中的文件）*/
+ (id)getAllSubFileOrDirectoryFullPathAtPath:(NSString *)path completionHandle:(void(^)(NSArray *fullPaths, NSError *error))completionHandle
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        NSArray *subPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:&error];
        NSMutableArray *fullPathsM = [NSMutableArray arrayWithCapacity:subPaths.count];
        for (NSString *subPath in subPaths) {
            [fullPathsM addObject:[path stringByAppendingPathComponent:subPath]];
        }
        if (completionHandle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle([fullPathsM copy], error);
            });
        }
    });
    
    return nil;
}

///** 复制小文件/文件夹 */
//+ (BOOL)copySmallFileOrDirectoryWithSourceFilePath:(NSString *)sourceFilePath destinationFilePath:(NSString *)destinationFilePath
//{
//    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:destinationFilePath contents:nil attributes:nil];
//
//    if (isSuccess) {
//        kZLIOGetWeakSelf;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            //        NSError *error = nil;
//            //        BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:sourceFilePath toPath:destinationFilePath error:&error];
//
//            // 创建写句柄和读句柄
//            NSFileHandle *sourceFileHandle = [weakSelf p_fileHandleWithPath:sourceFilePath type:ZLFileHandleTypeRead];
//            NSFileHandle *destinationFileHandle = [weakSelf p_fileHandleWithPath:destinationFilePath type:ZLFileHandleTypeWrite];
//            NSData *readData = [sourceFileHandle readDataToEndOfFile];
//            [destinationFileHandle writeData:readData];
//
//            [sourceFileHandle closeFile];
//            [destinationFileHandle closeFile];
//        });
//    }
//
//    return isSuccess;
//}

/** 复制文件/文件夹 */
+ (BOOL)copyFileOrDirectoryWithSourceFilePath:(NSString *)sourceFilePath destinationFilePath:(NSString *)destinationFilePath
{
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:destinationFilePath contents:nil attributes:nil];
    
    if (isSuccess) {
        kZLIOGetWeakSelf;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 创建写句柄和读句柄
            NSFileHandle *sourceFileHandle = [weakSelf p_fileHandleWithPath:sourceFilePath type:ZLFileHandleTypeRead];
            NSFileHandle *destinationFileHandle = [weakSelf p_fileHandleWithPath:destinationFilePath type:ZLFileHandleTypeWrite];
            
            // 从源文件中读数据;写到目标文件中
            // (1)循环读取源文件的数据
            // (2)判断是不是指定读取数据大小的整数倍
            // (3)文件总长度
            NSError *error = nil;
            NSDictionary *sourceFileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:sourceFilePath error:&error];
            NSNumber *fileSizeNumber = sourceFileDic[NSFileSize];
            NSInteger fileTotalSize = [fileSizeNumber longValue];
            
            NSInteger readSizePerTime = readFileSizePerTime; // 每次读取数据的大小
            NSInteger readSize = 0; // 已经读取数据的大小
            BOOL notEnd = YES; // 是否循环结束
            
            // 循环读取数据
            while (notEnd) {
                // 还剩余没有读取的数据大小
                NSInteger leftSize = fileTotalSize - readSize;
                if (leftSize < readSizePerTime) {
                    // 情况1：剩余大小不足每次应该读取的数据大小
                    NSData *readFileData = [sourceFileHandle readDataToEndOfFile];
                    [destinationFileHandle writeData:readFileData];
                    notEnd = NO;
                } else {
                    // 情况2：剩余大小大于每次应该读取的数据大小，按整数倍读取
                    NSData *readFileData = [sourceFileHandle readDataOfLength:readSizePerTime];
                    readSize = readSize + readSizePerTime;
                    [sourceFileHandle seekToFileOffset:readSize];
                    [destinationFileHandle writeData:readFileData];
                }
            }
            
            [sourceFileHandle closeFile];
            [destinationFileHandle closeFile];
            //            NSLog(@"caozuozhong:%@",[NSThread currentThread]);
        });
    }
    
    return isSuccess;
}

/** 移动文件/文件夹 */
+ (id)moveFileOrDirectoryWithSourceFilePath:(NSString *)sourceFilePath destinationFilePath:(NSString *)destinationFilePath completionHandle:(void (^)(BOOL, NSError *))completionHandle
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block NSError *error = nil;
        NSArray *subPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:sourceFilePath error:&error];
        if (error || subPaths == nil) {
            if (completionHandle) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandle(NO, error);
                });
            }
        } else {
            // GCD迭代
            NSInteger count = [subPaths count];
            dispatch_apply(count, dispatch_get_global_queue(0, 0), ^(size_t i) {
                NSString *fileName = subPaths[i];
                NSString *fromPath = [sourceFilePath stringByAppendingPathComponent:fileName];
                NSString *toPath = [destinationFilePath stringByAppendingPathComponent:fileName];
                [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error];
                //                MYLog(@"fuzhithread:%@",[NSThread currentThread]);
                if (completionHandle) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                        MYLog(@"fuzhiCompletionThread:%@",[NSThread currentThread]);
                        error ? completionHandle(NO, error) : completionHandle(YES, nil);
                    });
                }
            });
        }
    });
    
    return nil;
}

/** 删除文件/文件夹 */
+ (id)deleteFileOrDirectoryWithPath:(NSString *)path completionHandle:(void (^)(BOOL, NSError *))completionHandle
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (completionHandle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle(isSuccess, error);
            });
        }
    });
    
    return nil;
}

/** 根据路径判断文件/文件夹是否存在 */
+ (BOOL)judgeFileOrDirectoryExistWithPath:(NSString *)path isDirectory:(BOOL *)isDirectory
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

/** 获取某个文件的大小 */
+ (long long)diskStorageSizeOfFilePath:(NSString *)filePath
{
    return [self p_fileSizeOfPath:filePath];
}

/** 获取某个文件夹的大小 */
+ (id)diskStorageSizeOfDirectoryPath:(NSString *)directoryPath completionHandle:(void (^)(long long))completionHandle
{
    kZLIOGetWeakSelf;
    dispatch_queue_t loopDirectoryQueue = dispatch_queue_create("loopDirectoryQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(loopDirectoryQueue, ^{
        long long directorySize = [weakSelf p_directorySizeOfPath:directoryPath];
        if (completionHandle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle(directorySize);
            });
        }
    });
    return nil;
}


#pragma mark - PrivateMethods

+ (NSString *)p_getFilePathWithDirectory:(NSSearchPathDirectory)directory
{
    /*
     参数1：指定要搜索的目录
     参数2：指定搜索域（当前登录用户下）
     参数3：YES（绝对路径），NO（非绝对路径）
     */
    return [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) firstObject];
}

+ (NSFileHandle *)p_fileHandleWithPath:(NSString *)path type:(ZLFileHandleType)type
{
    NSFileHandle *fileHandle = nil;
    switch (type) {
        case ZLFileHandleTypeWrite:
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
            break;
            
        case ZLFileHandleTypeRead:
            fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
            break;
            
        case ZLFileHandleTypeUpdate:
            fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
            break;
            
        default:
            break;
    }
    return fileHandle;
}

+ (long long)p_fileSizeOfPath:(NSString *)path
{
    // 使用OC
    //    NSFileManager *manager = [NSFileManager defaultManager];
    //    if ([manager fileExistsAtPath:path]) {
    //        return [[manager attributesOfItemAtPath:path error:nil] fileSize];
    //    } else {
    //        return 0;
    //    }
    
    // 为提高性能，使用C语言
    struct stat st;
    if (lstat([path cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        return st.st_size;
    } else {
        return 0;
    }
}

+ (long long)p_directorySizeOfPath:(NSString *)path
{
    // 使用OC
    //    NSFileManager *manager = [NSFileManager defaultManager];
    //    if (![manager fileExistsAtPath:path])
    //    {
    //        return 0;
    //    }
    //    else
    //    {
    //        NSEnumerator *subFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator]; // 取出目录及子目录路径和其中所有文件路径创建枚举器
    //        NSString *fileName = nil;
    //        long long directorySize = 0;
    //        while ((fileName = [subFilesEnumerator nextObject]) != nil)
    //        {
    //            NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
    //            BOOL isDirectory = nil;
    //            [manager fileExistsAtPath:fileAbsolutePath isDirectory:&isDirectory];
    ////            directorySize = (isDirectory) ? directorySize : directorySize + [self p_fileSizeOfPath:fileAbsolutePath]; // 如果路径是子文件夹的路径，则跳过
    //            directorySize += [self p_fileSizeOfPath:fileAbsolutePath];
    //        }
    //        return directorySize;
    //    }
    
    // 为提高性能，使用C语言
    const char *cPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    long long directorySize = 0;
    
    DIR *dir = opendir(cPath);
    if (dir == NULL)
    {
        return 0;
    }
    else
    {
        struct dirent *child;
        while ((child = readdir(dir)) != NULL) {
            if ((child->d_type == DT_DIR && (child->d_name[0] == '.') && (child->d_name[1] == 0)) || /* 忽略目录.和.. */((child->d_name[0] == '.') && (child->d_name[1] == '.') && (child->d_name[2] == 0)))
            {
                continue;
            }
            int directoryPathLength = (int)strlen(cPath);
            char childPath[1024]; // 子文件的路径地址
            stpcpy(childPath, cPath);
            if (cPath[directoryPathLength - 1] != '/')
            {
                childPath[directoryPathLength] = '/';
                directoryPathLength++;
            }
            stpcpy(childPath + directoryPathLength, child->d_name);
            childPath[directoryPathLength + child->d_namlen] = 0;
            if (child->d_type == DT_DIR)
            {
                // directory
                directorySize += [self p_directorySizeOfPath:[NSString stringWithCString:childPath encoding:NSUTF8StringEncoding]]; // 递归，对子目录进行同样操作
                // 把目录本身所占用的空间也加上
                struct stat st;
                if (lstat(childPath, &st) == 0)
                {
                    directorySize += st.st_size;
                }
            }
            else if (child->d_type == DT_REG || child->d_type == DT_LNK)
            {
                // file or link
                struct stat st;
                if (lstat(childPath, &st) == 0)
                {
                    directorySize += st.st_size;
                }
            }
        }
    }
    return directorySize;
}

@end
