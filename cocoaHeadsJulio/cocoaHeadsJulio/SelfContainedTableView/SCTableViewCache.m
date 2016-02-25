//
//  SCTableViewCache.m
//  AnuncieSDK
//
//  Created by Julio Fernandes on 07/12/15.
//  Copyright © 2015 Zap Imóveis. All rights reserved.
//

#import "SCTableViewCache.h"

@implementation SCTableViewCache{
    NSMutableDictionary *items;
}

static SCTableViewCache *_cache = nil;

+(id) shared{
    if(!_cache){
        _cache = [[SCTableViewCache alloc] init];
    }
    return _cache;
}

- (id)init{
    self = [super init];
    if (self) {
        items = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearCache)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

-(void) clearCache{
    [items removeAllObjects];
}

-(id) loadNib:(NSString*) path owner:(id) owner{
    if(!path) return nil;
    
    UINib *cached = nil;
    @synchronized(items){
        cached = [items objectForKey:path];
    }
    
    if(cached){
        return [cached instantiateWithOwner:owner options:nil];
    } else {
        UINib *newNib = [UINib nibWithNibName:path bundle:[NSBundle bundleWithIdentifier:@"br.com.zap.AnuncieSDK"]];
        @synchronized(items){
            [items setValue:newNib forKey:path];
        }
        
        return [newNib instantiateWithOwner:owner options:nil];
    }
}

@end