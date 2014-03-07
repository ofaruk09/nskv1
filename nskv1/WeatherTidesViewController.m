//
//  WeatherTidesViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import "WeatherTidesViewController.h"
#include <Quartzcore/Quartzcore.h>

@interface WeatherTidesViewController ()

@end

@implementation WeatherTidesViewController
@synthesize fbEvent;
@synthesize timeToEvent;
@synthesize thisWeatherEvent;
@synthesize thisTidalEvent;
UIProgressView *progressBar;
const NSArray *weatherImages;
bool downloadsComplete;
int stepsTotal;
int stepsCompleted;
bool noProblemsDownloading = true;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    stepsTotal = TIDE_TOTAL_STEPS + WEATHER_TOTAL_STEPS;
    downloadsComplete = false;
    stepsCompleted = 0;
    CGRect rect = CGRectMake(0, 0, 320, 2);
    progressBar = [[UIProgressView alloc]initWithFrame:rect];
    progressBar.progress = 0.0f;
    [self.view addSubview: progressBar];
    noProblemsDownloading = true;
    //TEMPORARY VALUES TO SIMULATE A REAL FACEBOOK EVENT
    //---------------------------------------------------
    
    FacebookEvent *temp = [[FacebookEvent alloc]init];
    temp.eventLongitude = 1.2724;
    temp.eventLatitude = 51.9271;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *startDate = [format dateFromString:@"2014-03-09T21:30:00+0000"];
    temp.eventStartDate = startDate;
    temp.dateFormatterStart = format;
    //fbEvent = temp;
    //timeToEvent = 4.96;
    NSLog(@"Reported date: %@", fbEvent.eventStartDate);
    
    //---------------------------------------------------
    
    weatherImages = [[NSArray alloc]initWithObjects:@"NightWeather",
                     @"SunnyWeather",
                     @"PartlyCloudyWeather",
                     @"CloudyWeather",
                     @"RainWeather",
                     @"HeavyRainWeather",
                     @"SnowWeather",
                     @"LightningWeather", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:@"notifyProgressForTides"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:@"notifyProgressForWeather"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(errorReceived:)
                                                 name:@"errorDownloadingData"
                                               object:nil];
    
    [self determineVenueLocation];
	// Do any additional setup after loading the view.
    // When sending a request, to get ALL the data including gust, we must provide the city!
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void) determineVenueLocation
{
    NSLog(@"event location: %f , %f",fbEvent.eventLongitude,fbEvent.eventLatitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    if(fbEvent.eventLongitude != 0 && fbEvent.eventLatitude != 0){
        // we have the long/lat we can find the closest base station
        CLLocation *longLat = [[CLLocation alloc]initWithLatitude:fbEvent.eventLatitude longitude:fbEvent.eventLongitude];
        thisWeatherEvent = [[WeatherEvent alloc]initWithLocation:longLat forFacebookEvent:fbEvent];
        thisTidalEvent = [[TidalEvent alloc]initWithLocation:longLat forFacebookEvent:fbEvent];
    }
    else if (fbEvent.eventLocation != nil){
        // we MIGHT be able to use geocoders
        [geocoder geocodeAddressString:fbEvent.eventLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if(error){
                NSLog(@"ERROR");
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Location Found" message:@"No Location was found to display weather statistics" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alert show];
            }
            else{
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                thisWeatherEvent = [[WeatherEvent alloc]initWithLocation:[placemark location] forFacebookEvent:fbEvent];
                thisTidalEvent = [[TidalEvent alloc]initWithLocation:[placemark location] forFacebookEvent:fbEvent];
            }
        }];
    }
    else{
        // no chance
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Location Found" message:@"No Location was found to display weather statistics" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}
- (void) refreshView
{
    stepsCompleted++;
    float progress = (float)stepsCompleted/(float)stepsTotal;
    NSLog(@"%i/%i",stepsCompleted,stepsTotal);
    NSLog(@"%f",progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        progressBar.progress = progress;
    });
    
    if(stepsCompleted == stepsTotal && noProblemsDownloading){
        downloadsComplete = true;
        NSLog(@"downloads complete");
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressBar removeFromSuperview];
            [self.tableView reloadData];
        });
    }
    
}

