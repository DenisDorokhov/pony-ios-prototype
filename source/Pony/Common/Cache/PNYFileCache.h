//
// Created by Denis Dorokhov on 31/10/15.
// Copyright (c) 2015 Denis Dorokhov. All rights reserved.
//

#import "PNYCache.h"
#import "PNYCacheSerializer.h"

@interface PNYFileCache : NSObject <PNYCache>

@property (nonatomic, readonly) NSString *folderPath;
@property (nonatomic, readonly) id <PNYCacheSerializer> serializer;
@property (nonatomic) BOOL excludeFromBackup;

- (instancetype)initWithFolderPath:(NSString *)aFolderPath serializer:(id <PNYCacheSerializer>)aSerializer;
- (instancetype)initWithFolderPathInDocuments:(NSString *)aFolderPath serializer:(id <PNYCacheSerializer>)aSerializer;
- (instancetype)initWithFolderPathInCache:(NSString *)aFolderPath serializer:(id <PNYCacheSerializer>)aSerializer;

+ (instancetype)new __unavailable;
- (instancetype)init __unavailable;

@end