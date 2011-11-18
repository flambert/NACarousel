//
// NACarousel.m
// Carousel
//
// Created by Neil Ang on 23/11/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import "NACarousel.h"
#import <QuartzCore/QuartzCore.h>

// Private methods
@interface NACarousel ()

- (void)transitionTo:(UIImageView *)newView;
- (UIImageView *)currentImageView;

@property (nonatomic, readwrite) BOOL isTransitioning;
@property (nonatomic, readwrite) BOOL isStarted;

@end

@implementation NACarousel

@synthesize delegate           = _delegate;
@synthesize images             = _images;
@synthesize isTransitioning    = _isTransitioning;
@synthesize isStarted          = _isStarted;
@synthesize transitionDuration = _transitionDuration;
@synthesize slideDuration      = _slideDuration;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		_images             = [[NSMutableArray alloc] initWithCapacity:2];
		_carouselTimer      = nil;
		_isTransitioning    = NO;
		_isStarted          = NO;
		_transitionDuration = 0.75f;
		_slideDuration      = 2.0f;
	}

	return self;
}

// Add an image to the array
- (void)addImage:(UIImage *)image {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

	// Hide each imageview except the first one
	imageView.hidden = [self.images count] ? YES : NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;

	[self.images addObject:imageView];
	[self addSubview:imageView];

#if !__has_feature(objc_arc)
  [imageView release];
#endif
}

// Add an image to the array
- (void)addImageNamed:(NSString *)imageNamed {
	UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNamed ofType:nil]];
    [self addImage:image];
    
#if !__has_feature(objc_arc)
    [image release];
#endif
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	self.isTransitioning = NO;
}

#pragma mark Carousel Controls

- (void)next {
	int current = [self.images indexOfObject:[self currentImageView]];
	int next    = current + 1;

	if (next >= [self.images count]) {
		next = 0;
	}
    
    if ([_delegate respondsToSelector:@selector(carousel:willTransitionToImage:of:)]) {
        BOOL transitionToNext = [_delegate carousel:self willTransitionToImage:next of:[self.images count]];
        if (!transitionToNext && self.isStarted) {
            [self stop];
            return;
        }
    }

	[self transitionTo:[self.images objectAtIndex:next]];
}

- (void)prev {
	int current = [self.images indexOfObject:[self currentImageView]];
	int prev    = current - 1;

	if (prev < 0) {
		prev = [self.images count] - 1;
	}

    if ([_delegate respondsToSelector:@selector(carousel:willTransitionToImage:of:)]) {
        BOOL transitionToNext = [_delegate carousel:self willTransitionToImage:prev of:[self.images count]];
        if (!transitionToNext && self.isStarted) {
            [self stop];
            return;
        }
    }
    
	[self transitionTo:[self.images objectAtIndex:prev]];
}

- (void)start {
	if (_carouselTimer == nil) {
		_carouselTimer = [NSTimer scheduledTimerWithTimeInterval:self.slideDuration target:self selector:@selector(next) userInfo:nil repeats:YES];
		self.isStarted = YES;
        
        if ([_delegate respondsToSelector:@selector(carouselDidStart:)])
            [_delegate carouselDidStart:self];
	}
}

- (void)stop {
	[_carouselTimer invalidate];
	self.isStarted = NO;
	_carouselTimer = nil;

    if ([_delegate respondsToSelector:@selector(carouselDidStop:)])
        [_delegate carouselDidStop:self];
}

#pragma mark Private methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIImageView* imageView in self.images) {
        imageView.frame = self.bounds;
    }
}

- (UIImageView *)currentImageView {
	for (UIImageView *imageView in self.images) {
		if (imageView.hidden == NO) {
			return imageView;
		}
	}

	return nil;
}

- (void)transitionTo:(UIImageView *)newView {
	// Don't transition if already in a transition
	if (self.isTransitioning) {
		return;
	}

	self.isTransitioning = YES;

	CATransition *transition = [CATransition animation];

	// Should these be properties? Most likely yes.
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type           = kCATransitionFade;

	transition.duration = self.transitionDuration;
	transition.delegate = self;

	[self.layer addAnimation:transition forKey:nil];

	[self currentImageView].hidden = YES;
	newView.hidden                 = NO;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    _delegate = nil;
	[_carouselTimer invalidate];
	[_images release];
	[super dealloc];
}
#endif

@end
