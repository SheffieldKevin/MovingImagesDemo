require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

$perspectiveTransformFilterID = :'perspectivetransform.filter'
$videoWidth = 1280
$videoHeight = 720

def make_zstroke(logowidth)
  startPoint = MIShapes.make_point(0.01692 * logowidth, 0)
  pathDrawElement = MIDrawElement.new(:fillpath)
  pathDrawElement.startpoint = startPoint
  
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(
            0.285 * logowidth,
            0.0515 * logowidth)
  thePath.add_arc(centerPoint: centerPoint,
                       radius: 0.0515 * logowidth,
                   startAngle: -0.5 * Math::PI,
                     endAngle: -0.20 * Math::PI)
  centerPoint2 = MIShapes.make_point(logowidth * 1.06, logowidth * 0.98416)
  thePath.add_arc(centerPoint: centerPoint2,
                       radius: 0.01584 * logowidth,
                   startAngle: -0.16 * Math::PI,
                     endAngle: 0.5 * Math::PI)
  centerPoint3 = MIShapes.make_point(logowidth * 0.7915, logowidth * 0.9482)
  thePath.add_arc(centerPoint: centerPoint3,
                       radius: 0.0515 * logowidth,
                   startAngle: 0.5 * Math::PI,
                     endAngle: 0.8 * Math::PI)
  centerPoint4 = MIShapes.make_point(0.01584 * logowidth, 0.01584 * logowidth)
  thePath.add_arc(centerPoint: centerPoint4,
                       radius: 0.01584 * logowidth,
                   startAngle: 0.84 * Math::PI,
                     endAngle: -0.5 * Math::PI)
  thePath.add_closesubpath()
  pathDrawElement.arrayofpathelements = thePath
  pathDrawElement
end

def make_teardroppath(logowidth)
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(0, 0)
  thePath.add_arc(centerPoint: centerPoint,
         radius: logowidth * 0.20262,
     startAngle: Math::PI * 0.5 - 0.4545,
       endAngle: 0.4545 - Math::PI * 0.5)

  centerPoint2 = MIShapes.make_point(logowidth * 0.423, 0)
  thePath.add_arc(centerPoint: centerPoint2,
         radius: logowidth * 0.01692,
     startAngle: 0.4545 - Math::PI * 0.5,
       endAngle: Math::PI * 0.5 - 0.4545)
  thePath.add_closesubpath()

  startPoint = MIShapes.make_point(logowidth * 0.43043, logowidth * 0.01520)
  return startPoint, thePath
end

def make_drawteardrop(transformations, logowidth)
  startPoint, thePath = make_teardroppath(logowidth)
  pathDrawElement = MIDrawElement.new(:fillpath)
  pathDrawElement.arrayofpathelements = thePath
  pathDrawElement.startpoint = startPoint
  pathDrawElement.contexttransformations = transformations
  pathDrawElement
end

def make_drawlogo(inAngle, logoSize, centerPoint)
  logowidth = logoSize * 1.0
  drawLogo = MIDrawElement.new(:arrayofelements)
  drawLogo.fillcolor = MIColor.make_rgbacolor(0.05, 0.35, 0.05)

  drawBackgroundElement = MIDrawElement.new(:fillroundedrectangle)
  drawBackgroundElement.radius = 16
  backgroundColor = MIColor.make_rgbacolor(0.9, 0.9, 0.9, a: 0.5)
  drawBackgroundElement.fillcolor = backgroundColor
  bScale = 1.5
  backgroundRectangle = MIShapes.make_rectangle(
                                       width: logoSize * bScale,
                                      height: logoSize * bScale,
                                        xloc: -0.44 * (bScale - 1.0) * logoSize,
                                        yloc: -0.5 * (bScale - 1.0) * logoSize)
  drawBackgroundElement.rectangle = backgroundRectangle
  drawLogo.add_drawelement_toarrayofelements(drawBackgroundElement)

  transformations1 = MITransformations.make_contexttransformation()
  offset = MIShapes.make_point(logowidth * 0.82438, 0.20262 * logowidth)
  MITransformations.add_translatetransform(transformations1, offset)
  angle = [inAngle, 2.02].max * 2.0 - 6.7271
  MITransformations.add_rotatetransform(transformations1, angle)
  drawElement1 = make_drawteardrop(transformations1, logowidth)
  
  drawLogo.add_drawelement_toarrayofelements(drawElement1)
  
  transformations2 = MITransformations.make_contexttransformation()
  offset2 = MIShapes.make_point(0.2449 * logowidth, logowidth * 0.79738)
  MITransformations.add_translatetransform(transformations2, offset2)
  angle2 = [inAngle, 2.02].min * 2.0 + 0.4545
  MITransformations.add_rotatetransform(transformations2, angle2)
  drawElement2 = make_drawteardrop(transformations2, logowidth)
  
  drawLogo.add_drawelement_toarrayofelements(drawElement2)
  drawLogo.add_drawelement_toarrayofelements(make_zstroke(logowidth))

  transformations3 = MITransformations.make_contexttransformation()
  MITransformations.add_translatetransform(transformations3, centerPoint)
  drawLogo.contexttransformations = transformations3
  drawLogo
