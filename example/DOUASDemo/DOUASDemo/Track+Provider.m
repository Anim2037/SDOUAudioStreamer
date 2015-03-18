/* vim: set ft=objc fenc=utf-8 sw=2 ts=2 et: */
/*
 *  DOUAudioStreamer - A Core Audio based streaming audio player for iOS/Mac:
 *
 *      https://github.com/douban/DOUAudioStreamer
 *
 *  Copyright 2013-2014 Douban Inc.  All rights reserved.
 *
 *  Use and distribution licensed under the BSD license.  See
 *  the LICENSE file for full text.
 *
 *  Authors:
 *      Chongyu Zhu <i@lembacon.com>
 *
 */

#import "Track+Provider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Track (Provider)

+ (void)load
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self remoteTracks];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self musicLibraryTracks];
    });
}

+ (NSArray *)remoteTracks
{
    static NSArray *tracks = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://douban.fm/j/mine/playlist?type=n&channel=1004693&from=mainsite"]];
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:NULL
                                                         error:NULL];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
        
        NSMutableArray *allTracks = [NSMutableArray array];
        for (NSDictionary *song in [dict objectForKey:@"song"]) {
            Track *track = [[Track alloc] init];
            [track setArtist:[song objectForKey:@"artist"]];
            [track setTitle:[song objectForKey:@"title"]];
            [track setAudioFileURL:[NSURL URLWithString:@"http://ringcall.appdao.com/ringtone_files/2d/a8/e7/2da8e716e7de361c37587c517f7b638a.mp3"]];
            [allTracks addObject:track];
        }
        
        tracks = [allTracks copy];
    });
    
    return tracks;
}

+ (NSArray *)musicLibraryTracks
{
    static NSArray *tracks = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *allTracks = [NSMutableArray array];
        
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:cachePath error:nil];
        for (NSString *fileName in fileArray) {
            BOOL flag = YES;
            NSString *fullPath = [cachePath stringByAppendingPathComponent:fileName];
            if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
                if (!flag) {
                    // ignore .DS_Store
                    if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                        Track *track = [[Track alloc] init];
                        [track setArtist:@"测试作者"];
                        [track setTitle:@"测试标题"];
                        [track setAudioFileURL:[NSURL fileURLWithPath:fullPath]];
                        [allTracks addObject:track];
                    }
                }
//                else {
//                    [pathArray addObject:[self allFilesAtPath:fullPath]];
//                }
            }
        }
        
//        for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
//            if ([[item valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
//                continue;
//            }
//            
//            Track *track = [[Track alloc] init];
//            [track setArtist:[item valueForProperty:MPMediaItemPropertyArtist]];
//            [track setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
//            [track setAudioFileURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
//            [allTracks addObject:track];
//        }
//        
//        for (NSUInteger i = 0; i < [allTracks count]; ++i) {
//            NSUInteger j = arc4random_uniform((u_int32_t)[allTracks count]);
//            [allTracks exchangeObjectAtIndex:i withObjectAtIndex:j];
//        }
        
        tracks = [allTracks copy];
    });
    
    return tracks;
}

@end
