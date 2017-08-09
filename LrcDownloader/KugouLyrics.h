//
//  KugouLyrics.h
//  LyricX
//
//  Created by LuoShihui on 2017/3/27.
//  Copyright © 2017年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestSender.h"
#import "KeyValue_SearchLyrics.h"

@interface KugouLyrics : NSObject

+ (void)getLyricsByTitle:(NSString *)Title getLyricsByArtist:(NSString *)Artist getLyricsBySongDuration:(double)duration complete:(void (^)(NSString *songName, NSString *singer, NSString *lrc))complete;

+ (void)getLyricsListByTitle:(NSString *)Title getLyricsListByArtist:(NSString *)Artist getLyricsBySongDuration:(double)duration AddToArrayController:(NSArrayController *)array_controller;

+ (NSString *)getLyricsByID:(NSString *)ID getLyricsByAccesskey:(NSString *)accesskey;

@end
