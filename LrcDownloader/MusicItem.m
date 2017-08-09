//
//  MusicItem.m
//  LrcDownloader
//
//  Created by LuoShihui on 2017/6/18.
//  Copyright © 2017年 Zhonglian. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

+ (instancetype)itemWithName:(NSString *)name{
    MusicItem *item = [[MusicItem alloc] init];
    NSArray *pathComponents = [name componentsSeparatedByString:@"/"];
    if (pathComponents.count > 0) {
        item.name = pathComponents.lastObject;
        item.path = [name substringWithRange:NSMakeRange(0, name.length - [name rangeOfString:pathComponents.lastObject].length)];
    }else {
        item.name = name;
        item.path = @"";
    }
    
    item.status = DownloadStatusWait;
    return item;
}

- (NSString *)statusString {
    switch (self.status) {
        case DownloadStatusDone:
            return @"成功";
        case DownloadStatusFail:
            return @"失败";
        case DownloadStatusWait:
        default:
            return @"等待";
    }
}

@end
