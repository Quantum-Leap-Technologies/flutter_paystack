#import "FlutterPaystackPlugin.h"
#import <sys/utsname.h>
#import "PSTCKRSA.h"
#import "PSTCKAuthViewController.h"


@implementation FlutterPaystackPlugin {
    UIViewController *_viewController;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.wilburt/flutter_paystack"
            binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
  PSTCKLog(@"register: rootViewController=%@", viewController);
  FlutterPaystackPlugin* instance = [[FlutterPaystackPlugin alloc] initWithViewController: viewController];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getDeviceId" isEqualToString:call.method]) {
    result([@"iossdk_" stringByAppendingString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]);
      
  } else if([@"getAuthorization" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      NSString *url = arguments[@"authUrl"];
      [self requestAuth:url result: result];
      
  } else if([@"getEncryptedData" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      NSString *data = arguments[@"stringData"];
      result([PSTCKRSA encryptRSA:data]);
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}


// Resolve the presenter when it's needed, not at registration. Under the
// UIScene lifecycle (FlutterImplicitEngineDelegate) plugins register before any
// window exists, so the controller captured in registerWithRegistrar is nil and
// presenting from it silently does nothing.
- (UIViewController *)topViewController {
    UIViewController *root = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) { root = window.rootViewController; break; }
            }
            if (root != nil) break;
        }
    }
    if (root == nil) root = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (root == nil) root = _viewController;
    while (root.presentedViewController != nil) root = root.presentedViewController;
    return root;
}

- (void) requestAuth:(NSString * _Nonnull) url result:(FlutterResult)result {
    UIViewController *presenter = [self topViewController];
    PSTCKLog(@"requestAuth: url=%@ presenter=%@", url, presenter);
    if (presenter == nil) {
        // Fail instead of leaving the Dart side awaiting a result forever.
        result([FlutterError errorWithCode:@"no_view_controller"
                                   message:@"Unable to present 3DS authorization"
                                   details:nil]);
        return;
    }
    __block UINavigationController *nc = nil;
    PSTCKAuthViewController* authorizer = [[[PSTCKAuthViewController alloc] init]
                                           initWithURL:[NSURL URLWithString:url]
                                           handler:^{
                                               PSTCKLog(@"completion: returning requery to Dart");
                                               [nc dismissViewControllerAnimated:YES completion:nil];
                                               nc = nil;
                                               NSDictionary *response = @{ @"status": @"requery", @"message": @"Reaffirm Transaction Status on Server"};
                                               result([[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[response copy] options:0 error:NULL] encoding:NSUTF8StringEncoding]);
                                           }];
    nc = [[UINavigationController alloc] initWithRootViewController:authorizer];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [presenter presentViewController:nc animated:YES completion:^{
        PSTCKLog(@"requestAuth: auth view presented");
    }];
}

@end

