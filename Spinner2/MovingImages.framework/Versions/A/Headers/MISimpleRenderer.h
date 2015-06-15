//  MISimpleRenderer.h
//  MovieMaker
//
//  Created by Kevin Meaney on 03/11/2014.
//  Copyright (c) 2015 Zukini Ltd.

@import Foundation;
@import QuartzCore;

#import "MIReplyDictionary.h"

@class MIContext;

#pragma clang assume_nonnull begin

@interface MISimpleRenderer : NSObject

/// Assign variables which will be used when interpreting the draw dictionary.
@property (nullable, nonatomic, copy) NSDictionary *variables;

/// Instantiating the renderer. Designated initializer.
-(instancetype)initWithMIContext:(MIContext *)miContext;

// Convenience initializer.
-(instancetype)init;

/// Draw into the context. Assumes already oriented to bottom left is 0,0.
-(void)drawDictionary:(NSDictionary *)drawDict intoCGContext:(CGContextRef)context;

/// Assign an image to the image collection with identifier.
-(void)assignImage:(CGImageRef)image withIdentifier:(NSString *)identifier;

/// Remove image from image collection with identifier.
-(void)removeImageWithIdentifier:(NSString *)identifer;

@end

#pragma clang assume_nonnull end
