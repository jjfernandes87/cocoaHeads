//
//  SelfContainedTableView.m
//  AnuncieSDK
//
//  Created by Julio Fernandes on 07/12/15.
//  Copyright © 2015 Zap Imóveis. All rights reserved.
//

#import "SelfContainedTableView.h"
#import <QuartzCore/QuartzCore.h>

//////////////////////////////////////////  PRIVATES

@interface SelfContainedTableView (private)

-(void) bootstrap;
-(SCTCellController*) findControllerAtIndexPath:(NSIndexPath*) path;

@end

@interface SCTSectionController (private)

-(void) setRows:(NSArray*) newRows;

@end

//////////////////////////////////////////  SelfContainedTableView

@implementation SelfContainedTableView


-(void) reloadData{
    [super reloadData];
}

-(void) dealloc{
    [_rows release], _rows = nil;
    [_sectionsAndRows release], _sectionsAndRows = nil;
    [_indexTitles release], _indexTitles = nil;
    [_sections release], _sections = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self bootstrap];
    }
    return self;
}

-(void) awakeFromNib{
    [self bootstrap];
}

-(void) bootstrap{
    [super setDelegate:self];
    [super setDataSource:self];
    [_rows release], _rows = nil;
    _rows = [[NSMutableArray alloc] init];
}

#pragma mark - persistent support

-(id) dequeueReusableCellWithIdentifier:(NSString *)identifier{
    SCTCellView *cell = [super dequeueReusableCellWithIdentifier:identifier];
    if(cell.beingPersisted) return nil;
    return cell;
}

#pragma mark - properties

-(void) setDelegate:(id<UITableViewDelegate>)delegate{
    if(delegate){
        [[NSException exceptionWithName:@"SelfContainedTableView Error"
                                 reason:@"You can't assing a delegate to a self contained table"
                               userInfo:nil] raise];
    }else [super setDelegate:delegate];
}

-(void) setDataSource:(id<UITableViewDataSource>)dataSource{
    if(dataSource){
        [[NSException exceptionWithName:@"SelfContainedTableView Error"
                                 reason:@"You can't assing a datasource to a self contained table"
                               userInfo:nil] raise];
    }else [super setDataSource:dataSource];
}

-(void) setRows:(NSArray *)rows{
    [_sectionsAndRows release], _sectionsAndRows = nil;
    [_rows release], _rows = nil;
    _rows = [rows retain];
    _mode = SelfContainedTableViewModeSingleSection;
    [self reloadData];
}

-(void) setSectionsAndRows:(NSArray *)sectionsAndRows{
    [self setSectionsAndRows:sectionsAndRows reload:YES];
}

-(void) setSectionsAndRows:(NSArray *)sectionsAndRows reload:(BOOL) reloadTable{
    
    // check for sections
    BOOL haveSections = NO;
    for (NSObject *item in sectionsAndRows) {
        if([item isKindOfClass:[SCTSectionController class]]){
            haveSections = YES;
            break;
        }
    }
    if(!haveSections) {
        [self setRows:sectionsAndRows];
        return;
    }
    
    // compose ROWS
    NSMutableArray *rows            = [NSMutableArray array];
    NSMutableArray *newSections     = [NSMutableArray array];
    NSMutableArray *cleanSecAndRows = [NSMutableArray array];
    SCTSectionController *currentSection = nil;
    
    NSInteger max = sectionsAndRows.count;
    for (int i = 0; i < max; i++) {
        NSObject *item = [sectionsAndRows objectAtIndex:i];
        
        if([item isKindOfClass:[SCTCellController class]]){
            [rows addObject:item];
        }
        
        if([item isKindOfClass:[SCTSectionController class]] || i+1 == max){
            
            if(currentSection){
                if(!rows) NSLog(@"Attempting to create a Section without rows!");
                else {
                    [currentSection setRows:rows];
                    [cleanSecAndRows addObjectsFromArray:rows];
                    [newSections addObject:currentSection];
                }
            }
            
            if([item isKindOfClass:[SCTSectionController class]]){
                rows = [NSMutableArray array];
                currentSection = (SCTSectionController*)item;
                [cleanSecAndRows addObject:currentSection ];
            }
        }
    }
    
    // assigns
    [_rows release], _rows = nil;
    
    [_sectionsAndRows release], _sectionsAndRows = nil;
    _sectionsAndRows = [cleanSecAndRows retain];
    
    [_sections release];
    _sections = [[NSArray alloc] initWithArray:newSections];
    
    _mode = SelfContainedTableViewModeMultipleSections;
    
    if(reloadTable) [self reloadData];
}

