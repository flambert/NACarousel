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

- (void)transitionTo:(NSInteger)newIndex;

@property (nonatomic, readwrite) BOOL isTransitioning;
@property (nonatomic, readwrite) BOOL isStarted;

@end

@implementation NACarousel

@synthesize dataSource         = _dataSource;
@synthesize delegate           = _delegate;
@synthesize isTransitioning    = _isTransitioning;
@synthesize isStarted          = _isStarted;
@synthesize transitionDuration = _transitionDuration;
@synthesize slideDuration      = _slideDuration;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    
	if (self) {
        _currentImageView = [[UIImageView alloc] init];
        _currentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_currentImageView];
        
		_transitionDuration = 0.75f;
		_slideDuration      = 2.0f;
	}

	return self;
}

- (void)reloadData {
    _currentImageIndex = 0;
    
    if ([self.dataSource numberOfImagesInCarousel:self] > 0) {
        [self transitionTo:_currentImageIndex];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	self.isTransitioning = NO;
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [_currentImageView setContentMode:contentMode];
}

- (UIViewContentMode)contentMode {
    return [_currentImageView contentMode];
}

#pragma mark Carousel Controls

- (void)next {
	NSInteger next           = _currentImageIndex + 1;
    NSInteger numberOfImages = [self.dataSource numberOfImagesInCarousel:self];

	if (next >= numberOfImages) {
		next = 0;
	}
    
    if ([_delegate respondsToSelector:@selector(carousel:willTransitionToImage:of:)]) {
        BOOL transitionToNext = [_delegate carousel:self willTransitionToImage:next of:numberOfImages];
        if (!transitionToNext && self.isStarted) {
            [self stop];
            return;
        }
    }

	[self transitionTo:next];
}

- (void)prev {
	NSInteger prev           = _currentImageIndex - 1;
    NSInteger numberOfImages = [self.dataSource numberOfImagesInCarousel:self];

	if (prev < 0) {
		prev = numberOfImages - 1;
	}

    if ([_delegate respondsToSelector:@selector(carousel:willTransitionToImage:of:)]) {
        BOOL transitionToNext = [_delegate carousel:self willTransitionToImage:prev of:numberOfImages];
        if (!transitionToNext && self.isStarted) {
            [self stop];
            return;
        }
    }
    
	[self transitionTo:prev];
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
    _currentImageView.frame = self.bounds;
}

- (void)transitionTo:(NSInteger)newIndex {
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
    
    _currentImageIndex = newIndex;
    _currentImageView.image = [self.dataSource carousel:self imageForIndex:_currentImageIndex];
}

- (void)dealloc {
    _dataSource = nil;
    _delegate = nil;
	[_carouselTimer invalidate];
#if !__has_feature(objc_arc)
    [_carouselTimer release];
    [_currentImageView release];
	[super dealloc];
#endif
}

@end