end

# While creating the filter chain we don't have to get the inputs that will
# vary each time the filter chain is rendered as they will be updated at 
# render time.
def make_perspectivetransformfilter(sourceBitmap, targetBitmap)
  filterChain = MIFilterChain.new(targetBitmap)
  filter = MIFilter.new(:CIPerspectiveTransform,
    identifier: $perspectiveTransformFilterID)

  # Setting keep static means that the image is held onto and even if the
  # source bitmap changes the input image remains unchanged.
  filter.add_inputimage_property(sourceBitmap, keep_static: false)

  # Need to work with idea of camera position. sourceBitmap has dimensions
  # 256 x 256. The render destination rectangle is centred on the frame
  # bitmap and is 256 x 256 pixels. Might need to think about playing with
  # source and destination rectangles as part rotated towards viewer will have
  # part of image render outside of destination. Lets ignore that for now.
  
  topLeftPoint = MIShapes.make_point(0, 256)
  topLeft = MIFilterProperty.make_civectorproperty_frompoint(
            key: :inputTopLeft, value: topLeftPoint)
  filter.add_property(topLeft)

  topRightPoint = MIShapes.make_point(256, 256)
  topRight = MIFilterProperty.make_civectorproperty_frompoint(
            key: :inputTopRight, value: topRightPoint)
  filter.add_property(topRight)

  bottomLeftPoint = MIShapes.make_point(0, 0)
  bottomLeft = MIFilterProperty.make_civectorproperty_frompoint(
            key: :inputBottomLeft, value: bottomLeftPoint)
  filter.add_property(bottomLeft)

  bottomRightPoint = MIShapes.make_point(256, 0)
  bottomRight = MIFilterProperty.make_civectorproperty_frompoint(
            key: :inputBottomRight, value: bottomRightPoint)
  filter.add_property(bottomRight)

  filterChain.add_filter(filter)
  filterChain
end

def render_filterchain(filterChain)
  renderFilter = MIFilterChainRender.new

  topLeftPoint = MIShapes.make_point("(#{$videoWidth} - $topwidth) * 0.5", 720)
  tL = MIFilterRenderProperty.make_renderproperty_pointvector_withfilternamid(
                               key: :inputTopLeft,
                             point: topLeftPoint,
                     filtername_id: $perspectiveTransformFilterID)
  renderFilter.add_filterproperty(tL)

  topRightPoint = MIShapes.make_point("(#{$videoWidth} + $topwidth) * 0.5", 720)
  tR = MIFilterRenderProperty.make_renderproperty_pointvector_withfilternamid(
                               key: :inputTopRight,
                             point: topRightPoint,
                     filtername_id: $perspectiveTransformFilterID)
  renderFilter.add_filterproperty(tR)

  bottomLeftPoint = MIShapes.make_point(0, 0)
  bL = MIFilterRenderProperty.make_renderproperty_pointvector_withfilternamid(
                               key: :inputBottomLeft,
                             point: bottomLeftPoint,
                     filtername_id: $perspectiveTransformFilterID)
  renderFilter.add_filterproperty(bL)

  bottomRightPoint = MIShapes.make_point(1280, 0)
  bR = MIFilterRenderProperty.make_renderproperty_pointvector_withfilternamid(
                               key: :inputBottomRight,
                             point: bottomRightPoint,
                     filtername_id: $perspectiveTransformFilterID)
  renderFilter.add_filterproperty(bR)
  theRect = MIShapes.make_rectangle(xloc: 0, yloc: "$bottom",
                                   width: 1280, height: "$top - $bottom")
  renderFilter.destinationrectangle = theRect
  renderCommand = CommandModule.make_renderfilterchain(filterChain,
    renderinstructions: renderFilter)
  renderCommand
