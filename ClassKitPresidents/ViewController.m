//
//  ViewController.m
//  ClassKitPresidents
//
//  Created by Mitch Cohen on 4/12/18.
//  Copyright © 2018 Proactive Interactive, LLC. All rights reserved.
//

#import "ViewController.h"
#import "MSCElections.h"
#import "AppDelegate.h"
#import "ClassKitPresidents-Swift.h"

@interface ViewController ()

@property (nonatomic, strong) MSCElections *elections;
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;
@property (strong, nonatomic) IBOutlet UILabel *winnerLabel;

@property (strong, nonatomic) IBOutlet UILabel *triviaQuestionLabel;
@property (strong, nonatomic) IBOutlet UIButton *triviaYesButton;
@property (strong, nonatomic) IBOutlet UIButton *trviaNoButtonPressed;

@property (strong, nonatomic) IBOutlet UIButton *loserOneButton;
- (IBAction)loserOneButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *loserTwoButton;
- (IBAction)loserTwoButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *loserThreeButton;
- (IBAction)loserThreeButtonPressed:(id)sender;

@property (nonatomic, assign) NSInteger year;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSMutableArray *scores; //Array of NSNumber BOOL's
@property (nonatomic, assign) double score;
- (IBAction)doneButtonPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ClassKitManager.sharedInstance setupClassKit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshQuiz:) name:@"RefreshQuiz" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       [ClassKitManager.sharedInstance createContexts];

                       self.elections = [[MSCElections alloc] init];
                       AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                       if (appDelegate.year > 0) {
                           self.year = appDelegate.year;
                           [self setup];
                       } else {
                           NSLog(@"WARNING WARNING using manual year selection!!!");
                           [self setupWithManualYear];
                       }
                   });
}

-(void)refreshQuiz:(NSNotification *)notification {
    self.elections = [[MSCElections alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.year = appDelegate.year;
    [self setup];
}

-(void)setupWithManualYear {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose the year" message:@"Choose the year for your quiz" preferredStyle:UIAlertControllerStyleAlert];
    for (NSString *year in self.elections.years) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:year style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.year = [year integerValue];
            [self setup];
        }];
        [alertController addAction:action];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setup {
    self.yearLabel.text = [NSString stringWithFormat:@"%@",@(self.year)];
    self.winnerLabel.text = [self.elections winnerForYear:self.year];
    [self.loserOneButton setTitle:[self.elections loserForYear:self.year] forState:UIControlStateNormal];
    NSArray *losers = [self.elections allLosersExceptYear:self.year];
    [self.loserTwoButton setTitle:losers[0] forState:UIControlStateNormal];
    [self.loserThreeButton setTitle:losers[1] forState:UIControlStateNormal];
    self.triviaQuestionLabel.text = [self.elections triviaQuestionForYear:self.year];
    [ClassKitManager.sharedInstance startActivityForContextWithContext:ClassKitManager.sharedInstance.currentContext];
    self.date = [NSDate date];
    self.score = 0;
    self.scores = [@[[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]] mutableCopy];
}

-(void)calculateResultForLoserQuestion:(NSString *)chosenAnswer {
    NSString *rightAnswer = [self.elections loserForYear:self.year];
    if ([chosenAnswer isEqualToString:rightAnswer]) {
        [self showAlertWithString:@"Right!"];
        self.scores[0] = [NSNumber numberWithBool:YES];
    } else {
        [self showAlertWithString:@"Wrong!"];
        self.scores[0] = [NSNumber numberWithBool:NO];
    }
    [self calculateScore];
}

- (IBAction)loserOneButtonPressed:(UIButton *)sender {
    NSString *chosenAnswer = [sender titleForState:UIControlStateNormal];
    [self calculateResultForLoserQuestion:chosenAnswer];
}
- (IBAction)loserTwoButtonPressed:(UIButton *)sender {
    NSString *chosenAnswer = [sender titleForState:UIControlStateNormal];
    [self calculateResultForLoserQuestion:chosenAnswer];
}
- (IBAction)loserThreeButtonPressed:(UIButton *)sender {
    NSString *chosenAnswer = [sender titleForState:UIControlStateNormal];
    [self calculateResultForLoserQuestion:chosenAnswer];
}

-(void)calculateResultForTriviaQuestion:(NSString *)chosenAnswer {
    NSString *rightAnswer = [self.elections triviaAnswerForYear:self.year];
    if ([chosenAnswer isEqualToString:rightAnswer]) {
        [self showAlertWithString:@"Right!"];
        self.scores[1] = [NSNumber numberWithBool:YES];
    } else {
        [self showAlertWithString:@"Wrong!"];
        self.scores[1] = [NSNumber numberWithBool:NO];
    }
    [self calculateScore];
}

-(IBAction)setTriviaYesButtonPressed:(UIButton *)sender {
    NSString *chosenAnswer = [sender titleForState:UIControlStateNormal];
    [self calculateResultForTriviaQuestion:chosenAnswer];
}

-(IBAction)setTriviaNoButtonPressed:(UIButton *)sender {
    NSString *chosenAnswer = [sender titleForState:UIControlStateNormal];
    [self calculateResultForTriviaQuestion:chosenAnswer];
}

-(double)calculateScore {
    self.score = 0;
    for (NSNumber *thisScore in self.scores) {
        if ([thisScore boolValue] == YES) {
            self.score++;
        }
    }
    double scoreValue = self.score / self.scores.count;
    NSLog(@"Score value: %@",@(scoreValue));
    return scoreValue;
}

- (IBAction)doneButtonPressed:(id)sender {
    double calculatedScore = [self calculateScore];
    [ClassKitManager.sharedInstance setScoreWithScore:calculatedScore];
    NSString *scoreAsPercentage = [NSString stringWithFormat:@"Your score is %@%%",@((calculatedScore * 100))];
    [self showAlertWithString:scoreAsPercentage];
}

-(void)showAlertWithString:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end
