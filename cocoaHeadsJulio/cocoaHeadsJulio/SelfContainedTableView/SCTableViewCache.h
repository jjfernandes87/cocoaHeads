//
//  SCTableViewCache.h
//  AnuncieSDK
//
//  Created by Julio Fernandes on 07/12/15.
//  Copyright © 2015 Zap Imóveis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SCTableViewCache : NSObject

+(id) shared;
-(id) loadNib:(NSString*) path owner:(id) owner;
-(void) clearCache;

@end
