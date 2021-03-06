//
// Created by Denis Dorokhov on 16/01/16.
// Copyright (c) 2016 Denis Dorokhov. All rights reserved.
//

#import "PNYSongDownloadCell.h"
#import "PNYMacros.h"
#import "PNYDtoUtils.h"

@implementation PNYSongDownloadCell

- (void)dealloc
{
    [self.songDownloadService removeDelegate:self];
}

#pragma mark - Public

- (void)setSongDownloadService:(PNYSongDownloadService *)aSongDownloadService
{
    [_songDownloadService removeDelegate:self];

    _songDownloadService = aSongDownloadService;

    [_songDownloadService addDelegate:self];
}

- (void)setSong:(PNYSongDto *)aSong
{
    _song = aSong;

    self.artworkDownloadView.imageUrl = self.song.album.artworkUrl;

    NSString *artistName = self.song.album.artist.name != nil ? self.song.album.artist.name : PNYLocalized(@"common_unknownArtist");
    NSString *albumName = self.song.album.name != nil ? self.song.album.name : PNYLocalized(@"common_unknownAlbum");
    NSString *songName = self.song.name != nil ? self.song.name : PNYLocalized(@"common_unknownSong");

    if (self.song.album.year != nil) {
        self.songHeaderLabel.text = PNYLocalized(@"downloadManager_songHeader",
                artistName, albumName, self.song.album.year);
    } else {
        self.songHeaderLabel.text = PNYLocalized(@"downloadManager_songHeaderWithoutYear",
                artistName, albumName);
    }

    if (self.song.trackNumber != nil) {
        self.songTitleLabel.text = PNYLocalized(@"downloadManager_songTitle",
                self.song.trackNumber, songName, [PNYDtoUtils formatDurationFromSeconds:self.song.duration.doubleValue]);
    } else {
        self.songTitleLabel.text = PNYLocalized(@"downloadManager_songTitleWithoutTrackNumber",
                songName, [PNYDtoUtils formatDurationFromSeconds:self.song.duration.doubleValue]);
    }

    self.downloadProgressView.progress = [self.songDownloadService progressForSong:_song.id].value;
}

#pragma mark - <PNYSongDownloadServiceDelegate>

- (void)songDownloadService:(PNYSongDownloadService *)aService didProgressSongDownload:(id <PNYSongDownloadProgress>)aProgress
{
    if ([aProgress.song.id isEqualToNumber:self.song.id]) {
        self.downloadProgressView.progress = aProgress.value;
    }
}

@end