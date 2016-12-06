//
//  BETableView.m
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

#import "BETableView.h"
#import "Backendless.h"

@interface BETableView()<UITableViewDataSource>
{
    //Class _className;
    //BackendlessDataQuery *_dataQuery;
    //BackendlessGeoQuery *_geoQuery;
    NSArray *_collection;
    Responder *_responder;
    BOOL _needReloadData;
}
@property (nonatomic, strong) id<UITableViewDataSource> beTableViewDelegate;
@property (nonatomic, strong) NSMutableArray *data;
-(id)errorHandler:(Fault *)fault;
-(void)initProperties;
-(id)responseHandler:(id)response;
-(NSArray *)getIndexPathsForOffset:(NSUInteger)offset Count:(NSUInteger)count;
@end
@implementation BETableView
@synthesize data=_data;
-(void)dealloc
{
    [_collection release];
    [_beTableViewDelegate release];
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
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        
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
- (id)init
{
    self = [super init];
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
    [_collection release];
    _collection = [response retain];
    
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
        [self insertRowsAtIndexPaths:[self getIndexPathsForOffset:offset Count:count] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    return response;
}
-(id)errorHandler:(Fault *)fault
{
    return fault;
}

-(void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    if (dataSource == nil) {
        self.beTableViewDelegate = nil;
        [super setDataSource:nil];
        return;
    }
    if (dataSource != self) {
        self.beTableViewDelegate = dataSource;
    }
    [super setDataSource:self];
}

-(void)find:(Class)className dataQuery:(BackendlessDataQuery *)dataQuery
{
    _needReloadData = YES;
    //_className = [className copy];
    //_dataQuery = [dataQuery retain];
    _responder.chained = nil;
    NSArray *collection = [backendless.persistenceService find:className dataQuery:dataQuery];
    [self responseHandler:collection];
}
-(void)find:(Class)className dataQuery:(BackendlessDataQuery *)dataQuery responder:(id)responder
{
    _needReloadData = YES;
    //_className = [className copy];
    //_dataQuery = [dataQuery retain];
    _responder.chained = responder;
    [backendless.persistenceService find:className dataQuery:dataQuery responder:_responder];
}
-(void)find:(Class)className dataQuery:(BackendlessDataQuery *)dataQuery response:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock
{
    _needReloadData = YES;
    //_className = [className copy];
    //_dataQuery = [dataQuery retain];
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [backendless.persistenceService find:className dataQuery:dataQuery responder:_responder];
}


-(void)getPoints:(BackendlessGeoQuery *)query
{
    _needReloadData = YES;
    //_geoQuery = [query retain];
    _responder.chained = nil;
    NSArray *c = [backendless.geoService getPoints:query];
    [self responseHandler:c];
}
-(void)relativeFind:(BackendlessGeoQuery *)query
{
    _needReloadData = YES;
    //_geoQuery = [query retain];
    _responder.chained = nil;
    NSArray *c = [backendless.geoService relativeFind:query];
    [self responseHandler:c];
}
-(void)getPoints:(BackendlessGeoQuery *)query responder:(id)responder
{
    _needReloadData = YES;
    //_geoQuery = [query retain];
    _responder.chained = responder;
    [backendless.geoService getPoints:query responder:_responder];
}
-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id)responder
{
    _needReloadData = YES;
    //_geoQuery = [query retain];
    _responder.chained = responder;
    [backendless.geoService relativeFind:query responder:_responder];
}
-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock
{
    _needReloadData = YES;
    //_geoQuery = [query retain];
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [backendless.geoService getPoints:query responder:_responder];
}
-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock
{
    _needReloadData = YES;
    //_geoQuery = [query retain];
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [backendless.geoService relativeFind:query responder:_responder];
}

-(void)nextPage
{
    _needReloadData = NO;
    [_collection nextPage];
}
-(void)nextPageAsync:(id)responder
{
    _needReloadData = NO;
    _responder.chained = responder;
    [_collection nextPageAsync:_responder];
}
-(void)nextPageAsync:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock
{
    _needReloadData = NO;
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [_collection nextPageAsync:_responder];
}
-(id)getDataForIndexPath:(NSIndexPath *)indexPath
{
    return [_data objectAtIndex:indexPath.row];
}

-(void)removeAllObjects
{
    [_data removeAllObjects];
    [self reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)])
    {
        cell = [_beTableViewDelegate tableView:self cellForRowAtIndexPath:indexPath];
        if (cell) {
            return cell;
        }
    }
    static NSString *backendlessDefaultReusableCellIdentifier = @"BEDefaultCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:backendlessDefaultReusableCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:backendlessDefaultReusableCellIdentifier];
    }
    id cellData = [_data objectAtIndex:indexPath.row];
    if ([cellData isKindOfClass:[GeoPoint class]]) {
        GeoPoint *point = cellData;
        cell.textLabel.text = [NSString stringWithFormat:@"(%@, %@)", point.latitude, point.longitude];
    }
    else
    {
        BackendlessEntity *entity = cellData;
        cell.textLabel.text = entity.objectId;
    }
    return cell;
}


-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([_beTableViewDelegate respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
    {
        [_beTableViewDelegate sectionIndexTitlesForTableView:self];
    }
    return nil;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
    {
        return [_beTableViewDelegate tableView:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
    {
        return [_beTableViewDelegate tableView:self canMoveRowAtIndexPath:indexPath];
    }
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
    {
        [_beTableViewDelegate tableView:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
    {
        [_beTableViewDelegate tableView:self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)])
    {
        return [_beTableViewDelegate tableView:self sectionForSectionIndexTitle:title atIndex:index];
    }
    return 0;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:titleForFooterInSection:)])
    {
        return [_beTableViewDelegate tableView:self titleForFooterInSection:section];
    }
    return nil;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([_beTableViewDelegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
    {
        return [_beTableViewDelegate tableView:self titleForHeaderInSection:section];
    }
    return nil;
}

@end
