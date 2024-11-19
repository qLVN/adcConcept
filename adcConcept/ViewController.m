//
//  ViewController.m
//  test
//
//  Created by lucas on 09/11/24.
//  Copyright (c) 2024 lvn. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

bool debug = NO;
bool noConnect = NO; //debug: doesn't start making requests.

NSString *phpSessId;
//NSString *phpSessId = @"";
NSString *audSessId;
//NSString *audSessId = @"";
NSString *stateId;
//NSString *stateId = @"";
NSString *authorizeCode;
//NSString *authorizeCode = @"";
NSString *tomorrowSessId;
//NSString *tomorrowSessId = @"";

NSString *mondayDateToLoad = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
//    UINavigationBar* nav = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,320,1)];
//    nav.tintColor = [UIColor redColor];
//    [self.view addSubview:nav];
    
    //loading mainWebView
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"home" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.mainWebView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
    _mainWebView.delegate = self;
    
    //checking if an account is saved, if not showing the connect prompt
    
    //start connecting
    if (!noConnect) {
        if (tomorrowSessId != nil) {
            //Load data
            [self loadAgendaForTomorrowsessid:tomorrowSessId forMondayDate:nil];
        }
        else if (phpSessId != nil) {
            if (audSessId != nil) {
                if (stateId != nil) {
                    if (authorizeCode != nil) {
                        //tomorrowSessId is for sure nil
                        [self setTomorrowsessidForPhpsessid:phpSessId forAuthorizecode:authorizeCode forStateid:stateId];
                    }
                    else {
                        [self setAuthorizecodeForAudsessid:audSessId forStateid:stateId];
                    }
                }
                else {
                    [self setStateidForPhpsessid:phpSessId];
                }
                
            }
            else {
                [self setAudsessid];
            }
            
        }
        else {
            [self setPhpsessid];
        }
    }
    
}

- (void)restartConnection {
    phpSessId = nil;
    audSessId = nil;
    stateId = nil;
    authorizeCode = nil;
    tomorrowSessId = nil;
    
    [self sendSysout:@"Restarting connection process..."];
    [self setPhpsessid];
}

- (void)sendSysout:(NSString *)text {
    [self.mainWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"sysout('%@');", text]];
    NSLog(text);
}