-(void)errorReceived:(NSNotification*)notification
{
    if(noProblemsDownloading){
        dispatch_async(dispatch_get_main_queue(), ^{
            noProblemsDownloading = false;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong..." message:notification.object delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(downloadsComplete){
        return 6 + [[TidalEvent getTidesData] count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *weatherDataCellIdentifier = @"weatherDataCell";
    static NSString *windDirectionCellIdentifier = @"windDirectionCell";
    static NSString *meterCellIdentifier = @"meterCell";
    static NSString *messageCellIdentifier = @"messageCell";
    static NSString *dataSourceCellIdentifier = @"dataSourceCell";
    UITableViewCell *cell;
    MeterViewCell *meterCell;
    WeatherViewCell *weatherCell;
    
    if(indexPath.item == 0){
        //weather data view
        weatherCell = [tableView dequeueReusableCellWithIdentifier:weatherDataCellIdentifier forIndexPath:indexPath];
        [self findWeatherImageToUse];
        weatherCell.WeatherActualTemperature.text = [thisWeatherEvent.eventTemperature stringByAppendingString:@"°C"];
        weatherCell.WeatherFeelsLikeTemperature.text = [thisWeatherEvent.eventFeelsLikeTemperature stringByAppendingString:@"°C"];
        weatherCell.WeatherTypeLabel.text = thisWeatherEvent.eventWeatherType;
        weatherCell.WeatherVisibilityLabel.text = thisWeatherEvent.eventVisibility;
        [self makeTextGlow:weatherCell.WeatherTypeLabel];
        [self makeTextGlow:weatherCell.WeatherVisibilityLabel];
        weatherCell.WeatherImage.image = thisWeatherEvent.eventWeatherImage;
        [weatherCell animateImage];
        return weatherCell;
    }
    else if (indexPath.item == 1){
        //wind direction cell
        cell = [tableView dequeueReusableCellWithIdentifier:windDirectionCellIdentifier forIndexPath:indexPath];
        cell.detailTextLabel.text = thisWeatherEvent.eventWindDirection;
        return cell;
    }
    else if (indexPath.item == 2){
        meterCell = [tableView dequeueReusableCellWithIdentifier:meterCellIdentifier forIndexPath:indexPath];
        meterCell.Value.text = thisWeatherEvent.eventWindSpeed;
        meterCell.percentageOfMeter = thisWeatherEvent.percentageOfMaxWindSpeedWind;
        meterCell.MeterTypeLabel.text = @"Wind Speed (kt): ";
        meterCell.optionalLabel.text = @"";
        [meterCell animateMeter];
        return meterCell;
        //wind speed cell
    }
    else if (indexPath.item == 3){
        //wind gust cell
        meterCell = [tableView dequeueReusableCellWithIdentifier:meterCellIdentifier forIndexPath:indexPath];
        meterCell.Value.text = thisWeatherEvent.eventWindGusting;
        meterCell.percentageOfMeter = thisWeatherEvent.percentageOfMaxWindSpeedGust;
        meterCell.MeterTypeLabel.text = @"Wind Gusting Speed (kt): ";
        meterCell.optionalLabel.text = @"";
        [meterCell animateMeter];
        return meterCell;
    }
    else if(indexPath.item > 3 && indexPath.item < [[TidalEvent getTidesData]count]+3){
        int arrayIndex = indexPath.item - 4;
        TidalEvent *temp = [[TidalEvent getTidesData]objectAtIndex:arrayIndex];
        meterCell = [tableView dequeueReusableCellWithIdentifier:meterCellIdentifier forIndexPath:indexPath];
        meterCell.Value.text = temp.height;
        meterCell.percentageOfMeter = temp.percentageOfMaxTideHeight;
        meterCell.MeterTypeLabel.text = [NSString stringWithFormat:@"Tide Height(m) at Time: %@",temp.time];
        meterCell.optionalLabel.text = [NSString stringWithFormat:@"%@",temp.WaterMode];
        [meterCell animateMeter];
        return meterCell;
        //meters for tides
    }
    else if(indexPath.item == [[TidalEvent getTidesData]count]+3){
        //messsage cell
        cell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier forIndexPath:indexPath];
        cell.detailTextLabel.text = thisWeatherEvent.userMessage;
        return cell;
    }
    else if (indexPath.item == [[TidalEvent getTidesData]count]+4){
        //weather source cell
        cell = [tableView dequeueReusableCellWithIdentifier:dataSourceCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Weather Station: ";
        cell.detailTextLabel.text = thisWeatherEvent.baseStation;
        return cell;
    }
    else{
        //tide source cell
        cell = [tableView dequeueReusableCellWithIdentifier:dataSourceCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Port: ";
        cell.detailTextLabel.text = thisTidalEvent.baseStation;
        return cell;
    }
    // Configure the cell...
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item == 0){
        //weather data view
        return 213;
    }
    else if (indexPath.item == 1){
        //wind direction cell
        return 44;
    }
    else if (indexPath.item == 2){
        //wind speed cell
        return 80;
    }
    else if (indexPath.item == 3){
        //wind gust cell
        return 80;
    }
    else if(indexPath.item > 3 && indexPath.item < [[TidalEvent getTidesData]count]+3){
        //meters for tides
        return 80;
    }
    else if(indexPath.item == [[TidalEvent getTidesData]count]+4){
        //messsage cell
        return 60;
    }
    else if (indexPath.item == [[TidalEvent getTidesData]count]+5){
        //weather source cell
        return 60;
    }
    else{
        //tide source cell
        return 60;
    }
}

- (void)findWeatherImageToUse
{
    int wTemp = thisWeatherEvent.eventWeatherTypeValue.intValue;
    thisWeatherEvent.eventWeatherImage = [[UIImage alloc]init];
    //CONDITIONING IMAGE
    if (wTemp == 0) thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[0]];
    else if (wTemp == 1) thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[1]];
    else if (wTemp > 1 && wTemp <= 4) thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[2]];
    else if (wTemp > 4 && wTemp <=8) thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[3]];
    else if(wTemp > 8 && wTemp <= 12) thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[4]];
    else if(wTemp > 12 && wTemp <= 15) thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[5]];
    else if(wTemp > 15 && wTemp <= 27) thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[6]];
    else thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[7]];
}
-(void) makeTextGlow:(UILabel *)yourLabel
{
    [[yourLabel layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[yourLabel layer] setShadowOffset:CGSizeMake(0.0, 0.0)];
    [[yourLabel layer] setShadowRadius:2.0f];
    [[yourLabel layer] setShadowOpacity:0.99f];
    [[yourLabel layer] setMasksToBounds:NO];
    //http://benscheirman.com/2011/09/creating-a-glow-effect-for-uilabel-and-uibutton/
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