end

def draw_text(theText, textBottom)
  drawStringElement = MIDrawBasicStringElement.new
  textBox = MIShapes.make_rectangle(xloc: 10,
                                    yloc: textBottom,
                                   width: 1260,
                                  height: 100)
  drawStringElement.boundingbox = textBox
  drawStringElement.fontsize = 72
  drawStringElement.fillcolor = MIColor.make_rgbacolor(1,1,1)
  drawStringElement.stringtext = theText
  drawStringElement.postscriptfontname = :'Tahoma-Bold'
  drawStringElement.textalignment = :kCTTextAlignmentCenter
  drawStringElement
end

# progress is a value from 0.0 to 1.0 and reflects how far through the
# video we are.
def draw_textbitmap(textBitmap, progress)
  drawElements = MIDrawElement.new(:arrayofelements)
  
  # First thing is need to make black transparent.
  makeTransparentElement = MIDrawElement.new(:fillrectangle)
  drawRect = MIShapes.make_rectangle(xloc: 0, yloc: 0, width: 1280, height: 720)
  makeTransparentElement.rectangle = drawRect
  makeTransparentElement.blendmode = :kCGBlendModeCopy
  transparentColor = MIColor.make_rgbacolor(0,0,0, a: 0)
  makeTransparentElement.fillcolor = transparentColor
  drawElements.add_drawelement_toarrayofelements(makeTransparentElement)
  
  moveDistance = 740.0
  textToDraw = [
    "Not very long ago",
    "In a garden",
    "close by, there was",
    "a shady border.",
    "",
    "The shady border",
    "contained plants like",
    "Astrantia, Damson,",
    "Sarcococca confusa",
    "Epimediums and Ferns"
  ]
  
  numTexts = textToDraw.count.to_f
  progressBase = moveDistance * progress
  textToDraw.count.times do |i|
#    textBase = progressBase - i.to_f * moveDistance / numTexts
    textBase = progressBase - i.to_f * 80
    drawStringElement = draw_text(textToDraw[i], textBase)
    drawElements.add_drawelement_toarrayofelements(drawStringElement)
  end
  drawCommand = CommandModule.make_drawelement(textBitmap,
                             drawinstructions: drawElements)
  drawCommand
end

def drawmovieframe_tobitmap(movie, bitmap, frametime)
  track_id = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                            mediatype: :vide,
                                           trackindex: 0)
  rect = MIShapes.make_rectangle(width: 1280, height: 720)
  drawFrameElement = MIDrawImageElement.new
  drawFrameElement.destinationrectangle = rect
  drawFrameElement.set_moviefile_imagesource(source_object: movie,
                                                 frametime: frametime,
                                                    tracks: [ track_id ])
  drawCommand = CommandModule.make_drawelement(bitmap,
                             drawinstructions: drawFrameElement)
  drawCommand
end

