//  MICGImage.h
//  MovieMaker
//
//  Created by Kevin Meaney on 16/01/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.

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

/// Retains the cgImage and releases previously owned cgimage.
-(void)setCGImage:(nullable CGImageRef)cgImage;

/// Returns the CGImage.
-(nullable CGImageRef)CGImage CF_RETURNS_NOT_RETAINED;

@end
