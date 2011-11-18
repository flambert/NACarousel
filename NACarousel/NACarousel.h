//
// NACarousel.h
// Carousel
//
// Created by Neil Ang on 23/11/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NACarousel;
@protocol NACarouselDelegate <NSObject>
@optional
- (void)carouselDidStart:(NACarousel *)carousel;
- (void)carouselDidStop:(NACarousel *)carousel;
- (BOOL)carousel:(NACarousel *)carousel willTransitionToImage:(NSUInteger)imageIndex of:(NSUInteger)imageCount; // Return NO to stop
@end

@interface NACarousel : UIView {
	@private
    __unsafe_unretained id<NACarouselDelegate> _delegate;
    
	NSMutableArray *_images;
	NSTimer        *_carouselTimer;

	BOOL _isTransitioning;
	BOOL _isStarted;

	float _transitionDuration;
	float _slideDuration;
}

- (void)addImage:(UIImage *)image;
- (void)addImageNamed:(NSString *)imageNamed;

- (void)next;
- (void)prev;
- (void)start;
- (void)stop;

@property (nonatomic, unsafe_unretained) id<NACarouselDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableArray *images;

@property (nonatomic, readonly) BOOL isTransitioning;
@property (nonatomic, readonly) BOOL isStarted;

@property (nonatomic) float transitionDuration;
@property (nonatomic) float slideDuration;

@end
