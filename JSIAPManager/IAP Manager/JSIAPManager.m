//
//  JSIAPManager.m
//  JSIAPManager
//
//  Created by Stone, Jordan Matthew (US - Denver) on 8/14/13.
//  Copyright (c) 2013 Jordan Stone. All rights reserved.
//

#import "JSIAPManager.h"
#import <StoreKit/StoreKit.h>

NSString * const kProductIdentifier1 = @"ProductID";
NSString * const kProductIdentifier2 = @"ProductID";
NSString * const kProductIdentifier3 = @"ProductID";

@interface JSIAPManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) SKPaymentQueue *paymentQueue;
@property (nonatomic, strong) NSArray *productIdentifiers;
@property (nonatomic, copy) void (^productsBlock)(NSArray *products);
@property (nonatomic, copy) void (^purchaseSuccessBlock)(BOOL success);
@property (nonatomic, copy) void (^purchaseFailureBlock)(NSError *error);
@property (nonatomic, copy) void (^restoreSuccessBlock)(BOOL success);
@property (nonatomic, strong) NSArray *products;

@end

@implementation JSIAPManager

+ (JSIAPManager *)sharedManager {
    static JSIAPManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JSIAPManager alloc] init];
    });
    
    return manager;
}

+ (BOOL)productPurchased:(NSString *)productIdentifier {
    return [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
}

+ (BOOL)purchasingEnabled {
    return [SKPaymentQueue canMakePayments];
}

- (id)init {
    self = [super init];
    if (self) {
        _productIdentifiers = @[kProductIdentifier1, kProductIdentifier2, kProductIdentifier3];
        
        if ([SKPaymentQueue canMakePayments]) {
            _paymentQueue = [SKPaymentQueue defaultQueue];
            [_paymentQueue addTransactionObserver:self];
        }
    }
    
    return self;
}

- (void)fetchProducts:(void (^)(NSArray *))products {
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:self.productIdentifiers]];
    
    [productsRequest setDelegate:self];
    
    [productsRequest start];
    
    if (products) {
        self.productsBlock = products;
    }
}

- (void)purchaseProduct:(SKProduct *)product onSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *))failure {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    if (success) {
        self.purchaseSuccessBlock = success;
    }
    
    if (failure) {
        self.purchaseFailureBlock = failure;
    }
    
    [self.paymentQueue addPayment:payment];
}

- (void)restorePurchases:(void (^)(BOOL))success failure:(void (^)(NSError *))failure {
    if (success) {
        self.restoreSuccessBlock = success;
    }
    
    [self.paymentQueue restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate Methods
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    
    if (self.productsBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.productsBlock(self.products);
        });
    }
}

- (void)requestDidFinish:(SKRequest *)request {
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Error Encountered" message:@"We were unable to connect to the App Store to make your purchase. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:transaction.payment.productIdentifier];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (self.purchaseSuccessBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.purchaseSuccessBlock(YES);
                    });
                }
                
                [self.paymentQueue finishTransaction:transaction];
                
                break;
            case SKPaymentTransactionStatePurchasing:
                
                break;
            case SKPaymentTransactionStateRestored:
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:transaction.originalTransaction.payment.productIdentifier];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.paymentQueue finishTransaction:transaction];
                
                break;
            case SKPaymentTransactionStateFailed:
                if (self.purchaseFailureBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.purchaseFailureBlock(transaction.error);
                    });
                }
                
                [self.paymentQueue finishTransaction:transaction];
                
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (self.restoreSuccessBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.restoreSuccessBlock(YES);
        });
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    
}

@end
