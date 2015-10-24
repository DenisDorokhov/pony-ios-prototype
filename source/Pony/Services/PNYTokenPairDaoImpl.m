//
// Created by Denis Dorokhov on 24/10/15.
// Copyright (c) 2015 Denis Dorokhov. All rights reserved.
//

#import "PNYTokenPairDaoImpl.h"
#import "PNYMacros.h"

@implementation PNYTokenPairDaoImpl

static NSString *const KEY_TOKEN_PAIR = @"PNYTokenDataDaoImpl.tokenPair";

static NSString *const KEY_ACCESS_TOKEN = @"accessToken";
static NSString *const KEY_ACCESS_TOKEN_EXPIRATION = @"accessTokenExpiration";
static NSString *const KEY_REFRESH_TOKEN = @"refreshToken";
static NSString *const KEY_REFRESH_TOKEN_EXPIRATION = @"refreshTokenExpiration";

#pragma mark - <PNYSecurityStorage>

- (PNYTokenPair *)fetchTokenPair
{
    PNYAssert(self.persistentDictionary != nil);

    return [self fromDictionary:self.persistentDictionary.data[KEY_TOKEN_PAIR]];
}

- (void)storeTokenPair:(PNYTokenPair *)aTokenPair
{
    PNYAssert(aTokenPair != nil);
    PNYAssert(self.persistentDictionary != nil);

    self.persistentDictionary.data[KEY_TOKEN_PAIR] = [self toDictionary:aTokenPair];

    [self.persistentDictionary save];
}

- (void)removeTokenPair
{
    PNYAssert(self.persistentDictionary != nil);

    [self.persistentDictionary.data removeObjectForKey:KEY_TOKEN_PAIR];

    [self.persistentDictionary save];
}

#pragma mark - Private

- (NSDictionary *)toDictionary:(PNYTokenPair *)aTokenPair
{
    return @{
            KEY_ACCESS_TOKEN : aTokenPair.accessToken,
            KEY_ACCESS_TOKEN_EXPIRATION : @([aTokenPair.accessTokenExpiration timeIntervalSince1970]),
            KEY_REFRESH_TOKEN : aTokenPair.refreshToken,
            KEY_REFRESH_TOKEN_EXPIRATION : @([aTokenPair.refreshTokenExpiration timeIntervalSince1970]),
    };
}

- (PNYTokenPair *)fromDictionary:(NSDictionary *)aDictionary
{
    PNYTokenPair *tokenPair = nil;

    if (aDictionary != nil) {

        tokenPair = [[PNYTokenPair alloc] init];

        tokenPair.accessToken = aDictionary[KEY_ACCESS_TOKEN];
        tokenPair.accessTokenExpiration = [NSDate dateWithTimeIntervalSince1970:[aDictionary[KEY_ACCESS_TOKEN_EXPIRATION] doubleValue]];

        tokenPair.refreshToken = aDictionary[KEY_REFRESH_TOKEN];
        tokenPair.refreshTokenExpiration = [NSDate dateWithTimeIntervalSince1970:[aDictionary[KEY_REFRESH_TOKEN_EXPIRATION] doubleValue]];
    }

    return tokenPair;
}

@end