//  MICoreImageJSONConstants.h
//  Moving Images
//
//  Created by Kevin Meaney on 30/01/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.
//

@import Foundation;

/**
 @brief The property containing the array of dictionaries describing CIFilters
 @discussion When the MICoreImage object is to be created a dictionary is passed
 is containing the information needed to build the filter chain and determine
 the the object that receives the rendering of the filter chain.
*/
extern NSString *const MICoreImageJSONKeyCIFilterList;

/// The property containing a dictionary from which we can get render destination
extern NSString *const MICoreImageJSONKeyRenderDestination;

/**
 @brief The name of the core image filter to create. "coreimagefiltername" string
 @discussion This is the core image name of the filter like "CIBoxBlur" or 
 "CIDifferenceBlend". Not the name of the filter to be used for identification
 purposes.
*/
extern NSString *const MICoreImageJSONKeyCIFilterName;

/**
 @brief Properties to be applied to CIFilter. "filterproperties" array of dicts
 @discussion After instantation a CIFilter object will have the default
 properties applied. It is only necessary to define the properties that need to
 be set to override the default properties in the filter. Each element in the
 array is a dictionary which defines the property to be set. The value to be
 applied, the key used to apply that value, for some properties that whose type
 is a class like CIColor or NSAffineTransform then the value to be applied will
 first need to be created from a string and converted into one of these objects
 before being applied. If the class is CIImage then the keys to define the object
 that the image comes need to be specified. These keys are defined in 
 MIJSONConstants and are: MIJSONKeyObjectReference: "objectreference",
 MIJSONKeyObjectName: "objectname", and MIJSONKeyObjectType: "objecttype". Or
 alternatively the key MICoreImageJSONKeyCIFilterSourceImagePrevious is
 defined and value set to YES which means that the source image is the output
 image of the previous filter in the filter chain. This is the mechanism for
 chaining the filters together.
*/
extern NSString *const MICoreImageJSONKeyCIFilterProperties;

#pragma mark Dictionary keys for applying a CIFilter property.

/**
 @brief The value to be applied to the filter. type is variable.
 @discussion This is the value that is to be applied to the filter, applied with
 the key MICoreImageJSONKeyCIFIlterValueKey. Most values will be of type
 NSNumber which can be directly assigned to the filter. However if the
 MICoreImageJSONKeyCIFIlterValueClass is defined in the dictionary then the
 dictionary value will be a string and we will need to convert the string into
 an object of type defined by MICoreImageJSONKeyCIFIlterValueClass.
*/
extern NSString *const MICoreImageJSONKeyCIFilterValue;

/// The class of the object to be applied to the filter (optional). string.
extern NSString *const MICoreImageJSONKeyCIFIlterValueClass;

/// The CIFilter key that is to be used when applying the property. string.
extern NSString *const MICoreImageJSONKeyCIFIlterValueKey;

/**
 @brief An index into the list of CIFilters in the MICoreImage object.
 @discussion This key is used when modifying CIFilter property values whilst
 handling the render filter chain command not when the filter chain is being
 built. The render command dictionary contains an array of filter properties
 that need to be modified before rendering happens. Each element of the array
 is a dictionary with properties that define the index to the filter to be
 modified, the property of the filter to be modified and the new value. There
 is also optionally a value class property which may be needed when the value
 in the dictionary needs to be converted to the correct type to be assigned
 to the filter.
 
 If the value class is CIImage then what will be modified is an image which
 is used as input to the filter. This relates to whether an image is static or
 not or whether a static image should be updated. Static images are not normally
 updated.
*/
extern NSString *const MICoreImageJSONKeyCIFilterIndex;

/**
 @brief Is the filter source image a static image. BOOL. (optional)
 @discussion This property is relevant when the image source is a context or
 video buffer etc. where the contents can change between each time the filter
 chain is rendered. For source images that come from an image importer or
 similar then the image at the source does not change over time these images
 are effectively static images already. The default value is NO. The default
 behaviour assumes that the filter chain wants to capture changes to the
 source image. By defining this property and setting its value to YES the
 captured image is not replaced when the context that it was originally generated
 from changes.
*/
extern NSString *const MICoreImageJSONKeyCIFilterSourceImageKeepStatic;

/**
 @brief Force an image otherwise set as static to be updated. BOOL.
 @discussion When an image is taken from a bitmap context for use
 in a filter chain the image for example, the default behaviour is  that
 if the bitmap context content is modified then the image is thrown away and
 the next time the filter chain is to be rendered a new image from the bitmap
 context is generated as input to the filter chain. This behaviour can be
 overriden so that the input image becomes a static image. There may be times
 when we want to force a new image to be generated from the bitmap context.
 This poperty provides the ability to do that.
*/
extern NSString *const MICoreImageJSONKeyCIFilterForceSourceImageUpdate;

/**
 @brief The name given to a filter for identification purposes.
 @discussion If you need to be able to identify a filter in the filter chain
 so that you can make the outputImage of the that filter an input for the
 current filter then you can give the filter an identifying name using this
 key and then the filter can be referred to by other filters in the same
 filter chain.
*/
extern NSString *const MICoreImageJSONKeyMIFilterName;
