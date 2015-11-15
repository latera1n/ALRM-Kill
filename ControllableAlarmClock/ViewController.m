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
@property (strong, nonatomic) NSTimer *CountdownTimer;
@property (strong, nonatomic) NSRunLoop *runner;
@property (strong, nonatomic) NSRunLoop *countdownRunner;
@property (weak, nonatomic) IBOutlet UIView *clockTopView;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clockCircleImageView;
@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UILabel *alarmTimeTextLabel;

@end

@implementation ViewController

double previousXMovementCalibrited = 0.0;
double previousYMovementCalibrited = -98.5;
int revolutionCount = 0;
double degreeThisRound = 0.0;
NSTimeInterval timeInterval = 0;

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
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
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
    NSString *currentTimeString = [NSDateFormatter localizedStringFromDate:date
                                                                 dateStyle:NSDateFormatterNoStyle
                                                                 timeStyle:NSDateFormatterShortStyle];
    self.alarmTimeTextLabel.text = currentTimeString;

}

- (IBAction)gestureHandler:(UIGestureRecognizer *)sender {
    CGPoint clockCenterPoint = self.clockCircleImageView.center;
    CGPoint startPoint;
    
    if ([sender state] == UIGestureRecognizerStateBegan
        ) {
        self.dotImageView.hidden = false;
        self.setButton.hidden = false;
        [self.timer invalidate];
        [self.CountdownTimer invalidate];
        startPoint = [sender locationInView:self.clockTopView];
    }
    
    if ([sender state] == UIGestureRecognizerStateChanged) {
        CGPoint currentPoint = [sender locationInView:self.clockTopView];
        CGPoint currentDotCenter = self.dotImageView.center;
        CGFloat radiusToClockCenter = sqrtf(powf(currentPoint.x - clockCenterPoint.x, 2.0) + powf(currentPoint.y - clockCenterPoint.y, 2.0));
        CGFloat xMovement = (98.5 / radiusToClockCenter) * (currentPoint.x - clockCenterPoint.x) + 4;
        CGFloat yMovement = (98.5 / radiusToClockCenter) * (currentPoint.y - clockCenterPoint.y) - 20;
        degreeThisRound = asin((xMovement - 4) / 98.5) / M_PI * 180;
        CGFloat xMovementCalibrited = xMovement - 4;
        CGFloat yMovementCalibrited = yMovement + 20;
        
        currentDotCenter.x = clockCenterPoint.x + xMovement;
        currentDotCenter.y = clockCenterPoint.y + yMovement;
        self.dotImageView.center = currentDotCenter;
        
        NSLog(@"Previous: (%lf, %lf)", previousXMovementCalibrited, previousYMovementCalibrited);
        NSLog(@"Current:  (%lf, %lf)", xMovementCalibrited, yMovementCalibrited);
        
        if (xMovementCalibrited >= 0 && yMovementCalibrited <= 0) {
            ;
        } else if ((xMovementCalibrited >= 0 && yMovementCalibrited >= 0)
                   || (xMovementCalibrited <= 0 && yMovementCalibrited >= 0)) {
            degreeThisRound = 180 - degreeThisRound;
        } else {
            degreeThisRound = 360 + degreeThisRound;
        }
        
        if ((previousXMovementCalibrited < 0 && previousYMovementCalibrited < 0)
            && (xMovementCalibrited >= 0 && yMovementCalibrited < 0)) {
            revolutionCount++;
        } else if ((previousXMovementCalibrited >= 0 && previousYMovementCalibrited < 0)
            && (xMovementCalibrited < 0 && yMovementCalibrited < 0)) {
            revolutionCount--;
        }
        revolutionCount = revolutionCount < -1 ? -1 : revolutionCount;
        degreeThisRound = revolutionCount == -1 ? 0.0 : degreeThisRound;
        
        NSLog(@"Degree this revolution: %lf", degreeThisRound);
        NSLog(@"Revolution Count:       %d", revolutionCount);
        NSLog(@"Degree total:           %lf", degreeThisRound + revolutionCount * 360);
        
        previousXMovementCalibrited = xMovementCalibrited;
        previousYMovementCalibrited = yMovementCalibrited;
        
        NSString *setTime = [NSString stringWithFormat:@"%d:%.2d", revolutionCount == -1 ? 0 : revolutionCount,
                             (int)degreeThisRound / 6];
        self.alarmTimeTextLabel.text = setTime;
        
        if (revolutionCount == -1) {
            timeInterval = degreeThisRound / 6 * 60;
        } else {
            timeInterval = degreeThisRound / 6 * 60 + revolutionCount * 3600;
        }
        timeInterval = (int)timeInterval / 60 * 60.0;
        NSLog(@"%ld", (long)timeInterval);
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *alarmTime = [[NSDate alloc] initWithTimeIntervalSinceNow:timeInterval];
        
        NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        units |= NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *currentComponents = [gregorian components:units fromDate:alarmTime];
        alarmTime = [gregorian dateFromComponents:currentComponents];
        
        //  format and display the time
        NSString *currentTimeString = [NSDateFormatter localizedStringFromDate:alarmTime
                                                                     dateStyle:NSDateFormatterNoStyle
                                                                     timeStyle:NSDateFormatterShortStyle];
        self.currentTimeTextLabel.text = currentTimeString;
    }
    
    if ([sender state] == UIGestureRecognizerStateEnded) {
        self.dotImageView.hidden = true;
    }
}

- (IBAction)setAlarm:(UIButton *)sender {
    [self setAlarmTime];
    self.setButton.hidden = true;
    
    previousXMovementCalibrited = 0.0;
    previousYMovementCalibrited = -98.5;
    revolutionCount = 0;
    degreeThisRound = 0.0;
}

- (void)setAlarmTime {
    if (timeInterval == 0) {
        return;
    }
    [self startCountDown];
}

- (void)startCountDown {
    self.CountdownTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                          interval:1
                                            target:self
                                          selector:@selector(countDown)
                                          userInfo:nil
                                           repeats:YES];
    self.countdownRunner = [NSRunLoop currentRunLoop];
    [self.countdownRunner addTimer:self.CountdownTimer forMode:NSDefaultRunLoopMode];
}

- (void)countDown {
    
    int hours = (int) timeInterval / 3600;
    int minutes = (int) timeInterval / 60 - hours * 60;
    int seconds = (int) timeInterval % 60;
    
    NSString *currentTimeString = [[NSString alloc] initWithFormat:@"%d:%.2d:%.2d", hours, minutes, seconds];
    self.alarmTimeTextLabel.text = currentTimeString;
    
    timeInterval--;
    if (timeInterval <= 0.0) {
        [self soundAlarm];
        timeInterval = 0;
    }
}

- (void)soundAlarm {
    NSLog(@"Times up!");
}

@end
