//
//  WeatherTidesViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import "WeatherTidesViewController.h"

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
    // set up the view
    // stepsTotal so we can find the percentage of the download complete
    stepsTotal = TIDE_TOTAL_STEPS + WEATHER_TOTAL_STEPS;
    downloadsComplete = false;
    // steps completed reset
    stepsCompleted = 0;
    // add a progress bar to the view
    CGRect rect = CGRectMake(0, 0, 320, 2);
    progressBar = [[UIProgressView alloc]initWithFrame:rect];
    progressBar.progress = 0.0f;
    [self.view addSubview: progressBar];
    noProblemsDownloading = true;
    
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
// delegate method to deal with any problems from the download
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:true];
}
// selector description:
// sometimes the facebook event will not have a long/lat
// in this case we can try to geocode the location in the facebook event
// and get the coordinates from here, if we have the coordinates we can
// begin downloading the weather/tides information immediately
- (void) determineVenueLocation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    // check if there are coordinates to use
    if(fbEvent.eventLongitude != 0 && fbEvent.eventLatitude != 0){
        // we have the long/lat we can find the closest base station
        CLLocation *longLat = [[CLLocation alloc]initWithLatitude:fbEvent.eventLatitude longitude:fbEvent.eventLongitude];
        thisWeatherEvent = [[WeatherEvent alloc]initWithLocation:longLat forFacebookEvent:fbEvent];
        thisTidalEvent = [[TidalEvent alloc]initWithLocation:longLat forFacebookEvent:fbEvent];
    }
    // if there are no coordinates we might be able to use geocoders
    else if (fbEvent.eventLocation != nil){
        // we MIGHT be able to use geocoders
        [geocoder geocodeAddressString:fbEvent.eventLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if(error){
                // failed to geocode, have to display an alert to the user
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Location Found" message:@"No Location was found to display weather statistics" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alert show];
            }
            // geocode happened successfully, we can use these coordinates
            else{
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                thisWeatherEvent = [[WeatherEvent alloc]initWithLocation:[placemark location] forFacebookEvent:fbEvent];
                thisTidalEvent = [[TidalEvent alloc]initWithLocation:[placemark location] forFacebookEvent:fbEvent];
            }
        }];
    }
    else{
        // no chance, no location information was given whatsoever,
        // we should alert the user
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Location Found" message:@"No Location was found to display weather statistics" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

// selector description:
// this is the selector called when the controller recieves a progress update on
// the download, in this function we update the progress bar to reflect what
// percentage of the TOTALSTEPS we have completed.
// if all the downloads are complete we trigger a table reload

- (void) refreshView
{
    // update the progress bar here
    stepsCompleted++;
    float progress = (float)stepsCompleted/(float)stepsTotal;
    dispatch_async(dispatch_get_main_queue(), ^{
        progressBar.progress = progress;
    });
    // when the downloads complete successfully remove the progress bar from
    // the view and trigger a table view update
    if(stepsCompleted == stepsTotal && noProblemsDownloading){
        downloadsComplete = true;
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressBar removeFromSuperview];
            [self.tableView reloadData];
        });
    }
    
}

// selector description:

// this is the selector called by other classes if there was a problem
// downloading the data, i.e. no internet, web services are down etc.

-(void)errorReceived:(NSNotification*)notification
{
    // we use this flag so we do not throw multiple alerts at the user and
    // cause the application to crash.
    
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(downloadsComplete){
        // 6 is the number of rows required to view all the weather data
        // plus the station information
        return 6 + [[TidalEvent getTidesData] count];
    }
    else return 0;
}

// selector description:
// when updating the table view, we use this method to update all the labels
// and meters
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
    
    // this index path is the first item in the view, it displays the picture
    // and several bits of weather information
    if(indexPath.item == 0){
        //weather data view
        weatherCell = [tableView dequeueReusableCellWithIdentifier:weatherDataCellIdentifier forIndexPath:indexPath];
        [self findWeatherImageToUse];
        // set the different bits of information here
        weatherCell.WeatherActualTemperature.text = [thisWeatherEvent.eventTemperature stringByAppendingString:@"°C"];
        weatherCell.WeatherFeelsLikeTemperature.text = [thisWeatherEvent.eventFeelsLikeTemperature stringByAppendingString:@"°C"];
        weatherCell.WeatherTypeLabel.text = thisWeatherEvent.eventWeatherType;
        weatherCell.WeatherVisibilityLabel.text = thisWeatherEvent.eventVisibility;
        // make the text glow so it is visible on all the picture backgrounds
        [self makeTextGlow:weatherCell.WeatherTypeLabel];
        [self makeTextGlow:weatherCell.WeatherVisibilityLabel];
        // set the weather image
        weatherCell.WeatherImage.image = thisWeatherEvent.eventWeatherImage;
        [weatherCell animateImage];
        return weatherCell;
    }
    // this index path is for displaying the wind direction
    else if (indexPath.item == 1){
        //wind direction cell
        cell = [tableView dequeueReusableCellWithIdentifier:windDirectionCellIdentifier forIndexPath:indexPath];
        cell.detailTextLabel.text = thisWeatherEvent.eventWindDirection;
        return cell;
    }
    // index path for displaying the wind speed in knots
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
    // index path for displaying the wind gust speed in knots
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
    // this index path range is so we can display the correct amount of meters
    // for all the tide data found
    // the index path must be 3 more than the number of tide events
    // because there are 3 rows displayed before tide data is shown
    else if(indexPath.item > 3 && indexPath.item < [[TidalEvent getTidesData]count]+3){
        long arrayIndex = indexPath.item - 4;
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
    // index path for the message must be 3 more than the number of tide events to get the right row number
    else if(indexPath.item == [[TidalEvent getTidesData]count]+3){
        //messsage cell
        cell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier forIndexPath:indexPath];
        cell.detailTextLabel.text = thisWeatherEvent.userMessage;
        return cell;
    }
    //index path for the weather source must be 4 more than the number of tide events to get the right row number
    else if (indexPath.item == [[TidalEvent getTidesData]count]+4){
        //weather source cell
        cell = [tableView dequeueReusableCellWithIdentifier:dataSourceCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Weather Station: ";
        cell.detailTextLabel.text = thisWeatherEvent.baseStation;
        return cell;
    }
    // display the port information
    else{
        //tide source cell
        cell = [tableView dequeueReusableCellWithIdentifier:dataSourceCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Port: ";
        cell.detailTextLabel.text = thisTidalEvent.baseStation;
        return cell;
    }
    // Configure the cell...
}

// selector description:
// this returns the row height for each row.
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

// selector description:
// this method is used to determine which weather image to use
// there are many weather types and not enough images to depict all the weather
// types, so we categorise each image into a range of weather types.
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

// selector description:
// because the image may make the text not readable, we apply a glow to the
// label layer by adjusting the shadow properties to make it look like a glow.
-(void) makeTextGlow:(UILabel *)label
{
    [[label layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[label layer] setShadowOffset:CGSizeMake(0.0, 0.0)];
    [[label layer] setShadowRadius:2.0f];
    [[label layer] setShadowOpacity:0.99f];
    [[label layer] setMasksToBounds:NO];
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
