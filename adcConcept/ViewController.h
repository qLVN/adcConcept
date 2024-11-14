//
//  ViewController.h
//  test
//
//  Created by lucas on 09/11/24.
//  Copyright (c) 2024 lvn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;
- (void)sendSysout:(NSString *)text;

@property (nonatomic, strong) UIAlertView *phpsessidErrorAlert;
@property (nonatomic, strong) UIAlertView *audsessidErrorAlert;
@property (nonatomic, strong) UIAlertView *audsessidPasswordErrorAlert;
@property (nonatomic, strong) UIAlertView *stateidErrorAlert;
@property (nonatomic, strong) UIAlertView *authorizecodeErrorAlert;
@property (nonatomic, strong) UIAlertView *authorizecodeRestartAlert;
@property (nonatomic, strong) UIAlertView *tomorrowcodeErrorAlert;
@property (nonatomic, strong) UIAlertView *agendaErrorAlert;
@end