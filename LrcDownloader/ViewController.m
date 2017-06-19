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

@interface ViewController()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSButton *filePathButton;
@property (weak) IBOutlet NSTextField *filePathField;
@property (weak) IBOutlet NSButton *startSearchingButton;
@property (weak) IBOutlet NSTableView *filesListTable;

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *progressLabel;

@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSString *selectedPath;

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
    NSArray *fileList = [manager contentsOfDirectoryAtPath:path error:nil];
    [self.fileList removeAllObjects];
    for (NSString *fileName in fileList) {
        if ([fileName isSongSuffix]) {
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

- (void)searchSongLrc {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (NSInteger i = 0; i< self.fileList.count;i++) {
            MusicItem *item = [self.fileList objectAtIndex:i];
            NSString *file = item.name;
            NSString *path = [NSString stringWithFormat:@"%@/%@", self.selectedPath, file];
            
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
            CMTime audioDuration= audioAsset.duration;
            float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
            
            NSString *fileName = [file removeSuffix];
            NSString *lrc = [KugouLyrics getLyricsByTitle:fileName getLyricsByArtist:nil getLyricsBySongDuration:audioDurationSeconds];
            if (lrc.length>0) {
                NSString *lrcFilePath = [NSString stringWithFormat:@"%@/%@.lrc", self.selectedPath, fileName];
                [lrc writeToFile:lrcFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                //设置成功
                item.status = DownloadStatusDone;
            }else {
                //设置失败
                item.status = DownloadStatusFail;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.filesListTable reloadData];
                [self.progressBar setUsesThreadedAnimation:YES];
                [self.progressBar setDoubleValue:(int)((i+1)/self.fileList.count)*100];
                [self.progressLabel setStringValue:[NSString stringWithFormat:@"%ld/%ld", i+1, self.fileList.count]];
            });
        }
    });
}

@end
