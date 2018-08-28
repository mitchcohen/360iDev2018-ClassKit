//
//  MSCElections.h
//  ClassKitPresidents
//
//  Created by Mitch Cohen on 7/12/18.
//  Copyright © 2018 Proactive Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCElections : NSObject
//@property (nonatomic, strong) NSArray *electionYears;
-(NSString *)winnerForYear:(NSInteger)year;
-(NSString *)loserForYear:(NSInteger)year;
-(NSString *)triviaQuestionForYear:(NSInteger)year;
-(NSString *)triviaAnswerForYear:(NSInteger)year;
-(NSArray *)allLosersExceptYear:(NSInteger)year;
-(NSArray *)years;
@end
