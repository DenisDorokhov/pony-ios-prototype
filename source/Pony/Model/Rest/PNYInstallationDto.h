//
// Created by Denis Dorokhov on 24/10/15.
// Copyright (c) 2015 Denis Dorokhov. All rights reserved.
//

#import <EasyMapping/EKMappingProtocol.h>

@interface PNYInstallationDto : NSObject <EKMappingProtocol>

@property (nonatomic, strong) NSString *version;

@end