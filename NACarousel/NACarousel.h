//
// NACarousel.h
// Carousel
//
// Created by Neil Ang on 23/11/10.
// Copyright 2010 neilang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NACarousel;

@protocol NACarouselDataSource <NSObject>
@required
- (NSInteger)numberOfImagesInCarousel:(NACarousel *)carousel;
- (UIImage *)carousel:(NACarousel *)carousel imageForIndex:(NSInteger)index;
@end

@protocol NACarouselDelegate <NSObject>
@optional
- (void)carouselDidStart:(NACarousel *)carousel;
- (void)carouselDidStop:(NACarousel *)carousel;
- (BOOL)carousel:(NACarousel *)carousel willTransitionToImage:(NSInteger)imageIndex of:(NSInteger)imageCount; // Return NO to stop
@end

@interface NACarousel : UIView {
	@private
    __unsafe_unretained id<NACarouselDataSource> _dataSource;
    __unsafe_unretained id<NACarouselDelegate> _delegate;
    
	NSTimer     *_carouselTimer;
    NSInteger    _currentImageIndex;
    UIImageView *_currentImageView;

	BOOL _isTransitioning;
	BOOL _isStarted;

	float _transitionDuration;
	float _slideDuration;
}

- (void)reloadData;

- (void)next;
- (void)prev;
- (void)start;
- (void)stop;

@property (nonatomic, assign) id<NACarouselDataSource> dataSource;
@property (nonatomic, assign) id<NACarouselDelegate> delegate;

@property (nonatomic, readonly) BOOL isTransitioning;
@property (nonatomic, readonly) BOOL isStarted;

@property (nonatomic) float transitionDuration;
@property (nonatomic) float slideDuration;

@end
