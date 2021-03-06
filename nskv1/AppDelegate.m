//
//  AppDelegate.m
//  nskv1
//
//  Created by Omorr Faruk on 25/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@implementation AppDelegate
static NSString *devTokenField;
NSString *fbID;
bool errorIsShown = NO;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    // the launch options are used to check if there are any remote notifications the program must handle
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [self saveRemoteNotification:remoteNotif];
    // register for push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    // Override point for customization after application launch.
    return YES;
    
}
// Selector Description:
// Delegate method for dealing with response to alert view button pressed
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshEventList" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPinnedList" object:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    FacebookEvent *ev = [[FacebookEvent alloc]init];
    // This code gets the permissions to get the events from facebook and post responses to events
    NSArray *perm = [[NSArray alloc]initWithObjects:@"rsvp_event", nil];
    [FBSession openActiveSessionWithPublishPermissions:perm defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (error && !errorIsShown) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            errorIsShown = YES;
            // if otherwise we check to see if the session is open, an alternative to
            // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
            // property of the session object; the macros are useful, however, for more
            // detailed state checking for FBSession objects
        }
        if (FB_ISSESSIONOPENWITHSTATE(status)) {
            // send our requests if we successfully logged in
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(error && !errorIsShown){
                    // there was an issue connecting with the internet
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Not connected to the internet, please ensure:  \n - Flight Mode is not enabled \n -You have an active data connection"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    errorIsShown = YES;
                    if([FacebookEvent getEventsList] == nil)
                    {
                        [FacebookEvent setManagedObjectContext:self.managedObjectContext];
                        [ev loadCachedEvents];
                    }
                }
                else if(!error)
                {
                    // gets the ID of the user, used for finding attending events
                    NSMutableDictionary *dictionary = (NSMutableDictionary *)result;
                    ev.userID = [dictionary objectForKey:@"id"];
                    fbID = ev.userID;
                    // if the application just started and there are no events, download them
                    if([FacebookEvent getEventsList] == nil){
                        [FacebookEvent setManagedObjectContext:self.managedObjectContext];
                        [ev downloadEvents];
                        [self sendDeviceTokenToService];
                    }
                }
            }];
        }
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// Selector Description:
// get the device token used for push notifications and prepare it to be sent to the device token web service
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    // formats it for use in the web service
    devTokenField = [[[[devToken description]
                       stringByReplacingOccurrencesOfString: @"<" withString: @""]
                      stringByReplacingOccurrencesOfString: @">" withString: @""]
                     stringByReplacingOccurrencesOfString: @" " withString: @""];
    // sends this selector when it has a device token
    [self sendDeviceTokenToService];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Failed to register for push notifications, please relaunch the app to try again"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
// Selector Description:
// checks if we have both a facebook id and a device token, then sends both to the device token web service.
- (void)sendDeviceTokenToService
{
    
    // checks if we have both
    if(devTokenField == nil | fbID== nil){
        return;
    }
    // checks if we have sent it before to prevent duplicate tokens being sent from the same device
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString* tokenSentBefore = [def valueForKey:@"TokenSent"];
    if(!tokenSentBefore){
        // prepares the information to be sent by putting the info in a dictionary
        NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  fbID, @"fbID",
                                  devTokenField, @"deviceToken",
                                  @"", @"oldToken",
                                  nil];
        [self postData:jsonDict withDeviceTokenToSave:devTokenField];
    }
    else
    {
        if(![tokenSentBefore isEqualToString:devTokenField])
        {
            NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      fbID, @"fbID",
                                      devTokenField, @"deviceToken",
                                      tokenSentBefore, @"oldToken",
                                      nil];
            [self postData:jsonDict withDeviceTokenToSave:devTokenField];
        }
    }
}

- (void)postData:(NSDictionary *)jsonDict withDeviceTokenToSave:(NSString*)token
{
    NSString *address = @"http://somecoolname.com/DeviceService/Api/DeviceToken";
    // preparing post request to be sent here
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    // create an operation queue to send the data asynchronously
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!error)
        {
            // writes to the user defaults that the information has been sent before so it doesnt do it again
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:token forKey:@"TokenSent"];
            [defaults synchronize];
        }
    }];
}
// Selector Description:
// Delegate for dealing with when a remote notification has arrived in app
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *message = [NSString stringWithFormat:@"%@. Please see the pinned events for more details", [[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An event has changed"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self saveRemoteNotification:userInfo];
}
// Selector Description:
// Saves the event that has changed to the user defaults so user can see any changes that have happened in app later
- (void)saveRemoteNotification:(NSDictionary*)notification
{
    // gets the facebook event in the notification
    NSString *recievedEvent = [notification objectForKey:@"eID"];
    // checks if there is already a notification for this event, if there is, no need to add it again
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newPrefs = [defaults objectForKey:@"FacebookEventChanged"];
    NSArray *currentFlaggedEvents = [newPrefs componentsSeparatedByString:@","];
    bool addEventToPrefs = true;
    for (NSString *str in currentFlaggedEvents) {
        if ([str isEqualToString:recievedEvent]) {
            addEventToPrefs = false;
        }
    }
    if (addEventToPrefs) {
        // if the event should be added to the prefs, delete the current entry and rewrite a new list of notified events
        [defaults removeObjectForKey:@"FacebookEventChanged"];
        // create a new comma separated string for the list of events changed
        NSString *newDefaultValue = @"";
        for (NSString *str in currentFlaggedEvents) {
            newDefaultValue = [newDefaultValue stringByAppendingString:[NSString stringWithFormat:@"%@,",str]];
        }
        newDefaultValue = [newDefaultValue stringByAppendingString:[NSString stringWithFormat:@"%@,",recievedEvent]];
        // add the new value to the defaults
        [defaults setObject:newDefaultValue forKey:@"FacebookEventChanged"];
        // refresh the pinned list to display the alert
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"eventModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"cdtest.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
