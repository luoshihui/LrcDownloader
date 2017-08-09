//
//  NSString+MusicFile.h
//  LrcDownloader
//
//  Created by LuoShihui on 2017/6/18.
//  Copyright © 2017年 Zhonglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MusicFile)

- (BOOL)isSongSuffix;

- (NSString *)removeSuffix;

- (BOOL)isWav;

- (BOOL)isMp3;

- (BOOL)isAac;

- (BOOL)isFlac;

- (BOOL)isApe;

@end
