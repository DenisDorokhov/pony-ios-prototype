//
// Created by Denis Dorokhov on 25/10/15.
// Copyright (c) 2015 Denis Dorokhov. All rights reserved.
//

#import "PNYTestCase.h"
#import "PNYRestServiceImpl.h"
#import "PNYAlbumDto.h"
#import "PNYAlbumSongsDto.h"
#import "PNYSongDto.h"
#import "PNYTokenPairDaoMock.h"
#import "PNYFileUtils.h"

@interface PNYRestServiceTests : PNYTestCase
{
@private
    PNYRestServiceImpl *service;
}

@end

@implementation PNYRestServiceTests

static NSString *const DEMO_URL = @"http://pony.dorokhov.net/demo";
static NSString *const DEMO_EMAIL = @"foo@bar.com";
static NSString *const DEMO_PASSWORD = @"demo";

- (void)setUp
{
    [super setUp];

    id <PNYRestServiceUrlDao> urlDao = mockProtocol(@protocol(PNYRestServiceUrlDao));

    [given([urlDao fetchUrl]) willReturn:[NSURL URLWithString:DEMO_URL]];

    service = [PNYRestServiceImpl new];
    service.urlDao = urlDao;
    service.tokenPairDao = [PNYTokenPairDaoMock new];
}