- (void)setPhpsessid {
    NSString *url = @"https://tomorrow.audencia.com/";
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [req setValue:@"https://login.audencia.com/" forHTTPHeaderField:@"Referer"];
    [req setValue:@"same-site" forHTTPHeaderField:@"Sec-Fetch-Site"];
    [req setValue:@"navigate" forHTTPHeaderField:@"Sec-Fetch-Mode"];
    [req setValue:@"document" forHTTPHeaderField:@"Sec-Fetch-Dest"];
    [req setValue:@"?1" forHTTPHeaderField:@"Sec-Fetch-User"];
    [req setValue:@"?0" forHTTPHeaderField:@"sec-ch-ua-mobile"];
    [req setValue:@"\"macOS\"" forHTTPHeaderField:@"sec-ch-ua-platform"];
    [req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"\"Chromium\";v=\"127\", \"Not)A;Brand\";v=\"99\"" forHTTPHeaderField:@"sec-ch-ua"];
    [req setValue:@"gzip, deflate, br, zstd" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/w" forHTTPHeaderField:@"Accept"];
    [req setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:req delegate:self];
//    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError) {
//            //            [self sendSysout:[NSString stringWithFormat:@"Request error (1.0): %@", [connectionError localizedDescription]]];
//            //
//            //            self.phpsessidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed request, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            //            [self.phpsessidErrorAlert show];
//            return;
//        }
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        if ((long)[httpResponse statusCode] == 200) { //Caused by a wrong redirect
//            [self sendSysout:@"Ignored faulty redirect (1.0)."];
//            return;
//        }
//        if ((long)[httpResponse statusCode] != 302) {
//            [self sendSysout:[NSString stringWithFormat:@"Response error (1.0), code %li", (long)[httpResponse statusCode]]];
//            
//            self.phpsessidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong response, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            [self.phpsessidErrorAlert show];
//            return;
//        }
//        
//    }];
}

- (void)setAudsessid {
    NSString *url = @"https://login.audencia.com/api/login";
    NSString *bodyData = @"";
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [req setValue:@"https://login.audencia.com/login" forHTTPHeaderField:@"Referer"];
    [req setValue:@"https://login.audencia.com" forHTTPHeaderField:@"Origin"];
    [req setValue:@"same-origin" forHTTPHeaderField:@"Sec-Fetch-Site"];
    [req setValue:@"cors" forHTTPHeaderField:@"Sec-Fetch-Mode"];
    [req setValue:@"empty" forHTTPHeaderField:@"Sec-Fetch-Dest"];
    [req setValue:@"?1" forHTTPHeaderField:@"Sec-Fetch-User"];
    [req setValue:@"?0" forHTTPHeaderField:@"sec-ch-ua-mobile"];
    [req setValue:@"\"macOS\"" forHTTPHeaderField:@"sec-ch-ua-platform"];
    [req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"\"Chromium\";v=\"127\", \"Not)A;Brand\";v=\"99\"" forHTTPHeaderField:@"sec-ch-ua"];
    [req setValue:@"gzip, deflate, br, zstd" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [NSURLConnection connectionWithRequest:req delegate:self];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (connectionError) {
            [self sendSysout:[NSString stringWithFormat:@"Response error (1.1): %@", [connectionError localizedDescription]]];
            
            self.audsessidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Response error, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
            [self.audsessidErrorAlert show];

            return;
        }
        
        if ((long)[httpResponse statusCode] == 401) {
            [self sendSysout:@"Incorrect credentials (1.1)."];
            
            self.audsessidPasswordErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Incorrect credentials, please reconnect." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Reconnect", nil];
            [self.audsessidPasswordErrorAlert show];
            return;
        }
        else if ((long)[httpResponse statusCode] != 200) {
            [self sendSysout:[NSString stringWithFormat:@"Response error (1.1), code %li", (long)[httpResponse statusCode]]];
            
            self.audsessidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong response, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
            [self.audsessidErrorAlert show];
            return;
        } else {
            [self sendSysout:@"Correct credentials. Pursuing connection (1.1)."];
            NSDictionary* headers = [httpResponse allHeaderFields];
            NSString *resp = [[headers objectForKey:@"Set-Cookie"] substringFromIndex:17];
            NSRange range = [resp rangeOfString:@";"];
            NSString *result = resp;
            if (range.location != NSNotFound) {
                result = [result substringToIndex:range.location];
                
            }
            
            audSessId = result;
            if (debug) {
                [self sendSysout:[NSString stringWithFormat:@"[DEBUG] audsessid: %@", audSessId]];
            }
            
            
            if (result == nil) { //no audsessid header in response
                [self sendSysout:@"Response error (1.1), empty response target header."];
                
                self.audsessidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong response, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
                [self.audsessidErrorAlert show];
                return;
            } else {
                //can continue
                [self setStateidForPhpsessid:phpSessId];
            }
            
        }
        
    }];
}

