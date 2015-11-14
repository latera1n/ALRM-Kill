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
@property (weak, nonatomic) IBOutlet UIView *clockTopView;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clockCircleImageView;

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
//    NSLog(@"Current hour = %@", currentTimeString);
    self.currentTimeTextLabel.text = currentTimeString;

}

- (IBAction)gestureHandler:(UIGestureRecognizer *)sender {
    CGPoint clockCenterPoint = self.clockCircleImageView.center;
    
    if ([sender state] == UIGestureRecognizerStateBegan
        ) {
        self.dotImageView.hidden = false;
    }
    
    if ([sender state] == UIGestureRecognizerStateChanged) {
        CGPoint currentPoint = [sender locationInView:self.clockTopView];
        CGPoint currentDotCenter = self.dotImageView.center;
        NSLog(@"%f, %f", currentPoint.x, currentPoint.y);
        CGFloat radiusToClockCenter = sqrtf(powf(currentPoint.x - clockCenterPoint.x, 2.0) + powf(currentPoint.y - clockCenterPoint.y, 2.0));
        currentDotCenter.x = clockCenterPoint.x + (98.5 / radiusToClockCenter) * (currentPoint.x - clockCenterPoint.x) + 4;
        currentDotCenter.y = clockCenterPoint.y + (98.5 / radiusToClockCenter) * (currentPoint.y - clockCenterPoint.y) - 20;
        self.dotImageView.center = currentDotCenter;
    }
    
    if ([sender state] == UIGestureRecognizerStateEnded
        ) {
        self.dotImageView.hidden = true;
    }
}

@end
