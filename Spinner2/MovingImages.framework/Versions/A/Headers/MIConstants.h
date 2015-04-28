//  MIConstants.h
//
//  Created by Kevin Meaney on 31/07/2013.
//  Copyright (c) 2013-2014 Kevin Meaney. All rights reserved.

@import Foundation;

#pragma clang assume_nonnull begin

/// The image importer base object type. "imageimporter"
extern NSString *const MIImageImporterKey;

/// The image exporter base object type. "imageexporter"
extern NSString *const MIImageExporterKey;

/// The core image filter chain base object object type. "imagefilterchain"
extern NSString *const MIImageFilterKey;

/// The bitmap graphic context base object type. "bitmapcontext"
extern NSString *const MICGBitmapContextKey;

/// The pdf context base object type. "pdfcontext".
extern NSString *const MICGPDFContextKey;

/// The movie importer base object type. "movieimporter".
extern NSString *const MIMovieImporterKey;

/// The movie frame iterator base object type. "movieframeiterator"
// extern NSString *const MIMovieFrameIteratorKey;

/// The movie editor base object type. "movieeditor".
extern NSString *const MIMovieEditorKey;

/// The movie video frames writer base object type. "videoframeswriter"
extern NSString *const MIMovieVideoFramesWriterKey;

/// NSGraphicContext wrapper base object. "nsgraphicscontext"
extern NSString *const MINSGraphicContextKey;

/**
 @brief Presets for different types of bitmap and pdf contexts to be created.
 @discussion According to the Quartz 2D Programming Guide: Graphic Contexts.
 the following presets are supported pixel formats.
*/

/// Alpha only preset. 8 bits integer per pixel. "AlphaOnly8bpcInt"
extern NSString *const MIAlphaOnly8bpc8bppInteger; // no colour data.

/// Grayscale. No alpha. 8 bits integer per pixel. "Gray8bpcInt"
extern NSString *const MIGray8bpc8bppInteger; // single 8 bit grayscale.

/// Grayscale. No alpha. 16 bits integer per pixel. "Gray16bpcInt"
extern NSString *const MIGray16bpc16bppInteger; // single 16 bit grayscale.

/// Grayscale. No alpha. 32 bits float per pixel. "Gray32bpcFloat"
extern NSString *const MIGray32bpc32bppFloat; // single 32 bit float grayscale

/// RGB. No alpha. 8 bpc, 32bpp. Integer. "AlphaSkipFirstRGB8bpcInt". XRGB
extern NSString *const MIAlphaSkipFirstRGB8bpc32bppInteger;

/// RGB. No alpha. 8 bpc, 32bpp. Integer. "AlphaSkipLastRGB8bpcInt". RGBX
extern NSString *const MIAlphaSkipLastRGB8bpc32bppInteger;

/// RGB. Alpha. 8 bpc, 32bpp. Integer. "AlphaPreMulFirstRGB8bpcInt". aRGB
extern NSString *const MIAlphaPreMulFirstRGB8bpc32bppInteger;

/// RGB. Alpha. 8 bpc, 32bpp. Integer. "AlphaPreMulLastRGB8bpcInt". RGBa
extern NSString *const MIAlphaPreMulLastRGB8bpc32bppInteger;

/// RGB. Alpha. 16 bpc, 64bpp. Integer. "AlphaPreMulLastRGB16bpcInt" RGBa
extern NSString *const MIAlphaPreMulLastRGB16bpc64bppInteger;

/// RGB. No alpha. 16 bpc, 64bpp. Integer. "AlphaSkipLastRGB16bpcInt" RGBX
extern NSString *const MIAlphaSkipLastRGB16bpc64bppInteger;

/// RGB. No alpha. 32 bpc. 128bpp. Float. "AlphaSkipLastRGB32bpcFloat" RGBX
extern NSString *const MIAlphaSkipLastRGB32bpc128bppFloat;

/// RGB. No alpha. 32 bpc. 128bpp. Float. "AlphaPreMulLastRGB32bpcFloat" RGBa
extern NSString *const MIAlphaPreMulLastRGB32bpc128bppFloat;

/// CMYK. 8 bpc. 32 bpp. Integer. "CMYK8bpcInt" CMYK
extern NSString *const MICMYK8bpc32bppInteger;

/// CMYK. 16 bpc. 64 bpp. Integer. "CMYK16bpcInt" CMYK
extern NSString *const MICMYK16bpc64bppInteger;

/// CMYK. 32 bpc. 128 bpp. Integer. "CMYK32bpcFloat" CMYK
extern NSString *const MICMYK32bpc128bppFloat;

/// BGRA. Alpha. 8bpc, 32bpp. Integer. "AlphaPreMulBGRA8bpcInt" BGRA
extern NSString *const MIAlphaPreMulBGRA8bpc32bppInteger; //BGRA

/**
 @brief The platform default bitmap context.
 @discussion On iOS the preferred bitmap context is BGRA 8bpc whilst on OSX
 the preferred bitmap context ARGB 8bpc. On OSX This maps to 
 MIAlphaPreMulFirstRGB8bpc32bppInteger whilst on iOS this maps to
 MIAlphaPreMulBGRA8bpc32bppInteger.
*/
extern NSString *const MIPlatformDefaultBitmapContext;

/**
 @brief An error message key.
 @discussion If the following key exists in a dictionary returned by any of the
 base objects then an error occured.
*/
extern NSString *const MIErrorMessageKey;

NSArray *MICGBitmapGetPresetList();

#pragma clang assume_nonnull end
