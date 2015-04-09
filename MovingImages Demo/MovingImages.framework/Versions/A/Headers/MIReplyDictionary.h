//  MIReplyDictionary.h
//  MovingImages
//
//  Created by Kevin Meaney on 30/07/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.

@import Foundation;

typedef NS_ENUM(NSInteger, MIReplyErrorEnum)
{
    MIReplyErrorNoError = 0,
    MIReplyErrorMissingOption = 254,
    MIReplyErrorInvalidObjectReference = 253,
    MIReplyErrorInvalidIndex = 252,
    MIReplyErrorOptionValueInvalid = 251,
    MIReplyErrorInvalidSubCommand = 250,
    MIReplyErrorMissingSubCommand = 249,
    MIReplyErrorOperationFailed = 248,
    MIReplyErrorUnknownProperty = 247,
    MIReplyErrorInvalidOption = 246,
    MIReplyErrorMissingProperty = 245,
    MIReplyErrorInvalidProperty = 244
};

#pragma clang assume_nonnull begin

/**
 @brief Creates a reply dictionary ready to be returned to the launch agent client
 @param replyString The reply value converted into a string if necessary.
 @param eCode   The reply error code from running command. 0 indicates no error.
 */
NSDictionary *MIMakeReplyDictionary(NSString *replyString, NSInteger eCode);

/**
 @brief Creates a reply dictionary ready to be returned to the launch agent client
 @param replyString The reply value converted into a string if necessary.
 @param eCode   The reply error code from running command. 0 indicates no error.
 @param numericValue If result of command is a numeric value.
*/
NSDictionary *MIMakeReplyDictionaryWithNumericValue(NSString *replyString,
                                                    NSInteger eCode,
                                                    NSNumber *numericValue);

/// Assumes no error, so creates a reply dictionary with a dictionary object.
NSDictionary *MIMakeReplyDictionaryWithDictionaryValue(NSDictionary *dictValue,
                                                       BOOL makeJSONString);

/// Make the reply dictionary taking an array of string results and an error code
NSDictionary *MIMakeReplyDictionaryWithArray(NSArray *replyList,
                                             NSNumber *eCode);

/// Gets the string representation of the result, and optionally the error code.
NSString *MIGetReplyValuesFromDictionary(NSDictionary *replyDictionary,
                                         MIReplyErrorEnum *returnVal);

/// Get the numeric result value of the command
NSNumber * __nullable MIGetNumericReplyValueFromDictionary(
                                                NSDictionary *replyDictionary);

/// Get the NSNumber error code from reply dictionary.
NSNumber *MIGetNSNumberErrorCodeFromReplyDictionary(NSDictionary *replyDict);

/**
 @brief Get the MIReplyErrorEnum error code value from the reply dictionary.
 @result Returns the error code value from the dictionary, if no value, then
 returns MIReplyErrorNoError
*/
MIReplyErrorEnum MIGetErrorCodeFromReplyDictionary(NSDictionary *replyDict);

/// Get the string value from the reply dictionary.
NSString *MIGetStringFromReplyDictionary(NSDictionary *replyDictionary);

/// Get the array of string/numeric values from the reply dictionary.
NSArray * __nullable MIGetStringArrayFromReplyDictionary(
                                                NSDictionary *replyDictionary);

/// Get the dictionary value from the reply dictionary
NSDictionary * __nullable MIGetDictionaryValueFromReplyDictionary(
                                                NSDictionary *replyDict);

#pragma clang assume_nonnull end
