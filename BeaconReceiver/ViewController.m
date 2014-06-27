//
//  ViewController.m
//  BeaconReceiver
//
//  David Inglis

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSArray *beaconArray; // The array of visible beacons
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"11111111-2222-3333-4444-555555555555"];
    
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"gimbal"];
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];

    self.statusLabel.text = @"Initializing...";
    
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    // For testing purposes only, take out in final app
   [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
     
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

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Entered region!";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    // We entered a region, now start looking for our target beacons!
    
    self.statusLabel.text = @"Finding beacons.";
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
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

@end
