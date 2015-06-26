require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

# Variables are:
# $opacity Opacity of the swipe area.
# $red Red component of the swipe color.
# $green Green component of the swipe color.
# $blue Blue component of the swipe color.

$copyMachineTransitionFilterID = :'copymachinetransition.filter'
$videoWidth = 1280.0
$videoHeight = 720.0

# While creating the filter chain we don't have to get the inputs that will
# vary each time the filter chain is rendered as they will be updated at 
# render time. I'm not specifying the non image properties that will vary
# at render time as they will be specified then & default values will do for
# now.
def make_copymachinetransitionfilter(sourceImage, targetImage, targetBitmap)
  filterChain = MIFilterChain.new(targetBitmap)

  imageSourceID = SmigIDHash.make_imageidentifier(sourceImage)
  imageTargetID = SmigIDHash.make_imageidentifier(targetImage)
  filter = MIFilters::MITransitionFilter.new(:CICopyMachineTransition,
                                identifier: $copyMachineTransitionFilterID,
                                input_time: 0.0,
                        input_image_source: imageSourceID,
                  input_targetimage_source: imageTargetID)

  extentRect = MIShapes.make_rectangle(width: $videoWidth, height: $videoHeight)
  inputExtentProperty = MIFilterProperty.make_civectorproperty_fromrectangle(
    key: :inputExtent, value: extentRect)
  filter.add_property(inputExtentProperty)

  angleProperty = MIFilterProperty.make_cinumberproperty(key: :inputAngle, 
    value: 0.0)
  filter.add_property(angleProperty)

  widthProperty = MIFilterProperty.make_cinumberproperty(key: :inputWidth,
    value: 80.0)
  filter.add_property(widthProperty)

  filterChain.add_filter(filter)
  filterChain
end

def render_filterchain(filterChain, inputTime)
  renderFilter = MIFilterChainRender.new
  # Don't need to specify source or destination rectangle as the default is
  # to capture the complete area.
  
  # Even though the color property is the same each time because the color
  # component values are equations to be evaluated by having it listed in the
  # render chain it will cause it to be reevaluated at render time. Same goes
  # for opacity.
  inputColor = MIColor.make_rgbacolor("$red", "$green", "$blue")
  colorProperty = MIFilterRenderProperty.make_renderproperty_withfilternameid(
              key: :inputColor,
            value: inputColor,
    filtername_id: $copyMachineTransitionFilterID,
      value_class: :CIColor)
  renderFilter.add_filterproperty(colorProperty)
  
  opacityProperty = MIFilterRenderProperty.make_renderproperty_withfilternameid(
              key: :inputOpacity,
            value: "$opacity",
      value_class: :NSNumber,
    filtername_id: $copyMachineTransitionFilterID)
  renderFilter.add_filterproperty(opacityProperty)

  timeProperty = MIFilterRenderProperty.make_renderproperty_withfilternameid(
              key: :inputTime,
            value: inputTime,
    filtername_id: $copyMachineTransitionFilterID)
  renderFilter.add_filterproperty(timeProperty)

  renderCommand = CommandModule.make_renderfilterchain(filterChain,
    renderinstructions: renderFilter)
  renderCommand
end

def add_movieframe_tocollection(movie, collection_identifier: nil,
  frametime: nil)
  track_id = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                            mediatype: :vide,
                                           trackindex: 0)
  assignCommand = CommandModule.make_assignimage_frommovie_tocollection(movie,
       frametime: frametime,
          tracks: [ track_id ],
      identifier: collection_identifier)
  assignCommand
end

def drawmovieframe_tobitmap(movie, bitmap, frametime)
  track_id = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                            mediatype: :vide,
                                           trackindex: 0)
  rect = MIShapes.make_rectangle(width: $videoWidth, height: $videoHeight)
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
    movieImporter1 = setupCommands.make_createmovieimporter("~/DummyMovie.mov",
                                             addtocleanup: false, 
                                      pathsubstitutionkey: :movie1path)

    movieImporter2 = setupCommands.make_createmovieimporter("~/DummyMovie.mov",
                                             addtocleanup: false, 
                                      pathsubstitutionkey: :movie2path)

    frameSize = MIShapes.make_size($videoWidth, $videoHeight)
    bitmap = setupCommands.make_createbitmapcontext(
                              size: frameSize,
                            preset: :PlatformDefaultBitmapContext,
                      addtocleanup: false)

    sourceImageID = SecureRandom.uuid
    targetImageID = SecureRandom.uuid
    
    finalImageID = SecureRandom.uuid

    frameTime = MovieTime.make_movietime(timevalue: 0, timescale: 36000)
    assignCommand1 = add_movieframe_tocollection(movieImporter1,
            collection_identifier: sourceImageID,
                        frametime: frameTime)
    setupCommands.add_command(assignCommand1)

    assignCommand2 = add_movieframe_tocollection(movieImporter2,
            collection_identifier: targetImageID,
                        frametime: frameTime)
    setupCommands.add_command(assignCommand2)

    filterChainInstructions = make_copymachinetransitionfilter(sourceImageID,
      targetImageID, bitmap)

    filterChain = setupCommands.make_createimagefilterchain(
                filterChainInstructions, addtocleanup: false)

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

    assignImageToCollection = CommandModule.make_assignimage_tocollection(
                                                    bitmap,
                                        identifier: finalImageID)

    processCommands = SmigCommands.new
    processCommands.run_asynchronously = true

    frameDuration = MovieTime.make_movietime(timevalue: 1201, timescale: 36000)

    # First 60 frames movie 1, next 60 frames merging movies, last 60 frames
    # movie 2.
    
    numFrames1 = 60
    numFrames2 = 90
    numFrames3 = 60

    numFrames1.times do |i|
      fT = MovieTime.make_movietime(timevalue: 1201 * i, timescale: 36000)
