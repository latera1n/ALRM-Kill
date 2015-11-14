//
//  ViewController.m
//  ControllableAlarmClock
//
//  Created by DengYuchi on 11/14/15.
//  Copyright © 2015 HackSC15. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currentTimeTextLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSRunLoop *runner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateTimeDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTimeDisplay {
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow: 0];
    self.timer = [[NSTimer alloc] initWithFireDate:now
                                          interval:1
                                            target:self
                                          selector:@selector(updateTime)
                                          userInfo:nil
                                           repeats:YES];
    self.runner = [NSRunLoop currentRunLoop];
    [self.runner addTimer:self.timer forMode:NSDefaultRunLoopMode];
}


- (void)updateTime {
    //  use gregorian calendar for calendrical calculations
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    //  get current date
    NSDate *date = [NSDate date];
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    units |= NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *currentComponents = [gregorian components:units fromDate:date];
    date = [gregorian dateFromComponents:currentComponents];
    
    //  format and display the time
    NSString *currentTimeString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSLog(@"Current hour = %@", currentTimeString);
    self.currentTimeTextLabel.text = currentTimeString;

}

@end
