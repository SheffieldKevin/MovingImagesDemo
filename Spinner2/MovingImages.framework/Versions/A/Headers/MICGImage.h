//  MICGImage.h
//  MovieMaker
//
//  Copyright (c) 2015 Zukini Ltd.

@import Foundation;
@import CoreGraphics;

/**
 @brief A minimal CGImage wrapper object that will manage CGImage's lifetime
 @discussion This object is a lifetime managing object for a CGImageRef object
 within the context of ARC. The addtion of conforming to the NSCopying protocol
 and implementing the copy method is 
*/
@interface MICGImage : NSObject <NSCopying>

/// Copy initializer. Designated initializer.
-(nonnull instancetype)initWithMICGImage:(nonnull MICGImage *)image;

/// Initialize with a CGImageRef
-(nonnull instancetype)initWithCGImage:(nullable CGImageRef)image;

/// copy this object method.
-(nonnull instancetype)copy;

/// Returns the CGImage.
-(nullable CGImageRef)CGImage CF_RETURNS_NOT_RETAINED;

@end
