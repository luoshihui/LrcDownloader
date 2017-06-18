//
//  NSString+MusicFile.m
//  LrcDownloader
//
//  Created by LuoShihui on 2017/6/18.
//  Copyright © 2017年 Zhonglian. All rights reserved.
//

#import "NSString+MusicFile.h"

@implementation NSString (MusicFile)

- (BOOL)isSongSuffix {
    NSArray *componests = [self componentsSeparatedByString:@"."];
    if (componests.count <= 0) {
        return NO;
    }else {
        NSString *suffix = [componests lastObject];
        if ([[self songSuffixList] containsObject:[suffix lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)songSuffixList {
    return @[@"mp3", @"flac", @"wav", @"ape", @"aac"];
}

- (NSString *)removeSuffix {
    NSArray *componests = [self componentsSeparatedByString:@"."];
    if (componests.count <= 0) {
        return self;
    }else {
        NSString *suffix = [componests lastObject];
        return [self substringToIndex:([self rangeOfString:suffix].location - 1)];
    }
}

@end
