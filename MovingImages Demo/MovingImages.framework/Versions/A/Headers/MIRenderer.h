//  MIRenderer.h
//  MovieMaker
//
//  Copyright (c) 2015 Zukini Ltd.

#import <Foundation/Foundation.h>

#import "MIHandleCommands.h"
#import "MIReplyDictionary.h"

#pragma clang assume_nonnull begin

/// The key for the commands dictionary to setup drawing.
extern NSString *const MISetupDictionaryKey;

/// The key for the commands dictionary to do background drawing.
extern NSString *const MIBackgroundDrawDictionaryKey;

/// The key for the commands dictionary for commands to be run on main thread
extern NSString *const MIMainThreadDrawDictionaryKey;

/// The key for draw instructions to be drawn to current context on main thread
extern NSString *const MIDrawDictionaryKey;

/// The key for the commands dictionary for cleanup commands.
extern NSString *const MICleanupDictionaryKey;

@class MIContext;

/**
 @brief Draw into a cgcontext, but also do prepatory drawing as well.
 @discussion
*/
@interface MIRenderer : NSObject

/// The context that manages variables, images and base objects
@property (readonly, strong) MIContext *rendererContext;

/// Do we have as minimum draw instructions to be drawn.
@property (readonly) BOOL isReady;

/// The variables which will be used when interpreting the draw dictionary.
@property (nullable, nonatomic, copy) NSDictionary *variables;

/// Instantiate the renderer. Designated initializer.
-(instancetype)initWithMIContext:(MIContext *)miContext;

/// Instantiate the renderer. Convenience initializer.
-(instancetype)init;

/**
 @brief Configure sets up the various draw and cleanup dictionaries to be used.
 @discussion The only required sub dictionary is the dictionary obtained using
 the MIDrawDictionaryKey though you might as well use MISimpleRenderer if that
 is the case.
*/
-(BOOL)configure:(NSDictionary *)configDict;

/// Perform the setup commands and return the reply dictionary.
-(NSDictionary *)setupDrawing;

/// Perform the cleanup commands. Remove objects, clear images etc.
-(NSDictionary *)cleanup;

/**
 @brief Carry out the background drawing commands.
 @discussion These are commands that are intended to be run asynchronously on
 a work queue and not on the main thread. When the commands have completed
 successfully or not the completion handler will be called. Time consuming
 commands can be done here. Completion handler will be called on the main
 queue. Keep it simple.
*/
-(NSDictionary *)performBackgroundCommandsOnQueue:(dispatch_queue_t)workQueue
                completionHandler:(nullable MICommandCompletionHandler)handler;

/**
 @brief Perform commands that need to carried out immediately b4 drawIntoCGContext.
 @discussion If you need to perform commands that must be completed before
 drawing to the CGContext can happen then use this method to perform those
 commands. You should make sure none of the commands to be perfomed will take
 any significant time.
*/
-(NSDictionary *)performMainthreadCommands;

/**
 @brief Draw into a CGContext & return true on success.
 @discussion The drawIntoCGContext method can draw into any context, but
 is really intended for drawing into a window or view context (iOS/OSX) on
 the main thread.
*/
-(BOOL)drawIntoCGContext:(CGContextRef)context;

@end

#pragma clang assume_nonnull end
