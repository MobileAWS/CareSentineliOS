//
//  MawsTextView.m
//  CareSentineliOS
//
//  Created by Mike on 6/7/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "MawsTextView.h"
#import "UIKIT/UIKit.h"
#import "UIResources.h"

@implementation MawsTextView
@synthesize iconImage = _iconImage;
-(void)setIconImage:(UIImage *)iconImage{
    self->_iconImage = iconImage;
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = baseBackgroundColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(5, 5)];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    view.layer.mask = mask;
    UIImageView *left = [[UIImageView alloc] initWithImage:iconImage];
    left.translatesAutoresizingMaskIntoConstraints = false;
    [view addSubview:left];
    NSDictionary *arrayViews = @{@"image":left};
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[image]-5-|" options:0 metrics:nil views:arrayViews]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[image]-5-|" options:0 metrics:nil views:arrayViews]];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = view;
}

-(CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect rect = [super leftViewRectForBounds:bounds];
    return CGRectMake(rect.origin.x, rect.origin.y, self.bounds.size.height, self.bounds.size.height);
}


@end
