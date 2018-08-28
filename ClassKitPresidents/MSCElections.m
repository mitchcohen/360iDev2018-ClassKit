//
//  MSCElections.m
//  ClassKitPresidents
//
//  Created by Mitch Cohen on 7/12/18.
//  Copyright © 2018 Proactive Interactive, LLC. All rights reserved.
//

#import "MSCElections.h"
@import GameplayKit;

@interface MSCElections()

@property (nonatomic, strong) NSArray *elections;
@end

@implementation MSCElections

-(instancetype)init {
    self = [super init];
    if (self) {
        NSString *urlString = [[[NSBundle mainBundle] URLForResource:@"elections" withExtension:@"json"] absoluteString];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        NSError *error;
        self.elections = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        return self;
    } else {
        return nil;
    }
}

-(NSString *)winnerForYear:(NSInteger)year {
    for (NSDictionary *election in self.elections) {
        if ([election[@"year"] integerValue] == year) {
            return election[@"winner"];
        }
    }
    return nil;
}

-(NSString *)loserForYear:(NSInteger)year {
    for (NSDictionary *election in self.elections) {
        if ([election[@"year"] integerValue] == year) {
            return election[@"loser"];
        }
    }
    return nil;
}

-(NSString *)triviaQuestionForYear:(NSInteger)year {
    for (NSDictionary *election in self.elections) {
        if ([election[@"year"] integerValue] == year) {
            return election[@"triviaQuestion"];
        }
    }
    return nil;
}

-(NSString *)triviaAnswerForYear:(NSInteger)year {
    for (NSDictionary *election in self.elections) {
        if ([election[@"year"] integerValue] == year) {
            NSInteger answer = [election[@"trivialAnswer"] integerValue];
            if (answer == 1) {
                return @"Yes";
            } else {
                return @"No";
            }
        }
    }
    return nil;
}

-(NSArray *)allLosersExceptYear:(NSInteger)year {
    NSMutableArray *losers = [[NSMutableArray alloc] init];
    for (NSDictionary *election in self.elections) {
        NSString *thisLoser = election[@"loser"];
        if (![thisLoser isEqualToString:[self loserForYear:year]]) {
            [losers addObject:thisLoser];
        }
    }
    NSSet *set = [NSSet setWithArray:losers]; //Strip out duplicates, such as the ever-losing Charles Pinckney
    NSArray *losers2 = [set allObjects];

    return [losers2 shuffledArray];
}

-(NSArray *)years {
    NSMutableArray *years = [[NSMutableArray alloc] init];
    for (NSDictionary *election in self.elections) {
        NSInteger thisYear = [election[@"year"] integerValue];
        NSString *thisYearString = [NSString stringWithFormat:@"%@",@(thisYear)];
        [years addObject:thisYearString];
    }
    return years;
}

@end
