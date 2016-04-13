//
//  QBInAppPurchaseManager.m
//  GoFish
//
//  Created by user on 07/09/12.
//
//

#import "QBInAppPurchaseManager.h"
#import "Reachability.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "FBAppDelegate.h"

@implementation QBInAppPurchaseManager

@synthesize productIdentifiers = _productIdentifiers;
@synthesize validProducts = _validProducts;
@synthesize invalidProductIdentifiers = _invalidProducts;
@synthesize productToBePurchased = _productToBePurchased;
@synthesize delegate = _delegate;
@synthesize reachability = _reachability;
@synthesize moreAppPage = _moreAppPage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // restarts any purchases if they were interrupted last time the app was open
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)viewDidLoad
{
    self.reachability = [Reachability reachabilityForInternetConnection];

    if (self.moreAppPage)
    {
//        for (UIView *view in self.view.subviews)
//        {
//            [view removeFromSuperview];
//        }
//        [self.inappPrompt removeFromSuperview];
//        self.view.backgroundColor = [UIColor clearColor];
//        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Upgrade Application" message:@"Upgrade to pro" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upgrade",@"Restore", nil];
        alertView.tag = 1000;
        [alertView show];

    }
    else
    {
        self.inappContentTitle.font = [UIFont fontWithName:APPLICATION_FONT size:20];
        self.inappContentLabel.font = [UIFont fontWithName:APPLICATION_FONT size:23];
        self.inappContentLabel2.font = [UIFont fontWithName:APPLICATION_FONT size:23];
        self.inappPrompt.layer.cornerRadius = 5;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[FBAppDelegate application] logGoogleAnalytics:@"UI" action:@"ViewSwitch" label:@"InAppPurchase - QBInAppPurchaseManager" value:nil];
}

#pragma mark Member functions

+ (BOOL)canMakePayements
{
    return [SKPaymentQueue canMakePayments];
}


// Check whether the product is present in the valid products array returned from store.
- (BOOL)validateProductWithIdentifier:(NSString *)productIdentifier
{
    if ([self.validProducts count] == 0)
    {
        return NO;
    }
    
    for (SKProduct *product in self.validProducts)
    {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            return YES;
        }
    }
    
    return NO;
}


- (SKProduct *)selectValidProductsWithIdentifier:(NSString *)productIdentifier
{
    for (SKProduct *product in self.validProducts)
    {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            return product;
        }
    }
    return nil;
    
}


// Retreives product data from store. This can be used to check if product identifier entered is valid or not.
- (void) requestProductData
{
    NSLog(@"Request Product data");
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIdentifiers] ;
    request.delegate = self;
    [request start];
}


