//
//  FileInfo.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 8/13/15.
//  Copyright (c) 2015 BACKENDLESS.COM. All rights reserved.
//

#import "BEFileInfo.h"

@implementation BEFileInfo

-(NSString *)description {
    return [NSString stringWithFormat:@"<BEFileInfo> -> URL: %@, name: %@, publicUrl: %@, publisher: %@, createdOn: %@ ", _URL, _name, _publicUrl, _publisher, _createdOn];
}

@end
