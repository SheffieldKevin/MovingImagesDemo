require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

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

def make_videowithzukinilogo()
  # Constants
  logoSize = 128
  videoWidth = 1280
  videoHeight = 720
  instructionHash = {}
  begin
    setupCommands = SmigCommands.new
    movieImporter = setupCommands.make_createmovieimporter("DummyInputName.mov",
                                             addtocleanup: false, 
                                      pathsubstitutionkey: :movie1path)

    # since we want to see the progress in the demo application we can't
    # use the movie importer's process frames command. We would otherwise
    # not see the result
    # imageIdentifier = SecureRandom.uuid
    # processFramesCommand = ProcessFramesCommand.new(movieImporter)
    # processFramesCommand.create_localcontext = false
    # processFramesCommand.imageidentifier = imageIdentifier

    movieWriter = setupCommands.make_createvideoframeswriter(
                                          'DummyOutputName.mov',
                            addtocleanup: false,
                             utifiletype: 'com.apple.quicktime-movie',
                     pathsubstitutionkey: :exportfilepath)

    
    # track_id = MovieTrackIdentifier.make_movietrackid_from_mediatype(
    #                                            mediatype: :vide,
    #                                           trackindex: 0)
    
    # processFramesCommand.videotracks = [ track_id ]

    frameSize = MIShapes.make_size(videoWidth, videoHeight)
    frameDuration = MovieTime.make_movietime(timevalue: 1, timescale: 30)
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                    movieWriter,
                            preset: :h264preset_hd,
                         framesize: frameSize,
                     frameduration: frameDuration,
                     cleanaperture: nil,
                       scalingmode: nil)
    setupCommands.add_command(addVideoInputCommand)

    bitmap = setupCommands.make_createbitmapcontext(
                              size: frameSize,
                            preset: :PlatformDefaultBitmapContext,
                      addtocleanup: false)

    processCommands = SmigCommands.new
    processCommands.run_asynchronously = true

    nextFrameTime = MovieTime.make_movietime_nextsample()
    track_id = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                                mediatype: :vide,
                                               trackindex: 0)
    imageIdentifier = SecureRandom.uuid

    assignImageToCollection = CommandModule.make_assignimage_tocollection(
                                                    bitmap,
                                        identifier: imageIdentifier)

    destRect = MIShapes.make_rectangle(size: frameSize, xloc: 0, yloc: 0)

    # All the demo videos are 10 seconds long and at a frame rate of 30
    # frames a second that is 300 frames to process.
    numFrames = 280
    
    logoCenter = MIShapes.make_point(videoWidth - logoSize * 1.275,
                                     logoSize * 0.255)
    
    numFrames.times do |i|
#      assignImage = CommandModule.make_assignimage_frommovie_tocollection(
#                                        movieImporter,
#                             frametime: nextFrameTime,
#                                tracks: [ track_id ],
#                            identifier: imageIdentifier)
      drawImageElement = MIDrawImageElement.new
      drawImageElement.destinationrectangle = destRect
      drawImageElement.set_moviefile_imagesource(source_object: movieImporter, 
                                                     frametime: nextFrameTime, 
                                                        tracks: [ track_id ])
      drawImageCommand = CommandModule.make_drawelement(bitmap, 
                                drawinstructions: drawImageElement,
                                     createimage: false)
      processCommands.add_command(drawImageCommand)
      
      # Angle for teardrop on logo goes from 0 .. 4.04 and back again.
      logoMaxFrames = numFrames / 2
      angle = 0.0
      if i < logoMaxFrames 
        angle = 4.04 * (i % logoMaxFrames).to_f / (logoMaxFrames - 1).to_f
      else
        angle = 4.04*((numFrames-i-1)%logoMaxFrames).to_f/(logoMaxFrames-1).to_f
      end
      drawLogoElement = make_drawlogo(angle, logoSize, logoCenter)
      drawLogoCommand = CommandModule.make_drawelement(bitmap,
                                    drawinstructions: drawLogoElement,
                                         createimage: true)
      processCommands.add_command(drawLogoCommand)
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
    finalizeCommands.add_tocleanupcommands_closeobject(movieWriter)
    finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                          imageIdentifier)
    drawToView = MIDrawImageElement.new
    drawToView.set_imagecollection_imagesource(
                                  identifier: imageIdentifier)
    destinationRect = MIShapes.make_rectangle(
                                      size: frameSize,
                                      xloc: "($width - #{videoWidth}) * 0.5",
                                      yloc: "($height - #{videoHeight}) * 0.5")
    drawToView.destinationrectangle = destinationRect

    instructionHash = { setup: setupCommands.commandshash,
                      process: processCommands.commandshash,
                     finalize: finalizeCommands.commandshash,
             drawinstructions: drawToView.elementhash,
               exportfilename: "MovieWithLogo.mov"}
  end
  instructionHash
end

puts JSON.pretty_generate(make_videowithzukinilogo())
