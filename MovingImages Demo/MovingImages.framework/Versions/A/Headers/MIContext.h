//  MIContext.h
//  Zukini.
//
//  Copyright (c) 2015 Kevin Meaney

@import Foundation;
@import CoreGraphics;

typedef NSInteger MIBaseReference;
extern const MIBaseReference kMIInvalidElementReference;

@class MIBaseObject;

/**
 @brief MIContext MovingImages context holding references to base objects
 @discussion Every base object that is a member of a MIContext has a base
 reference that is unique in that context and can be used to obtain a
 base object from the context. Every base object also has an object type and
 an object name. Objects can be obtained by their object type and name. This
 is not guaranteed to be unique (an object of a particular type can be given
 the same name as another object of the same type) but with judicious choice
 of object names then to all intents and purposes obtaining objects by their
 type and name can be reliable. A less reliable way of obtaining an object is
 via it's type and and type index. Deletion of other objects affects the
 object index so you might not get the object you expect. This approach
 should not be used.
*/
@interface MIContext : NSObject

@property (readonly) BOOL isEmpty;

/**
 @brief If a context is not specified then the default context will be used.
 @discussion This is the accessor to the default context which will always
 return the same context whenever it is called.
*/
+(MIContext *)defaultContext;

/// The designated initializer
-(instancetype)init;

/// Append a dictionary with keys for variable names & their associated values.
-(void)appendVariables:(NSDictionary *)variables;

/// Drop the last variables dictionary added.
-(void)dropVariablesDictionary:(NSDictionary *)dictToDrop;

/// Add image with identifier to the the image collection.
-(BOOL)assignCGImage:(CGImageRef)theImage identifier:(NSString *)identifier;

/// Remove image from the collection with identifier.
-(BOOL)removeImageWithIdentifier:(NSString *)identifier;

/// Get cg image from image collection with identifier.
-(CGImageRef)getCGImageWithIdentifier:
                                (NSString *)identifier CF_RETURNS_NOT_RETAINED;

@end
