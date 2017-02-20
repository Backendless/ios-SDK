//
//  BECollectionView.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "BECollectionView.h"
#import "Backendless.h"

@interface BECollectionView() <UICollectionViewDataSource>
{
    //Class _className;
    //BackendlessDataQuery *_dataQuery;
    //BackendlessGeoQuery *_geoQuery;
    Responder *_responder;
    BOOL _needReloadData;
}
@property (nonatomic, strong) id<UICollectionViewDataSource> beCollectionViewDelegate;
@property (nonatomic, strong) NSMutableArray *data;
-(id)errorHandler:(Fault *)fault;
-(void)initProperties;
-(id)responseHandler:(id)response;
-(NSArray *)getIndexPathsForOffset:(NSUInteger)offset Count:(NSUInteger)count;
@end;

@implementation BECollectionView
@synthesize data=_data;
-(void)dealloc
{
    [_beCollectionViewDelegate release];
    //[_dataQuery release];
    //[_geoQuery release];
    self.delegate = nil;
    self.dataSource = nil;
    [_responder release];
    [_data release];
    [super dealloc];
}
-(void)initProperties
{
    _needReloadData = YES;
    self.dataSource = self;
    _responder = [[Responder responder:self selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(errorHandler:)] retain];
    _data = [NSMutableArray new];
}
- (id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initProperties];
    }
    return self;
}

-(NSArray *)getIndexPathsForOffset:(NSUInteger)offset Count:(NSUInteger)count
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSUInteger i=offset; i < offset + count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [result addObject:indexPath];
    }
    return result;
}
-(id)responseHandler:(NSArray *)response
{
    if (!_data) {
        _data = [NSMutableArray new];
    }
    if (_needReloadData) {
        [_data removeAllObjects];
        [_data addObjectsFromArray:response];
        [self reloadData];
    }
    else
    {
        NSInteger offset = _data.count;
        NSInteger count = response.count;
        [_data addObjectsFromArray:response];
        [self insertItemsAtIndexPaths:[self getIndexPathsForOffset:offset Count:count]];
    }
    
    return response;
}
-(id)errorHandler:(Fault *)fault
{
    return fault;
}

-(void)setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    if (dataSource == nil) {
        self.beCollectionViewDelegate = nil;
        [super setDataSource:nil];
        return;
    }
    if (dataSource != self) {
        self.beCollectionViewDelegate = dataSource;
    }
    [super setDataSource:self];
}

-(void)find:(Class)className queryBuilder:(DataQueryBuilder *)queryBuilder {
    _responder.chained = nil;
    NSArray *collection = [backendless.persistenceService find:className queryBuilder:queryBuilder];
    [self responseHandler:collection];
}



//-(void)find:(Class)className queryBuilder:(DataQueryBuilder *)queryBuilder responder:(id)responder {
//    _responder.chained = responder;
//    [backendless.persistenceService find:className queryBuilder:queryBuilder responder:_responder];
//}

-(void)find:(Class)className queryBuilder:(DataQueryBuilder *)queryBuilder response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService find:className queryBuilder:queryBuilder response:responseBlock error:errorBlock];
}

-(void)getPoints:(BackendlessGeoQuery *)query
{
    //_geoQuery = [query retain];
    _responder.chained = nil;
    NSArray *c = [backendless.geoService getPoints:query];
    [self responseHandler:c];
}
-(void)relativeFind:(BackendlessGeoQuery *)query
{
    //_geoQuery = [query retain];
    _responder.chained = nil;
    NSArray *c = [backendless.geoService relativeFind:query];
    [self responseHandler:c];
}
-(void)getPoints:(BackendlessGeoQuery *)query responder:(id)responder
{
    //_geoQuery = [query retain];
    _responder.chained = responder;
    [backendless.geoService getPoints:query responder:_responder];
}
-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id)responder
{
    //_geoQuery = [query retain];
    _responder.chained = responder;
    [backendless.geoService relativeFind:query responder:_responder];
}
-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock
{
    //_geoQuery = [query retain];
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [backendless.geoService getPoints:query responder:_responder];
}
-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock
{
    //_geoQuery = [query retain];
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [backendless.geoService relativeFind:query responder:_responder];
}

-(id)getDataForIndexPath:(NSIndexPath *)indexPath
{
    return [_data objectAtIndex:indexPath.row];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_beCollectionViewDelegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)])
    {
        UICollectionViewCell *cell = [_beCollectionViewDelegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            return cell;
        }
    }
    return nil;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (![_beCollectionViewDelegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)])
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"collectionView:cellForItemAtIndexPath: not found" delegate:nil cancelButtonTitle:@"done" otherButtonTitles:nil] show];
        return 0;
    }
    return _data.count;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([_beCollectionViewDelegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)])
    {
        return [_beCollectionViewDelegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    return nil;
}
@end
