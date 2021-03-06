//
//  ViewController.m
//  LrcDownloader
//
//  Created by LuoShihui on 2017/6/17.
//  Copyright © 2017年 Zhonglian. All rights reserved.
//

#import "ViewController.h"
#import "NSString+MusicFile.h"
#import "KugouLyrics.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicItem.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MJExtension/MJExtension.h>

@interface ViewController()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSButton *filePathButton;
@property (weak) IBOutlet NSTextField *filePathField;
@property (weak) IBOutlet NSButton *startSearchingButton;
@property (weak) IBOutlet NSTableView *filesListTable;

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *progressLabel;

@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSString *selectedPath;
@property (nonatomic, strong) NSMutableArray *successList;
@property (nonatomic, strong) NSMutableArray *failList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)clickSelectPath:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    __weak typeof(self)weakSelf = self;
    panel.canCreateDirectories = NO;
    panel.canChooseDirectories = YES;
    panel.allowsMultipleSelection = NO;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSString *pathString = [panel.URLs.firstObject path];
            self.selectedPath = pathString;
            weakSelf.filePathField.stringValue = pathString;
            [weakSelf listSongFilesWithPath:pathString];
        }
    }];
}

- (IBAction)clickStartSearch:(id)sender {
    [self searchSongLrc];
}

- (void)listSongFilesWithPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager subpathsOfDirectoryAtPath:path error:nil];
    [self.fileList removeAllObjects];
    for (NSString *fileName in fileList) {
        if ([fileName isSupportSongSuffix]) {
            MusicItem *item = [MusicItem itemWithName:fileName];
            [self.fileList addObject:item];
        }
    }
    [self.filesListTable reloadData];
    [self.progressLabel setStringValue:[NSString stringWithFormat:@"0/%ld", self.fileList.count]];
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.fileList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MusicItem *item = [self.fileList objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:@"name"]) {
        return item.name;
    }else if ([tableColumn.identifier isEqualToString:@"status"]) {
        return item.statusString;
    }else if ([tableColumn.identifier isEqualToString:@"duration"]) {
        return @(item.audioDuration);
    }
    return @"";
}

- (NSMutableArray *)fileList
{
	if (!_fileList){
        _fileList = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return _fileList;
}

- (NSMutableArray *)successList
{
    if (!_successList){
        _successList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _successList;
}

- (NSMutableArray *)failList
{
    if (!_failList){
        _failList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _failList;
}

- (void)searchSongLrc {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.failList removeAllObjects];
        [self.successList removeAllObjects];
        for (NSInteger i = 0; i< self.fileList.count;i++) {
            MusicItem *item = [self.fileList objectAtIndex:i];
            NSString *file = item.name;
            NSString *subPath = item.path;
            NSString *path = [NSString stringWithFormat:@"%@/%@%@", self.selectedPath, subPath, file];
            
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
            CMTime audioDuration= audioAsset.duration;
            float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
            item.audioDuration = audioDurationSeconds;
        
            if (audioDurationSeconds == 0) {
                item.status = DownloadStatusFail;
                [self reloadTableAndProgress:i];
                [self.failList addObject:item];
                NSLog(@"歌曲解析时间失败: %@", [item mj_JSONString]);
                continue;
            }
            
            NSString *fileName = [file removeSuffix];
            [KugouLyrics getLyricsByTitle:fileName getLyricsByArtist:nil getLyricsBySongDuration:audioDurationSeconds complete:^(NSString *songName, NSString *singer, NSString *lrc) {
                if (lrc.length>0) {
                    NSString *lrcFilePath = [NSString stringWithFormat:@"%@/%@%@.lrc", self.selectedPath,subPath,fileName];
                    songName = songName.length > 0 ? songName : fileName;
                    singer = singer.length > 0 ? singer : @"未知";
                    NSString *lrcHeader = [self lrcHeaderForSong:songName singer:singer];
                    lrc = [lrcHeader stringByAppendingString:lrc];
                    [lrc writeToFile:lrcFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
                    //设置成功
                    item.status = DownloadStatusDone;
                    [self.successList addObject:item];
                }else {
                    //设置失败
                    item.status = DownloadStatusFail;
                    [self.failList addObject:item];
                    NSLog(@"未找到歌词: %@, 时长: %.2f", fileName, audioDurationSeconds);
                }
                [self reloadTableAndProgress:i];
            }];
        }
    });
}

- (void)reloadTableAndProgress:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.filesListTable reloadData];
        [self.progressBar setUsesThreadedAnimation:YES];
        [self.progressBar setDoubleValue:(int)((index+1)/self.fileList.count)*100];
        [self.progressLabel setStringValue:[NSString stringWithFormat:@"%ld/%ld", index+1, self.fileList.count]];
        
        if (index >= self.fileList.count - 1) {
            [self finishSearching];
        }
    });
}

- (void)finishSearching {
    self.progressLabel.stringValue = [NSString stringWithFormat:@"完成!成功%ld首，失败%ld首", self.successList.count, self.failList.count];
}

- (NSString *)lrcHeaderForSong:(NSString *)songName singer:(NSString *)singer  {
    return [NSString stringWithFormat:@"[ti:%@]\r\n[ar:%@]\r\n[al:未知]\r\n", songName, singer];
}

@end
