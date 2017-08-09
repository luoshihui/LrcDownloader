//
//  MusicItem.h
//  LrcDownloader
//
//  Created by LuoShihui on 2017/6/18.
//  Copyright © 2017年 Zhonglian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DownloadStatus) {
    DownloadStatusWait,
    DownloadStatusDone,
    DownloadStatusFail
};

@interface MusicItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) DownloadStatus status;

+ (instancetype)itemWithName:(NSString *)name;

- (NSString *)statusString;

@end