#pragma mark - scrolling stuff

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.scrollEnabled) [super touchesMoved:touches withEvent:event];
}

#pragma mark - rows manipulation

-(void) setContentOffset:(CGPoint)contentOffset{
    [super setContentOffset:contentOffset];
}

-(void) markCellAsSelected:(SCTCellController*) cell{
    NSIndexPath *path  = [self indexPathForCellController:cell];
    [self selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(void) removeAt:(int) position rowsCount:(int) count animation:(UITableViewRowAnimation) animation{
    
    NSMutableArray *paths   = [NSMutableArray array];
    NSMutableArray *allRows = [NSMutableArray arrayWithArray:self.rows];
    NSMutableArray *discardRows = [NSMutableArray array];
    
    for (int i = position; i < position+count; i++) {
        SCTCellController *cellController = [self.rows objectAtIndex:i];
        [discardRows addObject:cellController];
        
        NSIndexPath *path = [self indexPathForCellController:cellController];
        [paths addObject:path];
    }
    
    
    [allRows removeObjectsInArray:discardRows];
    [_rows release], _rows = nil;
    _rows = [allRows retain];
    
    [self deleteRowsAtIndexPaths:paths withRowAnimation:animation];
    
}

-(void) insertRowsOnTop:(NSArray*) rows animation:(UITableViewRowAnimation) animation{
    [self insertRows:rows at:0 animation:animation];
}

-(void) insertRows:(NSArray*) rows at:(int) position animation:(UITableViewRowAnimation) animation{
    
    NSMutableArray *paths   = [NSMutableArray array];
    NSMutableArray *allRows = [NSMutableArray arrayWithArray:self.rows];
    NSMutableArray *newRows = [NSMutableArray array];
    
    // add objects inside new rows array
    for (NSInteger i = rows.count-1; i >= 0; i--) {
        
        SCTCellController *cellController = [rows objectAtIndex:i];
        
        if([cellController isKindOfClass:[SCTCellController class]]){
            [allRows insertObject:cellController atIndex:position];
            [newRows addObject:cellController];
        }
    }
    
    [_rows release];
    _rows = [allRows retain];
    
    // get index paths
    for (int i = 0; i < newRows.count; i++) {
        SCTCellController *cellController = [newRows objectAtIndex:i];
        NSIndexPath *path = [self indexPathForCellController:cellController];
        [paths addObject:path];
    }
    
    CGPoint originalOffset = self.contentOffset;
    
    if(originalOffset.y != 0) {
        [self reloadData];
        [self setContentOffset:CGPointMake(originalOffset.x, originalOffset.y) animated:NO];
    } else if(animation != UITableViewRowAnimationNone){
        [self insertRowsAtIndexPaths:paths withRowAnimation:animation];
    } else {
        [self reloadData];
    }
    
}

#pragma mark - tableview delegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(!_sections.count) return 0;
    SCTSectionController *controller = [_sections objectAtIndex:section];
    return [controller tableView:tableView heightForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(!_sections.count) return nil;
    SCTSectionController *controller = [_sections objectAtIndex:section];
    controller.tableview = tableView;
    return [controller tableView:tableView viewForHeaderInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.mode == SelfContainedTableViewModeSingleSection){
        return 1;
    }else if(self.mode == SelfContainedTableViewModeMultipleSections){
        return _sections.count ? _sections.count : 1;
    }else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.mode == SelfContainedTableViewModeSingleSection){
        return self.rows.count;
    }else if(self.mode == SelfContainedTableViewModeMultipleSections){
        if(!_sections.count) return 0;
        SCTSectionController *controller = [_sections objectAtIndex:section];
        return controller.rows.count;
    } else {
        return 0;
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if (!_indexes) return @[];
    
    if(self.mode == SelfContainedTableViewModeMultipleSections){
        if(!_sections.count) return @[];
        
        NSMutableArray *tempIndexes = [NSMutableArray array];
        
        for (NSInteger i = 0, max = [_sections count]; i < max; i++) {
            SCTSectionController *controller = [_sections objectAtIndex:i];
            controller.tableview = tableView;
            [tempIndexes addObject:[controller tableView:tableView titleForHeaderInSection:i]];
        }
        
        [_indexTitles release], _indexTitles = nil;
        _indexTitles = [tempIndexes retain];
        
        return _indexTitles;
    } else {
        return @[];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SCTCellController *controller = [self findControllerAtIndexPath:indexPath];
    controller.tableview = tableView;
    if(controller.persistentCell && controller.cachedCell) return controller.cachedCell;
    else return [controller tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SCTCellController *controller = [self findControllerAtIndexPath:indexPath];
    return [controller tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SCTCellController *controller = [self findControllerAtIndexPath:indexPath];
    [controller retain];
    
    // call the delegate,if available
    if([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:didSelectRow:atSection:)]){
        if(self.mode == SelfContainedTableViewModeSingleSection){
            [self.sctDelegate selfContainedTableView:self didSelectRow:controller atSection:nil];
        }else if(self.mode == SelfContainedTableViewModeMultipleSections){
            SCTSectionController *sectionController = [self.sectionsAndRows objectAtIndex:indexPath.section];
            [self.sctDelegate selfContainedTableView:self didSelectRow:controller atSection:sectionController];
        }
    }
    
    if([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:didSelectRowAtIndexPath:)]){
        [self.sctDelegate selfContainedTableView:self didSelectRowAtIndexPath:indexPath];
    }
    
    return [[controller autorelease] tableView:tableView didSelectThisCellAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        SCTCellController *controller = [self findControllerAtIndexPath:indexPath];
        [self.sctDelegate selfContainedTableView:self didEndDisplayingCell:controller forRowAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:willDisplayCell:forRowAtIndexPath:)]) {
        SCTCellController *controller = [self findControllerAtIndexPath:indexPath];
        [self.sctDelegate selfContainedTableView:self willDisplayCell:controller forRowAtIndexPath:indexPath];
    }
}

-(SCTCellController*) findControllerAtIndexPath:(NSIndexPath*) indexPath{
    SCTCellController *controller = nil;
    if(self.mode == SelfContainedTableViewModeSingleSection){
        if ([self.rows count] > indexPath.row) {
            controller = [self.rows objectAtIndex:indexPath.row];
        }
    } else {
        SCTSectionController *section = [_sections objectAtIndex:indexPath.section];
        controller = [section.rows objectAtIndex:indexPath.row];
    }
    return controller;
}

-(NSIndexPath*) indexPathForCellController:(SCTCellController*) cell{
    
    if(self.mode == SelfContainedTableViewModeMultipleSections){
        NSInteger maxSections = _sections.count;
        for (NSInteger i = 0; i < maxSections; i++) {
            SCTSectionController *aSection = [_sections objectAtIndex:i];
            NSInteger maxRows = aSection.rows.count;
            for (NSInteger j = 0; j < maxRows; j++) {
                SCTCellController *aCell = [aSection.rows objectAtIndex:j];
                if(aCell == cell){
                    return [NSIndexPath indexPathForRow:j inSection:i];
                }
            }
        }
    } else {
        NSInteger maxRows = self.rows.count;
        for (NSInteger j = 0; j < maxRows; j++) {
            SCTCellController *aCell = [self.rows objectAtIndex:j];
            if(aCell == cell){
                return [NSIndexPath indexPathForRow:j inSection:0];
            }
        }
    }
    
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:scrollView:didChangeScrollOffset:)]){
        [self.sctDelegate selfContainedTableView:self scrollView:scrollView didChangeScrollOffset:self.contentOffset];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    realod = NO;
    if (decelerate) {
        if ([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:scrollView:didDraggedToPosition:)]){
            [self.sctDelegate selfContainedTableView:self scrollView:scrollView didDraggedToPosition:scrollView.contentOffset];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:willBeginDragging:)]){
        [self.sctDelegate selfContainedTableView:self willBeginDragging:scrollView.contentOffset];
    }
    
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([self.sctDelegate respondsToSelector:@selector(selfContainedTableView:scrollView:didDraggedToPosition:)]){
        [self.sctDelegate selfContainedTableView:self scrollView:scrollView didDraggedToPosition:scrollView.contentOffset];
    }
}


