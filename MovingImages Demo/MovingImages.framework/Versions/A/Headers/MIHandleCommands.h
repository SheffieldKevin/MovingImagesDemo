//  MIHandleCommands.h
//  Created by Kevin Meaney on 23/07/2013.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.

@import Foundation;
@import CoreGraphics;

@class MIContext;
@class MICGImage;

#pragma clang assume_nonnull begin

/// Prepare Cocoa Lumberjack for logging messages.
void MIInitializeCocoaLumberjack();

/**
 @brief Command completion handler block definition. success is async op succeed.
 @discussion For the handle...Command asynchronous methods a completion handler
 can be called. The completion handler takes a single BOOL parameter and this
 parameter reflects whether the asynchronous command completed successfully or
 not.
*/
typedef void (^MICommandCompletionHandler)(NSDictionary *replyDict);

/**
 @brief Create a MIContext within which base objects can be created.
 @discussion Also manages variables and the image collection.
*/
MIContext *MICreateContext();

/**
 @brief Handle a single command.
 @discussion The command parameter should contains all the information needed to
 perform the command.
 @param command The command to be handled described by a NSDictionary.
 @param context The context within which the command should be performed. If nil
 then commands will be performed within the default context.
 @result A reply dictionary with properties specifying whether the command
 completed successfully or not, and a reply value.
*/
NSDictionary *MIMovingImagesHandleCommand(__nullable MIContext *context,
                                          NSDictionary *command);

/**
 @brief Handle the list of commands which can be run sync or ascynchronously.
 @discussion If commands are to be run asynchronously then you can also pass
 in a completion handler which will be run on the main queue when the commands
 complete. If the commands are to be run synchronously or don't need to run a
 completion handler then just pass in nil.
 @param commands A dictionary with option properties & command list property.
 @param context The context within which the commands should be handled. If nil
 then commands will be performed within the default context.
 @param handler The completion handler, to be run on main queue. can be nil.
 @result A dictionary. If the commands are run synchronously then dictionary
 returns whether the commands successfully completed, and contains optional
 results. If the commands are run asychronously then the dictionary will return
 whether setting up the commands to run asynchronously or not was successful.
*/
NSDictionary *MIMovingImagesHandleCommands(__nullable MIContext *context,
        NSDictionary *commands, __nullable MICommandCompletionHandler handler);

/**
 @brief Generate a MICGImage using object represented by objectDict and options.
 @discussion The contents of the option dictionary should change depending on
 the object described in objectDict. A bitmap context takes no options whereas
 a movie importer object requires the frame time to be specified, while an image
 importer object takes an optional image index. If none is supplied then an index
 of 0 is assumed.
 @param context The context which contains the object to get image from.
 @param objectDict  A dictionary with info to find the image source object
 @param imageOptions  An image options dictionary. Contents depends on receiver.
 @param cantBeThisObject    This object is not available to get the image from
 @result a MICGImage wrapping a CGImageRef and returns nil on failure.
*/
__nullable MICGImage *MICGImageFromObjectAndOptions(__nullable MIContext *context,
        NSDictionary *objectDict, __nullable NSDictionary *imageOptions,
        __nullable id cantBeThisObject);

/**
 @brief Generate a MICGImage based on the properties of the image dictionary.
 @discussion MICGImageFromDictionary will first see if it can obtain an
 image from the image collection in the context, but if the image identifier key
 is not specified then MICGImageFromDictionary will determine the object to
 create the image and get the image options from the image dictionary and then
 call MICGImageFromObjectAndOptions to create the image.
*/
__nullable MICGImage *MICGImageFromDictionary(__nullable MIContext *context,
        NSDictionary *imageDict, __nullable id cantBeThisObject);

#pragma clang assume_nonnull end
