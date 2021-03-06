//
// Created by Denis Dorokhov on 29/11/15.
// Copyright (c) 2015 Denis Dorokhov. All rights reserved.
//

#import "PNYRestService.h"
#import "PNYPersistentDictionary.h"
#import "PNYSongDto.h"

@class PNYSongDownloadService;

@protocol PNYSongDownload <NSObject>

@property (nonatomic, readonly) NSNumber *songId;
@property (nonatomic, readonly) NSString *filePath;
@property (nonatomic, readonly) NSDate *date;

@end

@protocol PNYSongDownloadProgress <NSObject>

@property (nonatomic, readonly) PNYSongDto *song;
@property (nonatomic, readonly) float value;

@end

@protocol PNYSongDownloadServiceDelegate <NSObject>

@optional

- (void)songDownloadService:(PNYSongDownloadService *)aService didStartSongDownload:(NSNumber *)aSongId;
- (void)songDownloadService:(PNYSongDownloadService *)aService didProgressSongDownload:(id <PNYSongDownloadProgress>)aProgress;
- (void)songDownloadService:(PNYSongDownloadService *)aService didCancelSongDownload:(NSNumber *)aSongId;
- (void)songDownloadService:(PNYSongDownloadService *)aService didFailSongDownload:(NSNumber *)aSongId errors:(NSArray *)aErrors;
- (void)songDownloadService:(PNYSongDownloadService *)aService didCompleteSongDownload:(id <PNYSongDownload>)aSongDownload;
- (void)songDownloadService:(PNYSongDownloadService *)aService didDeleteSongDownload:(NSNumber *)aSongId;

@end

@interface PNYSongDownloadService : NSObject

@property (nonatomic, strong) id <PNYRestService> restService;
@property (nonatomic, strong) id <PNYPersistentDictionary> persistentDictionary;

@property (nonatomic, copy) NSString *folderPathInDocuments;

- (void)addDelegate:(id <PNYSongDownloadServiceDelegate>)aDelegate;
- (void)removeDelegate:(id <PNYSongDownloadServiceDelegate>)aDelegate;

- (id <PNYSongDownload>)downloadForSong:(NSNumber *)aSongId;
- (NSArray *)allDownloads;

- (void)startDownloadForSong:(PNYSongDto *)aSong;
- (void)cancelDownloadForSong:(NSNumber *)aSongId;
- (void)deleteDownloadForSong:(NSNumber *)aSongId;

- (id <PNYSongDownloadProgress>)progressForSong:(NSNumber *)aSongId;
- (NSArray *)allProgresses;

@end