@end

/*  SCTCellController */

@implementation SCTCellController

-(id) initWithPersistentCell:(BOOL)shouldPersistCell{
    self = [super init];
    if (self) {
        _persistentCell = shouldPersistCell;
    }
    return self;
}

-(void) reloadMe:(UITableViewRowAnimation) animation{
    NSIndexPath *thisIP = [(SelfContainedTableView*)self.tableview indexPathForCellController:self];
    if(thisIP){
        [self.tableview reloadRowsAtIndexPaths:@[thisIP] withRowAnimation:animation];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self loadDefaultCellForTable:tableView atIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectThisCellAtIndexPath:(NSIndexPath *)indexPath{
    //nop
}

- (NSString*) reuseIdentifier{
    if ([self.identifier isEqualToString:@""] || !self.identifier) {
        return [NSStringFromClass([self class]) componentsSeparatedByString:@"."].lastObject;
    }
    
    return self.identifier;
}

-(id) loadDefaultCellForTable:(UITableView*) tableView atIndexPath:(NSIndexPath*) indexPath{
    SCTCellView *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if(!cell){
        [[SCTableViewCache shared] loadNib:[self reuseIdentifier]
                                     owner:self];
        cell = (SCTCellView*) self.controllerCell;
        self.controllerCell = nil;
    }
    
    // persiste a celula para reutilizar nas próximas chamadas
    if(self.persistentCell) {
        cell.beingPersisted = YES;
        self.cachedCell = cell;
    }
    
    cell.controller = self;
    return cell;
}

-(void) dealloc{
    self.tableview = nil;
    self.controllerCell = nil;
    self.cachedCell = nil;
    [super dealloc];
}

@end

/* SCTCellView */

@implementation SCTCellView

-(void) dealloc{
    self.controller = nil;
    self.loadedKey = nil;
    [super dealloc];
}

@end

#pragma mark - SCTSectionController

@implementation SCTSectionController

-(void) dealloc{
    [_rows release], _rows = nil;
    self.controllerSection = nil;
    self.tableview = nil;
    [super dealloc];
}

-(void) setRows:(NSArray *)newRows{
    [_rows release], _rows = nil;
    _rows = [newRows retain];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self loadDefaultHeaderForTableView:tableView viewForHeaderInSection:section];
}

- (NSString*) customNibName{
    return [NSStringFromClass([self class]) componentsSeparatedByString:@"."].lastObject;
}

- (SCTSectionView*) loadDefaultHeaderForTableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *xibName = [self customNibName];
    [[SCTableViewCache shared] loadNib:xibName owner:self];
    SCTSectionView *sectionView = (SCTSectionView*) self.controllerSection;
    sectionView.controller = self;
    return sectionView;
}

- (void) reloadMe{
    [self.tableview reloadData];
}

@end

#pragma mark - SCTSectionView

@implementation SCTSectionView

-(void) dealloc{
    self.controller = nil;
    [super dealloc];
}

@end