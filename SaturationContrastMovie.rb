require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

$sourceImageFilterChainID = :'demo.zukinidemo.colorcontrols.videoframe'
$colorControlFilterID = :'colorcontrol.filter'

def make_colorcontrolfilter(targetBitmap)
  filterChain = MIFilterChain.new(targetBitmap)
#  filterChain.softwarerender = true
#  filterChain.use_srgbprofile = true
  filter = MIFilter.new(:CIColorControls, identifier: $colorControlFilterID)
  # Don't set property values at filter chain construction time. Default values
  # will be used but they'll be overridden at render time.
  # So we just need the input image identifier.
  image_identifier = SmigIDHash.make_imageidentifier($sourceImageFilterChainID)

  inputimage_property = MIFilterProperty.make_ciimageproperty(key: :inputImage,
    value: image_identifier)
  filter.add_property(inputimage_property)
  filterChain.add_filter(filter)
  filterChain
end

def make_applyfilter()
  # Constants
  videoWidth = 1280
  videoHeight = 720
  instructionHash = {}
  begin
    setupCommands = SmigCommands.new
    movieImporter = setupCommands.make_createmovieimporter("DummyInputName.mov",
                                             addtocleanup: false, 
                                      pathsubstitutionkey: :movie1path)

    frameSize = MIShapes.make_size(videoWidth, videoHeight)
    bitmap = setupCommands.make_createbitmapcontext(
                              size: frameSize,
                            preset: :PlatformDefaultBitmapContext,
                      addtocleanup: false)

    colorControlFilter = make_colorcontrolfilter(bitmap)
    filterChain = setupCommands.make_createimagefilterchain(colorControlFilter,
                                            addtocleanup: false)

    movieWriter = setupCommands.make_createvideoframeswriter(
                                          'DummyOutputName.mov',
                            addtocleanup: false,
                             utifiletype: 'com.apple.quicktime-movie',
                     pathsubstitutionkey: :exportfilepath)

    frameDuration = MovieTime.make_movietime(timevalue: 1001, timescale: 30000)
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
                                        identifier: imageIdentifier)
    setupCommands.add_command(assignImageToCollection)

    processCommands = SmigCommands.new
    processCommands.run_asynchronously = true

    track_id = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                                mediatype: :vide,
                                               trackindex: 0)

    # All the demo videos are 10 seconds long and at a frame rate of 29.97
    # frames a second that is 300 frames to process. There are two videos at
    # a slightly lower frame rate but I'm asking for frames at specific times
    # so every 10th frame will be repeated in output video.
    numFrames = 299
    
    numFrames.times do |i|
      frameTime = MovieTime.make_movietime(timevalue: 1001 * i,
                                           timescale: 30000)
      nextFrame = MovieTime.make_movietime_nextsample()

      assignImage = CommandModule.make_assignimage_frommovie_tocollection(
                                        movieImporter,
                             frametime: frameTime,
                                tracks: [ track_id ],
                            identifier: $sourceImageFilterChainID)
      processCommands.add_command(assignImage)

      renderFilter = MIFilterChainRender.new
      rPS = MIFilterRenderProperty.make_renderproperty_withfilternameid(
                                   key: :inputSaturation,
                                 value: '$saturation',
                           value_class: :NSNumber,
                         filtername_id: $colorControlFilterID)
      renderFilter.add_filterproperty(rPS)

      rPC = MIFilterRenderProperty.make_renderproperty_withfilternameid(
                                   key: :inputContrast,
                                 value: '$contrast',
                           value_class: :NSNumber,
                         filtername_id: $colorControlFilterID)
      renderFilter.add_filterproperty(rPC)

      renderCommand = CommandModule.make_renderfilterchain(filterChain,
        renderinstructions: renderFilter)
      processCommands.add_command(renderCommand)

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
    finalizeCommands.add_tocleanupcommands_closeobject(filterChain)
    finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                          imageIdentifier)
    drawToView = MIDrawImageElement.new
    drawToView.set_imagecollection_imagesource(
                                  identifier: imageIdentifier)

    scaleFactor = videoHeight.to_f / videoWidth.to_f
    destinationRect = MIShapes.make_rectangle(
                       width: "$width",
                      height: "$width * #{scaleFactor}",
                        xloc: 0,
                        yloc: "($height - $width * #{scaleFactor}) * 0.5")
    drawToView.destinationrectangle = destinationRect

    variables = [
      {
        maxvalue: 2.0,
        variablekey: :saturation,
        defaultvalue: 1.0,
        minvalue: 0.0
      },
      {
        maxvalue: 4.0,
        variablekey: :contrast,
        defaultvalue: 1.0,
        minvalue: 0.25
      }
    ]

    instructionHash = { setup: setupCommands.commandshash,
                      process: processCommands.commandshash,
                     finalize: finalizeCommands.commandshash,
             drawinstructions: drawToView.elementhash,
                    variables: variables,
               exportfilename: "SaturationContrastMovie.mov"}
  end
  instructionHash
end

puts JSON.pretty_generate(make_applyfilter())