// Used to purchase multiple quantity if supported by store
- (BOOL)makePaymentForProductWithIdentifier:(NSString *)productIdentifier forQuantity:(int)quantity
{
    if ([self validateProductWithIdentifier:productIdentifier])
    {
        // Code for transaction
        
        SKProduct *selectedProduct = [self selectValidProductsWithIdentifier:productIdentifier];
        
        if (selectedProduct == nil)
        {
            return NO;
        }
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        // payment.quantity = quantity;
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)makePaymentForProductWithIdentifier:(NSString *)productIdentifier
{
    if ([self validateProductWithIdentifier:productIdentifier])
    {
        // Code for transaction
        
        SKProduct *selectedProduct = [self selectValidProductsWithIdentifier:productIdentifier];
        
        if (selectedProduct == nil)
        {
            return NO;
        }
        
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (void)restoreCompletedTransactions
{
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

- (IBAction)closeInAppPrompt:(id)sender
{
//    [self dismissViewControllerAnimated:NO completion:nil];
    [self removedInappPrompt];
}

- (IBAction)buyNow:(id)sender
{
    self.reachability = [Reachability reachabilityWithHostName:@"itunesconnect.apple.com"];
    NetworkStatus internetStatus = self.reachability.currentReachabilityStatus;
    
    if (internetStatus != NotReachable)
    {
        if ([QBInAppPurchaseManager canMakePayements])
        {
            self.productIdentifiers = [NSSet setWithObjects:PRO_UPGRADE_ID, nil];
            
            [self requestProductData];
            if (!self.moreAppPage)
            {
                [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please enable In-App purchase in your device's restriction settings." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            alert.tag = 200;
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"No network" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = 200;
        [alert show];
    }

    debugLog(@"Buy Now clicked");
}

- (IBAction)restorePurchase:(id)sender
{
    self.reachability = [Reachability reachabilityWithHostName:@"itunesconnect.apple.com"];
    NetworkStatus internetStatus = self.reachability.currentReachabilityStatus;
    
    if (internetStatus != NotReachable)
    {
        if ([QBInAppPurchaseManager canMakePayements])
        {
            self.productIdentifiers = [NSSet setWithObjects:PRO_UPGRADE_ID, nil];
            [self restoreCompletedTransactions];
            if (!self.moreAppPage)
            {
                [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            }
            
            // Check network
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(reachabilityChanged:)
                                                         name:kReachabilityChangedNotification
                                                       object:nil];
            
            
            [self.reachability startNotifier];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please enable In-App purchase in your device's restriction settings." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            alert.tag = 200;
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"No network" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = 200;
        [alert show];
    }

    debugLog(@"restorepurchase");
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([queue.transactions count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You have no purchases that can be restored!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = 200;
        [alert show];
        
    }
    else
    {
        //        [self.bannerView removeFromSuperview];
        //        self.bannerView = nil;
//        [self removeSharedBannerView];

//        if([(NSObject *)self.delegate respondsToSelector:@selector(purchaseCompletedSuccessfully)])
//        {
//            [self.delegate purchaseCompletedSuccessfully];
//        }

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"You have successfully restored your previous purchase" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
    }
    
//    [self dismissViewControllerAnimated:NO completion:nil];

}



- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
}


// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
//    [self dismissViewControllerAnimated:NO completion:nil];

    [self removedInappPrompt];
    
    if (error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Restore Transaction failed!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = 200;
        [alert show];
    }
}


#pragma mark helper methods

// Transaction is in queue, user has been charged.  Client should complete the transaction.
- (void)completeTransaction: (SKPaymentTransaction *)transaction

{
    // Your application should implement these two methods.
    
    [self recordTransaction:transaction];
    
    [self provideContent:transaction.payment.productIdentifier];
    
    // Remove the transaction from the payment queue.
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self purchaseCompletedSuccessfully];
}


- (void)restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

// Transaction was cancelled or failed before being added to the server queue.
- (void)failedTransaction: (SKPaymentTransaction *)transaction

{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
//        [self removeInappPrompt];
//        [self dismissViewControllerAnimated:NO completion:nil];

        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Transaction failed!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = 200;
        [alert show];
    }
    else
    {
            [self userCancelledPurchase];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}


// Transaction is being added to the server queue.
- (void)purchasingTransaction: (SKPaymentTransaction *)transaction
{
    
}


// This function is used to save the transaction details.
//- (void) recordTransaction: (SKPaymentTransaction *)transaction
//{
//    // Calls delegate method.
//    if([(NSObject *)self.delegate respondsToSelector:@selector(recordTransaction:)])
//    {
//        [self.delegate recordTransaction:transaction];
//        
//    }
//    
//}


- (void)provideContent:(NSString *)productIdentifier
{
    // Calls delegate method.
    if([(NSObject *)self.delegate respondsToSelector:@selector(provideContent:)])
    {
        [self.delegate provideContent:productIdentifier];
        
    }
}


#pragma mark Product data request call back
-(void)request:(SKProductsRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"SKProductsRequest Failed %@",[error localizedDescription]);
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    alert.tag = 200;
    [alert show];
    [self removedInappPrompt];
}
// Sent immediately before -requestDidFinish:

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *) response
{
    
    self.validProducts = (NSMutableArray *)response.products;
    self.invalidProductIdentifiers = (NSMutableArray *)response.invalidProductIdentifiers;
     NSLog(@"Product RequestCompleted");
           
    [self productRequestCompleted];
}


#pragma mark Payement request call backs

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions

{
    
    for (SKPaymentTransaction *transaction in transactions)
        
    {
        
        switch (transaction.transactionState)
        
        {
                
            case SKPaymentTransactionStatePurchased:
                
                [self completeTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStateFailed:
                
                [self failedTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStateRestored:
                
                [self restoreTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStatePurchasing:
                
                [self purchasingTransaction:transaction];
                
                
            default:
                
                break;
                
        }
        
    }
    
}


- (void)dealloc
{
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    self.productIdentifiers = nil;
    self.validProducts = nil;
    self.invalidProductIdentifiers = nil;
    self.productToBePurchased = nil;
    
}
#pragma mark In app Delegates


- (void)initializePurchaseManager
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    BOOL isProVersion = [settings boolForKey:PRO_UPGRADE_ID];
    
    if (isProVersion != YES)
    {
        
        
        // Check network
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
//        [self.reachability startNotifier];
    }
//    self.reachability = [Reachability reachabilityForInternetConnection];
}


- (void) reachabilityChanged:(NSNotification *) note
{
    NSLog(@"Report Rechability");
}

- (void)productRequestCompleted
{
    
    if ( [self validateProductWithIdentifier:PRO_UPGRADE_ID])
    {
        
        [self makePaymentForProductWithIdentifier:PRO_UPGRADE_ID];
        
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Invalid product identifier!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = 200;
        [alert show];
        
    }
    
}


- (void)recordTransaction: (SKPaymentTransaction *)transaction
{
    PHPublisherIAPTrackingRequest *request = [PHPublisherIAPTrackingRequest requestForApp:@"42b68a73d0c14f1aaf6eb5e76ce3ac5c" secret:@"e1bf4489b19943e8b6258f1eaa2bcd44" product:transaction.payment.productIdentifier quantity:transaction.payment.quantity resolution:PHPurchaseResolutionBuy receiptData:transaction.transactionReceipt];
    [request send];
    
//    [self removeSharedBannerView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:YES forKey:transaction.payment.productIdentifier];
    [settings synchronize];

//    [self removedInappPrompt];

    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    
}


- (void)userCancelledPurchase
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self removedInappPrompt];
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    
}
- (void)purchaseCompletedSuccessfully
{
    //    [self.bannerView removeFromSuperview];
    //    self.bannerView = nil;
    
//    [self removeSharedBannerView];
//    [self removeInappPrompt];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    if([(NSObject *)self.delegate respondsToSelector:@selector(purchaseCompletedSuccessfully)])
//    {
//        [self.delegate purchaseCompletedSuccessfully];
//    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"You have successfully upgraded to pro version" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    alert.tag = 100;
    [alert show];
    
}


// Method to set address of In app prompt to a variable so that it can be removed from view once purchase is completed
- (void)savePromptViewPointer:(UIView *)pointer
{
//    self.inAppPromptView = pointer;
}


//- (void)removeInappPrompt
//{
//    [self.inAppPromptView removeFromSuperview];
//    self.inAppPromptView = nil;
//}

#pragma mark alertview delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == 0)
        {
//            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
//            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [self userCancelledPurchase];
//            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        }
        if (buttonIndex == 1)
        {
            [self buyNow:self];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        if (buttonIndex == 2)
        {

            [self restorePurchase:self];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
    }
    else if (alertView.tag == 200)
    {
        [self removedInappPrompt];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    else if(alertView.tag == 100 || alertView.tag == 101)
    {
        if([(NSObject *)self.delegate respondsToSelector:@selector(purchaseCompletedSuccessfully)])
        {
            [self.delegate purchaseCompletedSuccessfully];
        }
        [self removedInappPrompt];
    }
}

-(void)removedInappPrompt
{
    [self.view removeFromSuperview];
    if (!self.moreAppPage)
    {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"inappPromptRemoved" object:self];
    }
}

#pragma mark -

- (void)viewDidUnload {
    [self setInappContentLabel:nil];
    [self setInappContentLabel2:nil];
    [super viewDidUnload];
}
@end
