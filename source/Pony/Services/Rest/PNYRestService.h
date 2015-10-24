//
// Created by Denis Dorokhov on 24/10/15.
// Copyright (c) 2015 Denis Dorokhov. All rights reserved.
//

#import "PNYRestRequest.h"
#import "PNYCredentialsDto.h"
#import "PNYAuthenticationDto.h"
#import "PNYArtistAlbumsDto.h"
#import "PNYInstallationDto.h"

typedef void (^PNYRestServiceFailureBlock)(NSArray *aErrors);

@protocol PNYRestService <NSObject>

- (id <PNYRestRequest>)getInstallationWithSuccess:(void (^)(PNYInstallationDto *aInstallation))aSuccess
                            failure:(PNYRestServiceFailureBlock)aFailure;

- (id <PNYRestRequest>)authenticate:(PNYCredentialsDto *)aCredentials
                            success:(void (^)(PNYAuthenticationDto *aAuthentication))aSuccess
                            failure:(PNYRestServiceFailureBlock)aFailure;

- (id <PNYRestRequest>)logoutWithSuccess:(void (^)(PNYUserDto *aUser))aSuccess
                                 failure:(PNYRestServiceFailureBlock)aFailure;

- (id <PNYRestRequest>)getCurrentUserWithSuccess:(void (^)(PNYUserDto *aUser))aSuccess
                                         failure:(PNYRestServiceFailureBlock)aFailure;

- (id <PNYRestRequest>)refreshWithSuccess:(void (^)(PNYAuthenticationDto *aAuthentication))aSuccess
                                  failure:(PNYRestServiceFailureBlock)aFailure;


- (id <PNYRestRequest>)getArtistsWithSuccess:(void (^)(NSArray *aArtists))aSuccess
                                     failure:(PNYRestServiceFailureBlock)aFailure;

- (id <PNYRestRequest>)getArtistAlbums:(NSString *)aArtistIdOrName
                               success:(void (^)(PNYArtistAlbumsDto *aArtistAlbums))aSuccess
                               failure:(PNYRestServiceFailureBlock)aFailure;

@end