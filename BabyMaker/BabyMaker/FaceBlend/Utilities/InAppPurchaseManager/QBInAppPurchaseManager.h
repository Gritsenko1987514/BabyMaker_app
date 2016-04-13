//
//  QBInAppPurchaseManager.h
//  
//
//  Created by Qburst on 07/09/12.
//  Copyright 2012 __QBurst__. All rights reserved.//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>

@protocol QBInAppPurchaseDelegate;

@interface QBInAppPurchaseManager : UIViewController<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic, retain) NSSet *productIdentifiers;
// Array of valid SKProducts returned from store
@property (nonatomic, retain) NSMutableArray *validProducts;

// Array of invalid SKProducts returned from store
@property (nonatomic, retain) NSMutableArray *invalidProductIdentifiers;

// The product which has to be purchased. This field is set before starting transaction
@property (nonatomic,retain) SKProduct *productToBePurchased;
@property (nonatomic,retain) Reachability *reachability;

@property (nonatomic,assign) id <QBInAppPurchaseDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *inappContentTitle;
@property (strong, nonatomic) IBOutlet UILabel *inappContentLabel;
@property (strong, nonatomic) IBOutlet UILabel *inappContentLabel2;
@property (strong, nonatomic) IBOutlet UIView *inappPrompt;
@property (nonatomic) BOOL moreAppPage;

+ (BOOL)canMakePayements;
- (void)requestProductData;
- (BOOL)validateProductWithIdentifier:(NSString *)productIdentifier;
- (BOOL)makePaymentForProductWithIdentifier:(NSString *)productIdentifier forQuantity:(int)quantity;
- (BOOL)makePaymentForProductWithIdentifier:(NSString *)productIdentifier;
- (SKProduct *)selectValidProductsWithIdentifier:(NSString *)productIdentifier;
- (void)completeTransaction: (SKPaymentTransaction *)transaction;
- (void)restoreTransaction: (SKPaymentTransaction *)transaction;
- (void)failedTransaction: (SKPaymentTransaction *)transaction;
- (void)purchasingTransaction: (SKPaymentTransaction *)transaction;
- (void)recordTransaction: (SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
- (IBAction)closeInAppPrompt:(id)sender;
- (IBAction)buyNow:(id)sender;
- (IBAction)restorePurchase:(id)sender;

@end

@protocol QBInAppPurchaseDelegate

@required
- (void)productRequestCompleted;

@optional

- (void)recordTransaction: (SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;
- (void)userCancelledPurchase;
- (void)failedTransaction: (SKPaymentTransaction *)transaction;
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;
- (void)purchaseCompletedSuccessfully;
- (void)removedInappPrompt;

@end