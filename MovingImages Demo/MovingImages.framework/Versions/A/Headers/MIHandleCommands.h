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
 @brief Completion handler block definition for MIMovingImagesHandleCommands()
 @discussion A block definition to be used as completion handler for the
 MIMovingImagesHandleCommands function. This is an optional parameter for the
 MIMovingImagesHandleCommands function. If the commands are to be run
 asynchronously and completion handler parameter is passed to the function then
 the completion handler block will be called when the last command is processed.
 @param replyDict This is the reply dictionary, the same as what is returned
 by MIMovingImagesHandleCommands if the commands are synchronously.
*/
typedef void (^MICommandCompletionHandler)(NSDictionary *replyDict);

/**
 @brief This block is called before each command is processed.
 @discussion The progress handler callback is an optional parameter for the 
 MIMovingImagesHandleCommand and if passed in is called before each command
 is processed. This callback can be used to update the variables dictionary
 before each command is processed or to update a progress handler.
*/
typedef void (^MIProgressHandler)(NSInteger commandIndex);

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
NSDictionary *MIMovingImagesHandleCommand(MIContext * __nullable context,
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
 @param progressHandler A progress handler, for progress & variables. Can be nil.
 @param handler The completion handler, to be run on main queue. can be nil.
 @result A dictionary. If the commands are run synchronously then dictionary
 returns whether the commands successfully completed, and contains optional
 results. If the commands are run asychronously then the dictionary will return
 whether setting up the commands to run asynchronously or not was successful.
*/
NSDictionary *MIMovingImagesHandleCommands(MIContext * __nullable context,
                                NSDictionary *commands,
                                __nullable MIProgressHandler progressHandler,
                                __nullable MICommandCompletionHandler handler);

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
 MICGImage * __nullable MICGImageFromObjectAndOptions(MIContext * __nullable context,
        NSDictionary *objectDict, NSDictionary * __nullable imageOptions,
        id __nullable cantBeThisObject);

/**
 @brief Generate a MICGImage based on the properties of the image dictionary.
 @discussion MICGImageFromDictionary will first see if it can obtain an
 image from the image collection in the context, but if the image identifier key
 is not specified then MICGImageFromDictionary will determine the object to
 create the image and get the image options from the image dictionary and then
 call MICGImageFromObjectAndOptions to create the image.
*/
MICGImage * __nullable MICGImageFromDictionary(MIContext * __nullable context,
        NSDictionary *imageDict, id __nullable cantBeThisObject);

/**
 @brief Get a Integer value from a string. Uses DDMathParser to get the number
 @param string [IN] The string to parse to get the value from.
 @param value [OUT] A pointer to a NSInteger that will be assigned the value.
 @param variablesDict [IN] A dictionary of variables and their values.
 @return YES on success. NO if fails to obtain NSInteger
 */
BOOL MIUtilityGetIntegerFromString(NSString *string, NSInteger *value,
                                   NSDictionary * __nullable variablesDict);

/**
 @brief Get a CGFloat value from a string. Uses DDMathParser to get the number
 @param string [IN] The string to parse to get the value from.
 @param value [OUT] A pointer to a CGFloat that will be assigned the value.
 @param variablesDict [IN] A dictionary of variables and their values.
 @return YES on success. NO if fails to obtain CGFloat
 */
BOOL MIUtilityGetFloatFromString(NSString *string, CGFloat *value,
                                 NSDictionary * __nullable variablesDict);

#pragma clang assume_nonnull end