def make_applyfilter()
  # Constants
  instructionHash = {}
  begin
    setupCommands = SmigCommands.new
    movieImporter = setupCommands.make_createmovieimporter("~/DummyMovie.mov",
                                             addtocleanup: false, 
                                      pathsubstitutionkey: :movie1path)

    frameSize = MIShapes.make_size($videoWidth, $videoHeight)
    bitmap = setupCommands.make_createbitmapcontext(
                              size: frameSize,
                            preset: :PlatformDefaultBitmapContext,
                      addtocleanup: false)

    textBitmap = setupCommands.make_createbitmapcontext(
                              size: frameSize,
                            preset: :PlatformDefaultBitmapContext,
                      addtocleanup: false)

    perspectiveFilter = make_perspectivetransformfilter(textBitmap, bitmap)
    filterChain = setupCommands.make_createimagefilterchain(perspectiveFilter,
                                            addtocleanup: false)

    movieWriter = setupCommands.make_createvideoframeswriter(
                                          '~/DummyOutputName.mov',
                            addtocleanup: false,
                             utifiletype: 'com.apple.quicktime-movie',
                     pathsubstitutionkey: :exportfilepath)

    frameDuration = MovieTime.make_movietime(timevalue: 1201, timescale: 36000)
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                    movieWriter,
                            preset: :h264preset_hd,
                         framesize: frameSize,
                     frameduration: frameDuration,
                     cleanaperture: nil,
                       scalingmode: nil)
    setupCommands.add_command(addVideoInputCommand)

    drawElement = MIDrawElement.new(:fillrectangle)
    red = MIColor.make_rgbacolor(0.5, 0.0, 0.0)
    drawElement.fillcolor = red
    destRect = MIShapes.make_rectangle(size: frameSize)
    drawElement.rectangle = destRect
    drawRect = CommandModule.make_drawelement(bitmap,
                            drawinstructions: drawElement)
    setupCommands.add_command(drawRect)

    imageIdentifier = SecureRandom.uuid
    assignImageToCollection = CommandModule.make_assignimage_tocollection(
                                                    bitmap,
#                                                    textBitmap,
                                        identifier: imageIdentifier)
    setupCommands.add_command(assignImageToCollection)

    processCommands = SmigCommands.new
    processCommands.run_asynchronously = true

    # All the demo videos are 10 seconds long and at a frame rate of 29.97
    # frames a second that is 300 frames to process. There are two videos at
    # a slightly lower frame rate but I'm asking for frames at specific times
    # so every 10th frame will be repeated in output video.
    numFrames = 299
    
    numFrames.times do |i|
      fT = MovieTime.make_movietime(timevalue: 1001 * i,
                                           timescale: 30000)
      # nextFrame = MovieTime.make_movietime_nextsample()
      drawFrameCommand = drawmovieframe_tobitmap(movieImporter, bitmap, fT)
      processCommands.add_command(drawFrameCommand)
      progress = i.to_f / numFrames.to_f
      drawTextCommand = draw_textbitmap(textBitmap, progress)
      processCommands.add_command(drawTextCommand)
      processCommands.add_command(render_filterchain(filterChain))

      processCommands.add_command(assignImageToCollection)
      # All the drawing is done now. Need to add the drawing to the video writer
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
          movieWriter, sourceobject: bitmap)
      processCommands.add_command(addImageToWriterInput)
    end
    
    # The process commands are now done.
    # Create finalize commands list. Save the movie, close objects.
    finalizeCommands = SmigCommands.new
    saveMovie = CommandModule.make_finishwritingframescommand(movieWriter)
    finalizeCommands.add_command(saveMovie)
    finalizeCommands.add_tocleanupcommands_closeobject(movieImporter)
    finalizeCommands.add_tocleanupcommands_closeobject(bitmap)
    finalizeCommands.add_tocleanupcommands_closeobject(textBitmap)
    finalizeCommands.add_tocleanupcommands_closeobject(movieWriter)
    finalizeCommands.add_tocleanupcommands_closeobject(filterChain)
    finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                          imageIdentifier)
    drawToView = MIDrawImageElement.new
    drawToView.set_imagecollection_imagesource(
                                  identifier: imageIdentifier)

    scaleFactor = $videoHeight.to_f / $videoWidth.to_f
    destinationRect = MIShapes.make_rectangle(
                       width: "$width",
                      height: "$width * #{scaleFactor}",
                        xloc: 0,
                        yloc: "($height - $width * #{scaleFactor}) * 0.5")
    drawToView.destinationrectangle = destinationRect

    variables = [
      {
        maxvalue: 200.0,
        variablekey: :topwidth,
        defaultvalue: 150.0,
        minvalue: 100.0
      },
      {
        maxvalue: 300.0,
        variablekey: :bottom,
        defaultvalue: 0.0,
        minvalue: 0.0
      },
      {
        maxvalue: 720.0,
        variablekey: :top,
        defaultvalue: 730.0,
        minvalue: 420.0
      }
    ]

    instructionHash = { setup: setupCommands.commandshash,
                      process: processCommands.commandshash,
                     finalize: finalizeCommands.commandshash,
             drawinstructions: drawToView.elementhash,
                    variables: variables,
               exportfilename: "TextWithPerspectiveMovie.mov"}
  end
  instructionHash
end

puts JSON.pretty_generate(make_applyfilter())