- (void)setStateidForPhpsessid:(NSString *)id {
    NSString *url = @"https://tomorrow.audencia.com/oauth_connect";
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [req setValue:[NSString stringWithFormat:@"PHPSESSID=%@", id] forHTTPHeaderField:@"Cookie"];
    
    [req setValue:@"https://login.audencia.com/" forHTTPHeaderField:@"Referer"];
    [req setValue:@"same-site" forHTTPHeaderField:@"Sec-Fetch-Site"];
    [req setValue:@"navigate" forHTTPHeaderField:@"Sec-Fetch-Mode"];
    [req setValue:@"document" forHTTPHeaderField:@"Sec-Fetch-Dest"];
    [req setValue:@"?1" forHTTPHeaderField:@"Sec-Fetch-User"];
    [req setValue:@"?0" forHTTPHeaderField:@"sec-ch-ua-mobile"];
    [req setValue:@"\"macOS\"" forHTTPHeaderField:@"sec-ch-ua-platform"];
    [req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"\"Chromium\";v=\"127\", \"Not)A;Brand\";v=\"99\"" forHTTPHeaderField:@"sec-ch-ua"];
    [req setValue:@"gzip, deflate, br, zstd" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/w" forHTTPHeaderField:@"Accept"];
    [req setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:req delegate:self];
//    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError) {
//            //            [self sendSysout:[NSString stringWithFormat:@"Request error (2.0): %@", [connectionError localizedDescription]]];
//            //
//            //            self.phpsessidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed request, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            //            [self.phpsessidErrorAlert show];
//            return;
//        }
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        if ((long)[httpResponse statusCode] == 200) { //Caused by a wrong redirect
//            [self sendSysout:@"Ignored faulty redirect (2.0)."];
//            return;
//        }
//        if ((long)[httpResponse statusCode] != 302) {
//            [self sendSysout:[NSString stringWithFormat:@"Response error (2.0), code %li", (long)[httpResponse statusCode]]];
//            
//            self.stateidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong response, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            [self.stateidErrorAlert show];
//            return;
//        }
//        
//    }];
}

- (void)setAuthorizecodeForAudsessid:(NSString *)aud forStateid:(NSString *)state {
    NSString *url = [NSString stringWithFormat:@"https://login.audencia.com/authorize?state=%@&scope=login&response_type=code&approval_prompt=auto&client_id=tomorrow&redirect_uri=https://tomorrow.audencia.com/oauth_check", state];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [req setValue:[NSString stringWithFormat:@"AUD_AUTH_SESS_ID=%@", aud] forHTTPHeaderField:@"Cookie"];
    
    [req setValue:@"https://login.audencia.com/" forHTTPHeaderField:@"Referer"];
    [req setValue:@"same-site" forHTTPHeaderField:@"Sec-Fetch-Site"];
    [req setValue:@"navigate" forHTTPHeaderField:@"Sec-Fetch-Mode"];
    [req setValue:@"document" forHTTPHeaderField:@"Sec-Fetch-Dest"];
    [req setValue:@"?1" forHTTPHeaderField:@"Sec-Fetch-User"];
    [req setValue:@"?0" forHTTPHeaderField:@"sec-ch-ua-mobile"];
    [req setValue:@"\"macOS\"" forHTTPHeaderField:@"sec-ch-ua-platform"];
    [req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"\"Chromium\";v=\"127\", \"Not)A;Brand\";v=\"99\"" forHTTPHeaderField:@"sec-ch-ua"];
    [req setValue:@"gzip, deflate, br, zstd" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/w" forHTTPHeaderField:@"Accept"];
    [req setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:req delegate:self];
//    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError) {
//            //            [self sendSysout:[NSString stringWithFormat:@"Request error (1.0): %@", [connectionError localizedDescription]]];
//            //
//            //            self.phpsessidErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed request, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            //            [self.phpsessidErrorAlert show];
//            return;
//        }
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        if ((long)[httpResponse statusCode] == 200) { //Caused by a wrong redirect
//            [self sendSysout:@"Ignored faulty redirect (3.0)."];
//            return;
//        }
//        if ((long)[httpResponse statusCode] != 302) {
//            [self sendSysout:[NSString stringWithFormat:@"Response error (3.0), code %li", (long)[httpResponse statusCode]]];
//            
//            self.authorizecodeErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong response, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            [self.authorizecodeErrorAlert show];
//            return;
//        }
//        
//    }];
}

- (void)setTomorrowsessidForPhpsessid:(NSString *)id forAuthorizecode:(NSString *)code forStateid:(NSString *)state {
    NSString *url = [NSString stringWithFormat:@"https://tomorrow.audencia.com/oauth_check?code=%@&state=%@", code, state];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [req setValue:[NSString stringWithFormat:@"PHPSESSID=%@", id] forHTTPHeaderField:@"Cookie"];
    
    [req setValue:@"https://login.audencia.com/" forHTTPHeaderField:@"Referer"];
    [req setValue:@"same-site" forHTTPHeaderField:@"Sec-Fetch-Site"];
    [req setValue:@"navigate" forHTTPHeaderField:@"Sec-Fetch-Mode"];
    [req setValue:@"document" forHTTPHeaderField:@"Sec-Fetch-Dest"];
    [req setValue:@"?1" forHTTPHeaderField:@"Sec-Fetch-User"];
    [req setValue:@"?0" forHTTPHeaderField:@"sec-ch-ua-mobile"];
    [req setValue:@"\"macOS\"" forHTTPHeaderField:@"sec-ch-ua-platform"];
    [req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"\"Chromium\";v=\"127\", \"Not)A;Brand\";v=\"99\"" forHTTPHeaderField:@"sec-ch-ua"];
    [req setValue:@"gzip, deflate, br, zstd" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/w" forHTTPHeaderField:@"Accept"];
    [req setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:req delegate:self];
//    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError) {
//            //            [self sendSysout:[NSString stringWithFormat:@"Request error (4.0): %@", [connectionError localizedDescription]]];
//            //
//            //            tomorrowcodeErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed request, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            //            [tomorrowcodeErrorAlert show];
//            return;
//        }
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        if ((long)[httpResponse statusCode] == 200) { //Caused by a wrong redirect
//            [self sendSysout:@"Ignored faulty redirect (4.0)."];
//            return;
//        }
//        if ((long)[httpResponse statusCode] != 302) {
//            [self sendSysout:[NSString stringWithFormat:@"Response error (4.0), code %li", (long)[httpResponse statusCode]]];
//            
//            self.tomorrowcodeErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong response, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
//            [self.tomorrowcodeErrorAlert show];
//            return;
//        }
//        
//    }];
}

- (void)loadAgendaForTomorrowsessid:(NSString *)id forMondayDate:(NSString *)requestedMondayDate {
    NSString *mondayDateString;
    NSString *fridayDateString;
    
    // Create date formatters to format the dates
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (mondayDateToLoad == nil) {
        //getting startDate and endDate
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitWeekday | kCFCalendarUnitDay fromDate:currentDate];
        
        // Calculate the difference between the current day and Monday (assuming Monday is the first day of the week)
        NSInteger daysUntilMonday = (components.weekday - [calendar firstWeekday] + 7) % 7;
        NSDateComponents *mondayComponents = [NSDateComponents new];
        mondayComponents.day = -daysUntilMonday + 1;
        
        // Calculate the difference between the current day and Friday
        NSInteger daysUntilFriday = 5 - components.weekday;
        NSDateComponents *fridayComponents = [NSDateComponents new];
        fridayComponents.day = daysUntilFriday + 1;
        
        // Get the Monday and Friday dates
        NSDate *mondayDate = [calendar dateByAddingComponents:mondayComponents toDate:currentDate options:0];
        NSDate *fridayDate = [calendar dateByAddingComponents:fridayComponents toDate:currentDate options:0];
        
        // Format the Monday and Friday dates
        mondayDateString = [dateFormatter stringFromDate:mondayDate];
        fridayDateString = [dateFormatter stringFromDate:fridayDate];
    }
    else {
        NSDate *mondayDate = [dateFormatter dateFromString:requestedMondayDate];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:5];
        NSDate *fridayDate = [calendar dateByAddingComponents:dateComponents toDate:mondayDate options:0];
        
        mondayDateString = requestedMondayDate;
        fridayDateString = [dateFormatter stringFromDate:fridayDate];
    }
    
    
    
    NSString *url = [NSString stringWithFormat:@"https://tomorrow.audencia.com/api/events?startDate=%@&endDate=%@&groups[]=full", mondayDateString, fridayDateString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [req setValue:[NSString stringWithFormat:@"PHPSESSID=%@", id] forHTTPHeaderField:@"Cookie"];
    
    [req setValue:@"https://tomorrow.audencia.com/" forHTTPHeaderField:@"Referer"];
    [req setValue:@"same-origin" forHTTPHeaderField:@"Sec-Fetch-Site"];
    [req setValue:@"cors" forHTTPHeaderField:@"Sec-Fetch-Mode"];
    [req setValue:@"empty" forHTTPHeaderField:@"Sec-Fetch-Dest"];
    [req setValue:@"?0" forHTTPHeaderField:@"sec-ch-ua-mobile"];
    [req setValue:@"\"macOS\"" forHTTPHeaderField:@"sec-ch-ua-platform"];
    [req setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"\"Chromium\";v=\"127\", \"Not)A;Brand\";v=\"99\"" forHTTPHeaderField:@"sec-ch-ua"];
    [req setValue:@"gzip, deflate, br, zstd" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    [req setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:req delegate:self];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (connectionError) {
            [self sendSysout:[NSString stringWithFormat:@"Response error (10.0): %@", [connectionError localizedDescription]]];
            
            self.agendaErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error happened while loading the agenda, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
            [self.agendaErrorAlert show];
            
            return;
        }
        else if ((long)[httpResponse statusCode] != 200) {
            [self sendSysout:[NSString stringWithFormat:@"Response error (10.0), code %li", (long)[httpResponse statusCode]]];
            
            self.agendaErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error happened while loading the agenda, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", nil];
            [self.agendaErrorAlert show];
            return;
        } else {
            //get the agenda in response body
            [self sendSysout:@"Day agenda gathered (10.0)."];
            NSString *agendaData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSMutableString *escapedAgendaData = [NSMutableString stringWithString:agendaData];
            [escapedAgendaData replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            [escapedAgendaData replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            [escapedAgendaData replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            [escapedAgendaData replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            [escapedAgendaData replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            [escapedAgendaData replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            [escapedAgendaData replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            [escapedAgendaData replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escapedAgendaData length])];
            
            [self.mainWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadAgendaData('%@', '%@');", escapedAgendaData, mondayDateString]];
            
            mondayDateToLoad = nil;
            
            if (debug) {
                [self sendSysout:[NSString stringWithFormat:@"[DEBUG] agendadata: %@", escapedAgendaData]];
                [self sendSysout:[NSString stringWithFormat:@"[DEBUG] mondayDateString: %@", mondayDateString]];
            }
        }
        
    }];

}

//Stop automatic redirects when the request response is acquired
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ((long)[httpResponse statusCode] == 302) {
                
                if ([[response URL] isEqual:[NSURL URLWithString:@"https://tomorrow.audencia.com/"]]) { //case 1.0
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    NSDictionary* headers = [httpResponse allHeaderFields];
                    NSString *resp = [[headers objectForKey:@"Set-Cookie"] substringFromIndex:10];
                    NSRange range = [resp rangeOfString:@";"];
                    NSString *result = resp;
                    if (range.location != NSNotFound) {
                        result = [result substringToIndex:range.location];
                        
                    }
                    
                    phpSessId = result;
                    if (debug) {
                        [self sendSysout:[NSString stringWithFormat:@"[DEBUG] phpsessid: %@", phpSessId]];
                    }
                    
                    [self sendSysout:@"Session ID gathered (1.0)."];
                    
                    //can continue
                    [self setAudsessid];
                }
                if ([[response URL] isEqual:[NSURL URLWithString:@"https://tomorrow.audencia.com/oauth_connect"]]) { //case 2.0
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    NSDictionary* headers = [httpResponse allHeaderFields];
                    NSString *resp = [[headers objectForKey:@"Location"] substringFromIndex:43];
                    NSRange range = [resp rangeOfString:@"&"];
                    NSString *result = resp;
                    if (range.location != NSNotFound) {
                        result = [resp substringToIndex:range.location]; //incase of problem switch back to result
                        
                    }
                    
                    stateId = result;
                    if (debug) {
                        [self sendSysout:[NSString stringWithFormat:@"[DEBUG] stateid: %@", stateId]];
                    }
                    [self sendSysout:@"State ID gathered (2.0)."];
                    
                    //can continue
                    [self setAuthorizecodeForAudsessid:audSessId forStateid:stateId];
                    
                }
                if ([[response URL] isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"https://login.audencia.com/authorize?state=%@&scope=login&response_type=code&approval_prompt=auto&client_id=tomorrow&redirect_uri=https://tomorrow.audencia.com/oauth_check", stateId]]]) { //case 3.0
                    
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    NSDictionary* headers = [httpResponse allHeaderFields];
                    
                    NSString *location = [headers objectForKey:@"Location"];
                    if ([location isEqualToString:@"/login"]) { //wrong location header
                        [self sendSysout:@"Response error (3.0), wrong response target header."];
                        
                        self.authorizecodeRestartAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed due to internal error, please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Restart", nil];
                        [self.authorizecodeRestartAlert show];
                        
                        return nil;
                    }
                    
                    NSString *resp = [[headers objectForKey:@"Location"] substringFromIndex:47];
                    NSRange range = [resp rangeOfString:@"&"];
                    NSString *result = resp;
                    if (range.location != NSNotFound) {
                        result = [result substringToIndex:range.location];
                        
                    }
                    
                    authorizeCode = result;
                    if (debug) {
                        [self sendSysout:[NSString stringWithFormat:@"[DEBUG] authorizecode: %@", authorizeCode]];

                    }
                    [self sendSysout:@"Authorize code gathered (3.0)."];
                    
                    //can continue
                    [self setTomorrowsessidForPhpsessid:phpSessId forAuthorizecode:authorizeCode forStateid:stateId];
                    
                }
                if ([[response URL] isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"https://tomorrow.audencia.com/oauth_check?code=%@&state=%@", authorizeCode, stateId]]]) { //case 4.0
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    NSDictionary* headers = [httpResponse allHeaderFields];
                    
                    NSString *resp = [[headers objectForKey:@"Set-Cookie"] substringFromIndex:10];
                    NSRange range = [resp rangeOfString:@";"];
                    NSString *result = resp;
                    if (range.location != NSNotFound) {
                        result = [result substringToIndex:range.location];
                        
                    }
                    
                    tomorrowSessId = result;
                    if (debug) {
                        [self sendSysout:[NSString stringWithFormat:@"[DEBUG] tomorrowsessid: %@", tomorrowSessId]];

                    }
                    [self sendSysout:@"Tomorrow session ID gathered, connection successful (4.0)."];
                    
                    //OK to load data
                    [self loadAgendaForTomorrowsessid:tomorrowSessId forMondayDate:nil];
                    
                    
                }
                
                //[self sendSysout:[NSString stringWithFormat:@"%@", [response URL]]]; //debug
                
                return nil;
            } else if (debug) {
                [self sendSysout:@"[DEBUG] Unknown delegate call."];
            }
            
        }
    }
    if ([[NSString stringWithFormat:@"%@", [request URL]]  isEqual: @"https://login.audencia.com/api/login"]) {
        [self sendSysout:@"Cancelled unwanted login redirect."];
        return nil;
    }
    
    return request;
}

//Wait for the user to interact with the alert in case of an error while connecting
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.phpsessidErrorAlert) {
        if (buttonIndex == 0) {
            [self setPhpsessid];
        }
    }
    if (alertView == self.audsessidErrorAlert) {
        if (buttonIndex == 0) {
            [self setAudsessid];
            
        }
    }
    if (alertView == self.audsessidPasswordErrorAlert) {
        if (buttonIndex == 0) {
            
            //temporary, as no password prompt have been implemented yet
            return;
        }
    }
    if (alertView == self.stateidErrorAlert) {
        if (buttonIndex == 0) {
            [self setStateidForPhpsessid:phpSessId];
        }
    }
    if (alertView == self.authorizecodeErrorAlert) {
        if (buttonIndex == 0) {
            [self setAuthorizecodeForAudsessid:audSessId forStateid:stateId];
        }
    }
    if (alertView == self.authorizecodeRestartAlert) {
        if (buttonIndex == 0) {
            [self restartConnection];
        }
    }
    if (alertView == self.tomorrowcodeErrorAlert) {
        if (buttonIndex == 0) {
            [self setTomorrowsessidForPhpsessid:phpSessId forAuthorizecode:authorizeCode forStateid:stateId];
        }
    }
    if (alertView == self.agendaErrorAlert) {
        if (buttonIndex == 0) {
            [self loadAgendaForTomorrowsessid:tomorrowSessId forMondayDate:mondayDateToLoad];
        }
    }
}

//Retreive data from JS
-(BOOL)webView:(UIWebView *)_viewWeb shouldStartLoadWithRequest:(NSURLRequest *)request   navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    if ([[url scheme] isEqualToString:@"tmrw"])
    {

        NSString *requestedMonday = [url host];
        mondayDateToLoad = requestedMonday;
        
        [self loadAgendaForTomorrowsessid:tomorrowSessId forMondayDate:requestedMonday];
        
        return YES;
    }else
    {
        return YES;
    }
    
}

//Avoid certificates errors, (debug only)
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
