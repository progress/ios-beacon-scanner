//
//  ViewController.m
//  BeaconReceiver
//
//  Copyright 2014 © Progress Software
//  Contributor: David Inglis

#import "ViewController.h"

@interface ViewController ()



@end

@implementation ViewController
{
    NSArray *beaconArray; // The array of visible beacons
    NSUserDefaults *defaults;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.nameLabel.delegate = self;
    self.nameLabel.text = [defaults objectForKey:@"UserName"];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"08D4A950-80F0-4D42-A14B-D53E063516E6"];
    
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"gimbal"];
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];

    self.statusLabel.text = @"Initializing...";
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device must support monitoring." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    // For testing purposes only, take out in final app
    // [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    // [self userName:self.nameLabel.text entry:YES];
}

// When the return key gets pressed on the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [defaults setObject:self.nameLabel.text forKey:@"UserName"]; // for caching between sessions
    [defaults synchronize];
    [textField resignFirstResponder]; // closes the keyboard
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [beaconArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"TableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    CLBeacon *temp = [beaconArray objectAtIndex:indexPath.row];
    NSString *uuid = temp.proximityUUID.UUIDString;
    double d = temp.accuracy;
    d = floor(d * 10) / 10;
    cell.textLabel.text = [NSString stringWithFormat:@"%g meters  |  major: %@  |  minor: %@ ", d, temp.major, temp.minor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"UUID: %@", uuid];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)userName:(NSString*)name entry:(Boolean)didEnter
{
    NSString *nodeString = @"http://helloworld-20553.onmodulus.net/";
    NSURL *nodeURL = [NSURL URLWithString: nodeString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm.ss"];
    NSString *resultString = [dateFormatter stringFromDate:currentTime];
    NSString *finalString;
    finalString = [NSString stringWithFormat:@"%@,%hhu,%@", resultString, didEnter, self.nameLabel.text];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nodeURL];
    [request setHTTPMethod: @"POST"];
    NSLog(@"test");
    NSLog(self.nameLabel.text);
    NSLog(finalString);
    [request setHTTPBody: [finalString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSLog(@"Sent request.");
    }];
    [postDataTask resume];
    NSLog(@"past request in code.");

}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Entered region!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    // We entered a region, now start looking for our target beacons!
    
    self.statusLabel.text = @"Finding beacons.";
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    [self userName:self.nameLabel.text entry:YES];
}


- (void)locationManager:(CLLocationManager*)manager didStartMonitoringForRegion:(CLRegion *)region
{
    self.statusLabel.text = @"Looking for region.";
    
}


-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion *)region
{
    // Exited the region
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Exited region.";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    [self userName:self.nameLabel.text entry:NO];
}
 

-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    // Beacon found!
    if ([beacons count] > 0)
    {
        self.statusLabel.text = [NSString stringWithFormat:@"Beacons Visible: %d", [beacons count]];
        beaconArray = beacons;
        [self.tableView reloadData];
    }
    else
    {
        self.statusLabel.text = @"No beacons yet...";
    }
}

- (IBAction)dEOE:(id)sender {
}

@end