- (void)testGetInstallation
{
    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block PNYInstallationDto *installation = nil;

    [service getInstallationWithSuccess:^(PNYInstallationDto *aInstallation) {

        [expectation fulfill];

        installation = aInstallation;

    }                           failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    assertThat(installation.version, notNilValue());
}

- (void)testAuthenticate
{
    [self assertDemoAuthentication:[self authenticateSynchronously]];
}

- (void)testLogout
{
    [self authenticateSynchronously];

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block PNYUserDto *user = nil;

    [service logoutWithSuccess:^(PNYUserDto *aUser) {

        [expectation fulfill];

        user = aUser;

    }                  failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    [self assertDemoUser:user];
}

- (void)testGetCurrentUser
{
    [self authenticateSynchronously];

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block PNYUserDto *user = nil;

    [service getCurrentUserWithSuccess:^(PNYUserDto *aUser) {

        [expectation fulfill];

        user = aUser;

    }                          failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    [self assertDemoUser:user];
}

- (void)testRefreshToken
{
    [self authenticateSynchronously];

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block PNYAuthenticationDto *authentication = nil;

    [service refreshTokenWithSuccess:^(PNYAuthenticationDto *aAuthentication) {

        [expectation fulfill];

        authentication = aAuthentication;

    }                        failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    [self assertDemoAuthentication:authentication];
}

- (void)testGetArtists
{
    NSArray *artists = [self authenticateAndGetArtistsSynchronously];

    assertThat(artists, isNot(isEmpty()));

    PNYArtistDto *artist = artists[0];

    [self assertArtist:artist];
}

- (void)testGetArtistAlbums
{
    PNYArtistAlbumsDto *artistAlbums = [self authenticateAndGetArtistAlbumsSynchronously];

    assertThat(artistAlbums.albums, isNot(isEmpty()));

    [self assertArtist:artistAlbums.artist];
    [self assertAlbumSongs:artistAlbums.albums[0]];
}

- (void)testGetSongs
{
    PNYArtistAlbumsDto *artistAlbums = [self authenticateAndGetArtistAlbumsSynchronously];

    assertThat(artistAlbums.albums, isNot(isEmpty()));

    PNYAlbumSongsDto *albumSongs = artistAlbums.albums[0];

    NSMutableArray *songIds = [NSMutableArray array];
    for (PNYSongDto *song in albumSongs.songs) {
        [songIds addObject:song.id];
    }

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block NSArray *songs = nil;

    [service getSongsWithIds:songIds success:^(NSArray *aSongs) {

        [expectation fulfill];

        songs = aSongs;

    }                failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    assertThat(songs, hasCountOf([songIds count]));

    for (PNYSongDto *song in songs) {
        [self assertSong:song];
    }
}

- (void)testGetImage
{
    NSArray *artists = [self authenticateAndGetArtistsSynchronously];

    assertThat(artists, isNot(isEmpty()));

    PNYArtistDto *artist = artists[0];

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block UIImage *image = nil;

    [service downloadImage:artist.artworkUrl success:^(UIImage *aImage) {

        [expectation fulfill];

        image = aImage;

    }              failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    assertThat(image, notNilValue());
}

- (void)testDownloadSong
{
    PNYArtistAlbumsDto *artistAlbums = [self authenticateAndGetArtistAlbumsSynchronously];

    assertThat(artistAlbums.albums, isNot(isEmpty()));

    PNYAlbumSongsDto *albumSongs = artistAlbums.albums[0];

    PNYSongDto *song = albumSongs.songs[0];

    NSString *filePath = [PNYFileUtils generateTemporaryFilePath];

    __block BOOL isProgressCalled = NO;

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    [service downloadSong:song.url toFile:filePath progress:^(float aValue) {
        isProgressCalled = YES;
    }             success:^{
        [expectation fulfill];
    }             failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    assertThatBool([[NSFileManager defaultManager] fileExistsAtPath:filePath], isTrue());

    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];

    assertThatUnsignedLongLong(fileSize, greaterThan(@0));

    assertThatBool(isProgressCalled, isTrue());
}

#pragma mark - Private

- (PNYArtistAlbumsDto *)authenticateAndGetArtistAlbumsSynchronously
{
    NSArray *artists = [self authenticateAndGetArtistsSynchronously];

    assertThat(artists, isNot(isEmpty()));

    PNYArtistDto *albumArtist = artists[0];

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block PNYArtistAlbumsDto *artistAlbums = nil;

    [service getArtistAlbumsWithArtist:albumArtist.name success:^(PNYArtistAlbumsDto *aArtistAlbums) {

        [expectation fulfill];

        artistAlbums = aArtistAlbums;

    }                          failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    return artistAlbums;
}

- (NSArray *)authenticateAndGetArtistsSynchronously
{
    [self authenticateSynchronously];

    XCTestExpectation *expectation = PNYTestExpectationCreate();

    __block NSArray *artists = nil;

    [service getArtistsWithSuccess:^(NSArray *aArtists) {

        [expectation fulfill];

        artists = aArtists;

    }                      failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    return artists;
}

- (PNYAuthenticationDto *)authenticateSynchronously
{
    XCTestExpectation *expectation = PNYTestExpectationCreate();

    PNYCredentialsDto *credentials = [PNYCredentialsDto new];

    credentials.email = DEMO_EMAIL;
    credentials.password = DEMO_PASSWORD;

    __block PNYAuthenticationDto *authentication = nil;

    [service authenticateWithCredentials:credentials success:^(PNYAuthenticationDto *aAuthentication) {

        [expectation fulfill];

        authentication = aAuthentication;

    }                            failure:^(NSArray *aErrors) {
        [self failExpectation:expectation withErrors:aErrors];
    }];

    PNYTestExpectationWait();

    PNYTokenPair *tokenPair = [PNYTokenPair new];

    tokenPair.accessToken = authentication.accessToken;
    tokenPair.accessTokenExpiration = authentication.accessTokenExpiration;

    tokenPair.refreshToken = authentication.refreshToken;
    tokenPair.refreshTokenExpiration = authentication.refreshTokenExpiration;

    [service.tokenPairDao storeTokenPair:tokenPair];

    return authentication;
}

- (void)failExpectation:(XCTestExpectation *)aExpectation withErrors:(NSArray *)aErrors
{
    [aExpectation fulfill];

    XCTFail(@"Failed with errors: %@.", aErrors);
}

- (void)assertDemoAuthentication:(PNYAuthenticationDto *)aAuthentication
{
    assertThat(aAuthentication.accessToken, notNilValue());
    assertThat(aAuthentication.accessTokenExpiration, notNilValue());
    assertThat(aAuthentication.refreshToken, notNilValue());
    assertThat(aAuthentication.refreshTokenExpiration, notNilValue());

    [self assertDemoUser:aAuthentication.user];
}

- (void)assertDemoUser:(PNYUserDto *)aUser
{
    assertThat(aUser.name, notNilValue());
    assertThat(aUser.email, equalTo(DEMO_EMAIL));
    assertThat(aUser.creationDate, notNilValue());
    assertThatInteger(aUser.role, equalToInteger(PNYRoleDtoUser));
}

- (void)assertArtist:(PNYArtistDto *)aArtist
{
    assertThat(aArtist.id, notNilValue());
    assertThat(aArtist.name, notNilValue());
    assertThat(aArtist.artwork, notNilValue());
    assertThat(aArtist.artworkUrl, notNilValue());
}

- (void)assertAlbum:(PNYAlbumDto *)aAlbum
{
    assertThat(aAlbum.id, notNilValue());
    assertThat(aAlbum.name, notNilValue());
    assertThat(aAlbum.year, notNilValue());
    assertThat(aAlbum.artwork, notNilValue());
    assertThat(aAlbum.artworkUrl, notNilValue());

    [self assertArtist:aAlbum.artist];
}

- (void)assertGenre:(PNYGenreDto *)aGenre
{
    assertThat(aGenre.id, notNilValue());
    assertThat(aGenre.name, notNilValue());
    assertThat(aGenre.artwork, notNilValue());
    assertThat(aGenre.artworkUrl, notNilValue());
}

- (void)assertSong:(PNYSongDto *)aSong
{
    // Disc number can be nil, so we skip it.

    assertThat(aSong.id, notNilValue());
    assertThat(aSong.url, notNilValue());
    assertThat(aSong.size, notNilValue());
    assertThat(aSong.duration, notNilValue());
    assertThat(aSong.trackNumber, notNilValue());
    assertThat(aSong.artistName, notNilValue());
    assertThat(aSong.name, notNilValue());

    [self assertAlbum:aSong.album];
    [self assertGenre:aSong.genre];
}

- (void)assertAlbumSongs:(PNYAlbumSongsDto *)aAlbumSongs
{
    [self assertAlbum:aAlbumSongs.album];

    assertThat(aAlbumSongs.songs, isNot(isEmpty()));

    [self assertSong:aAlbumSongs.songs[0]];
}

@end