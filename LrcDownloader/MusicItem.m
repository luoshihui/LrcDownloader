//
//  MusicItem.m
//  LrcDownloader
//
//  Created by LuoShihui on 2017/6/18.
//  Copyright © 2017年 Zhonglian. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

+ (instancetype)itemWithName:(NSString *)name {
    MusicItem *item = [[MusicItem alloc] init];
    item.name = name;
    item.status = DownloadStatusWait;
    return item;
}

- (NSString *)statusString {
    switch (self.status) {
        case DownloadStatusDone:
            return @"完成";
        case DownloadStatusFail:
            return @"失败";
        case DownloadStatusWait:
        default:
            return @"等待";
    }
}

@end
