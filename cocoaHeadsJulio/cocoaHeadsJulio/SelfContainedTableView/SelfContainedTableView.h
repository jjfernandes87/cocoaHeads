//
//  SelfContainedTableView.h
//  AnuncieSDK
//
//  Created by Julio Fernandes on 07/12/15.
//  Copyright © 2015 Zap Imóveis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewCache.h"

@class SelfContainedTableView;
@class SCTCellController;
@class SCTCellView;
@class SCTSectionController;
@class SCTSectionView;

typedef enum {
    SelfContainedTableViewModeSingleSection,
    SelfContainedTableViewModeMultipleSections
}SelfContainedTableViewMode;

#pragma mark - SelfContainedTableView

@protocol SelfContainedTableViewDelegate <NSObject>

@optional
-(void) selfContainedTableView:(SelfContainedTableView*) table didSelectRow:(SCTCellController*) row atSection:(SCTSectionController*) section;
-(void) selfContainedTableView:(SelfContainedTableView*) table didSelectRowAtIndexPath:(NSIndexPath*) indexPath;
-(void) selfContainedTableView:(SelfContainedTableView*) table scrollView:(UIScrollView *) scrollView didChangeScrollOffset:(CGPoint) newOffset;
-(void) selfContainedTableView:(SelfContainedTableView*) table scrollView:(UIScrollView *) scrollView didDraggedToPosition:(CGPoint) newOffset;
-(void) selfContainedTableView:(SelfContainedTableView*) table willBeginDragging:(CGPoint) offset;
-(void) selfContainedTableView:(SelfContainedTableView*) table didPullToRefresh:(BOOL) refresh;
-(void) selfContainedTableView:(SelfContainedTableView*) table didEndDisplayingCell:(SCTCellController *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
-(void) selfContainedTableView:(SelfContainedTableView*) table willDisplayCell:(SCTCellController *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SelfContainedTableView : UITableView <UITableViewDataSource,UITableViewDelegate>{
    NSArray *_sections;
    BOOL realod;
}

// array of Indexes
@property (nonatomic, readwrite, retain) NSArray *indexTitles;

// based on indexes list
@property (nonatomic) BOOL indexes;

// array of SCTSectionController and SCTCellControllers. if you assign 'sectionsAndRows', then 'rows' will be discarted
@property (nonatomic, readwrite, retain) NSArray *sectionsAndRows;

// array of SCTCellControllers. if you assign 'rows', then 'rowsAndSections' will be discarted
@property (nonatomic, readwrite, retain) NSArray *rows;

// based on 'rowsAndSections' and 'rows'
@property (readonly) SelfContainedTableViewMode mode;

// delegate that will be called when a row is selected
@property (nonatomic, assign) IBOutlet id<SelfContainedTableViewDelegate> sctDelegate;

// rows manipulation
-(void) setSectionsAndRows:(NSArray *)sectionsAndRows reload:(BOOL) reloadTable;
-(void) insertRowsOnTop:(NSArray*) rows animation:(UITableViewRowAnimation) animation;
-(void) insertRows:(NSArray*) rows at:(int) position animation:(UITableViewRowAnimation) animation;
-(void) removeAt:(int) position rowsCount:(int) count animation:(UITableViewRowAnimation) animation;

// selection
-(void) markCellAsSelected:(SCTCellController*) cell;
-(NSIndexPath*) indexPathForCellController:(SCTCellController*) cell;

@end

#pragma mark - SCTCellController

@interface SCTCellController : NSObject

@property (nonatomic, assign) IBOutlet SCTCellView *controllerCell;
@property (nonatomic, assign) UITableView *tableview;

// controle de persistencia
@property (nonatomic, readonly) BOOL persistentCell;
@property (nonatomic, retain) SCTCellView *cachedCell;
@property (nonatomic, readwrite) int tag;
@property (nonatomic, assign) NSString* identifier;
@property (nonatomic, readwrite, assign) id currentObject;

// se a view for persistente, o método loadDefaultCellForTable será chamado só uma vez
// já heightForRowAtIndexPath continua a ser chamado a cada reload
-(id) initWithPersistentCell:(BOOL) shouldPersistCell;

// recarrega novamente o cell desse controller
-(void) reloadMe:(UITableViewRowAnimation) animation;

// must overwrite
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectThisCellAtIndexPath:(NSIndexPath *)indexPath;

// optional, by default returns the class name
- (NSString*) reuseIdentifier;

// load a cell whose xib have the same name as her class
-(id) loadDefaultCellForTable:(UITableView*) tableView atIndexPath:(NSIndexPath*) indexPath;

@end

#pragma mark - SCTCellView

@interface SCTCellView : UITableViewCell

@property (nonatomic, assign) IBOutlet SCTCellController *controller;
@property (nonatomic, assign) IBOutlet UIView *backgroundCell;
@property (nonatomic, retain) NSString *loadedKey;
@property (nonatomic) BOOL beingPersisted;

@end

#pragma mark - SCTSectionController

@interface SCTSectionController : NSObject

// array of SCTCellControllers, auto-created by tableview
@property (nonatomic, readonly) NSArray *rows;

@property (nonatomic, assign) IBOutlet SCTSectionView *controllerSection;
@property (nonatomic, assign) UITableView *tableview;

- (NSString*) customNibName;
- (void) reloadMe;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (SCTSectionView*) loadDefaultHeaderForTableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

@end

#pragma mark - SCTSectionView

@interface SCTSectionView : UIView

@property (nonatomic, assign) IBOutlet SCTSectionController *controller;

@end