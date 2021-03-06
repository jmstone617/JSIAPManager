//
//  JSIAPManager.h
//  JSIAPManager
//
//  Created by Stone, Jordan Matthew (US - Denver) on 8/14/13.
//  Copyright (c) 2013 Jordan Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kProductIdentifier1;
extern NSString * const kProductIdentifier2;
extern NSString * const kProductIdentifier3;

@class SKProduct;

@interface JSIAPManager : NSObject

+ (JSIAPManager *)sharedManager;

+ (BOOL)productPurchased:(NSString *)productIdentifier;
+ (BOOL)purchasingEnabled;

- (void)fetchProducts:(void (^)(NSArray *products))products;
- (void)purchaseProduct:(SKProduct *)product onSuccess:(void (^)(BOOL success))success failure:(void (^)(NSError *error))failure;
- (void)restorePurchases:(void (^)(BOOL success))success failure:(void (^)(NSError *error))failure;

@end

