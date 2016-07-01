//
//  GLGestureRecognizer.h
//
//  Created by Adam Preble on 4/28/09.  adam@giraffelab.com
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
@import UIKit;

@interface GLGestureRecognizer : NSObject

@property (nonatomic, strong) NSDictionary *templates;
@property (nonatomic, readonly) NSArray *touchPoints;
@property (nonatomic, readonly) NSArray *resampledPoints;

- (void)addTouchAtPoint:(CGPoint)point;
- (void)addTouches:(NSSet*)set fromView:(UIView *)view;
- (void)resetTouches;

- (NSString *)findBestMatch;
- (NSString *)findBestMatchCenter:(CGPoint*)outCenter angle:(float*)outRadians score:(float*)outScore mode:(int) mode key:(NSString*) key;
-(void) saveTemplateData;

//This is a move-around, because of an unknown reason, it's not possible to get Objective C constants in Swift files
-(int) cAdd;
-(int) cRemove;
-(int) cRead;
@end