#      add_movieframe_tocollection(movieImporter1,
#            collection_identifier: sourceImageID,
#                        frametime: frameTime)

      drawFrameCommand = drawmovieframe_tobitmap(movieImporter1, bitmap, fT)
      processCommands.add_command(drawFrameCommand)
      processCommands.add_command(assignImageToCollection)
      # All the drawing is done now. Need to add the drawing to the video writer
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
                                                           movieWriter,
                                imagecollectionidentifier: finalImageID,
                                            frameduration: frameDuration)
      processCommands.add_command(addImageToWriterInput)
    end

    numFrames2.times do |index|
      i = numFrames1 + index

      sFT = MovieTime.make_movietime(timevalue: 1201 * i, timescale: 36000)
      addMovieCommand1 = add_movieframe_tocollection(movieImporter1,
                              collection_identifier: sourceImageID,
                                          frametime: sFT)
      processCommands.add_command(addMovieCommand1)

      tFT = MovieTime.make_movietime(timevalue: 1201 * index, timescale: 36000)
      addMovieCommand2 = add_movieframe_tocollection(movieImporter2,
                              collection_identifier: targetImageID,
                                          frametime: tFT)
      processCommands.add_command(addMovieCommand2)

      inputTime = index.to_f / (numFrames2.to_f - 1.0)
      renderCommand = render_filterchain(filterChain, inputTime)
      processCommands.add_command(renderCommand)
      
      processCommands.add_command(assignImageToCollection)
      # All the drawing is done now. Need to add the drawing to the video writer
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
                                                           movieWriter,
                                imagecollectionidentifier: finalImageID)
      processCommands.add_command(addImageToWriterInput)
    end

    numFrames3.times do |index|
      i = numFrames2 + index
      fT = MovieTime.make_movietime(timevalue: 1201 * i, timescale: 36000)

      drawFrameCommand = drawmovieframe_tobitmap(movieImporter2, bitmap, fT)
      processCommands.add_command(drawFrameCommand)
      processCommands.add_command(assignImageToCollection)
      # All the drawing is done now. Need to add the drawing to the video writer
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
                                                           movieWriter,
                                imagecollectionidentifier: finalImageID,
                                            frameduration: frameDuration)
      processCommands.add_command(addImageToWriterInput)
    end

    # The process commands are now done.
    # Create finalize commands list. Save the movie, close objects.
    finalizeCommands = SmigCommands.new
    saveMovie = CommandModule.make_finishwritingframescommand(movieWriter)
    finalizeCommands.add_command(saveMovie)
    finalizeCommands.add_tocleanupcommands_closeobject(movieImporter1)
    finalizeCommands.add_tocleanupcommands_closeobject(movieImporter2)
    finalizeCommands.add_tocleanupcommands_closeobject(bitmap)
    finalizeCommands.add_tocleanupcommands_closeobject(movieWriter)
    finalizeCommands.add_tocleanupcommands_closeobject(filterChain)
    finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                          sourceImageID)
    finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                          targetImageID)
    finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                          finalImageID)

    drawToView = MIDrawImageElement.new

    drawToView.set_imagecollection_imagesource(
                                  identifier: finalImageID)
    scaleFactor = $videoHeight.to_f / $videoWidth.to_f
    destinationRect = MIShapes.make_rectangle(
                       width: "$width",
                      height: "$width * #{scaleFactor}",
                        xloc: 0,
                        yloc: "($height - $width * #{scaleFactor}) * 0.5")
=begin
    drawToView.set_bitmap_imagesource(source_object: logoBitmap)
    scaleFactor = $videoHeight.to_f / $videoWidth.to_f
    destinationRect = MIShapes.make_rectangle(
                       width: $zukiniLogoSize,
                      height: $zukiniLogoSize,
                        xloc: "($width - #{$zukiniLogoSize}) * 0.5",
                        yloc: "($height - #{$zukiniLogoSize}) * 0.5")
=end
    drawToView.destinationrectangle = destinationRect

    variables = [
      {
        maxvalue: 1.0,
        variablekey: :opacity,
        defaultvalue: 0.5,
        minvalue: 0.0
      },
      {
        maxvalue: 1.0,
        variablekey: :red,
        defaultvalue: 0.5,
        minvalue: 0.0
      },
      {
        maxvalue: 1.0,
        variablekey: :green,
        defaultvalue: 0.5,
        minvalue: 0.0
      },
      {
        maxvalue: 1.0,
        variablekey: :blue,
        defaultvalue: 0.5,
        minvalue: 0.0
      }
    ]

    instructionHash = { setup: setupCommands.commandshash,
                      process: processCommands.commandshash,
                     finalize: finalizeCommands.commandshash,
             drawinstructions: drawToView.elementhash,
                    variables: variables,
               exportfilename: "CopyMachineTransitionMovie.mov"}
  end
  instructionHash
end

f = "~/github/MovingImagesDemo/Zukini Demo/renderer_CopyMachineTransition.json"

fullPath = File.expand_path(f)

open(fullPath, 'w') { |f| f.puts JSON.pretty_generate(make_applyfilter()) }

# puts JSON.pretty_generate(make_applyfilter())

puts "Done"
