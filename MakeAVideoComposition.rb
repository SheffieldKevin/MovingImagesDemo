require 'moving_images'

# This script will pull in two movies and create two video tracks. The first
# transition will be from video track 0 to video track 1, and the second
# transition will be back to video track 0. First transition will be a simple
# dissolve ramp transition. The second transition will be transform ramp where
# video track 1 is gradually replaced by video track 0. 2 seconds.

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

# Variables are:
# $transdur1. min 0.5 max 2.5
# $transdur2. min 0.5 max 2.5

# The passthrough time period when 1 or another track is being is shown without
# any sort of transition is 2 seconds. The movie length will be:
# 3 * 2 seconds + transdur1 + transdur2

$videoWidth = 1280.0
$videoHeight = 720.0

def make_videocomposition()
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

    # Create the movie editor where the video composition will happen.
    movieEditorObject = setupCommands.make_createmovieeditor(
                                             addtocleanup: false)

    addVideoTrackCommand = CommandModule.make_createtrackcommand(
                                                movieEditorObject,
                                     mediatype: :vide)

    # Create two video tracks using the addVideoTrackCommand.
    setupCommands.add_command(addVideoTrackCommand)
    setupCommands.add_command(addVideoTrackCommand)

    bitmapSize = MIShapes.make_size(800, 600)
    # Need the bitmap to render the video composition diagram to.
    bitmap = setupCommands.make_createbitmapcontext(
                              size: bitmapSize,
                            preset: :PlatformDefaultBitmapContext,
                      addtocleanup: false,
                           profile: :kCGColorSpaceGenericRGB)

    processCommands = SmigCommands.new
    processCommands.run_asynchronously = true

    finalImageID = SecureRandom.uuid

    assignImageToCollection = CommandModule.make_assignimage_tocollection(
                                                    bitmap,
                                        identifier: finalImageID)

    track0 = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                        mediatype: :vide,
                                       trackindex: 0)

    track1 = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                        mediatype: :vide,
                                       trackindex: 1)

    timeZero = MovieTime.make_movietime(timevalue: 0, timescale: 1)
    inputDuration = MovieTime.make_movietime(timevalue: 10, timescale: 1)
    timeRange = MovieTime.make_movie_timerange(start: timeZero,
                                            duration: inputDuration)
    passThruDuration = MovieTime.make_movietime(timevalue:2, timescale:1)
    firstTansitionStartTime = MovieTime.make_movietime(timevalue:2, timescale:1)
    firstTransitionDuration = MovieTime.make_movietime_fromseconds(
                                                                   "$transdur1")
    secondPassThruStartTime = MovieTime.make_movietime_fromseconds(
                                                             "2.0 + $transdur1")
    secondTransitionStartTime = MovieTime.make_movietime_fromseconds(
                                                             "4.0 + $transdur1")
    secondTransitionDuration = MovieTime.make_movietime_fromseconds(
                                                                   "$transdur2")
    thirdPassThruStartTime = MovieTime.make_movietime_fromseconds(
                                                "4.0 + $transdur1 + $transdur2")
    thirdPassThruDuration = MovieTime.make_movietime_fromseconds(
                                              "6.0 - ($transdur1 + $transdur2)")

    # insert first track segment. Full length of first imported movie vid track.
    insertTrackSegmentCommand1 = CommandModule.make_inserttracksegment(
                            movieEditorObject, 
                     track: track0,
             source_object: movieImporter1,
              source_track: track0,
             insertiontime: MovieTime.make_movietime(timevalue:0, timescale:1), 
          source_timerange: timeRange)
    processCommands.add_command(insertTrackSegmentCommand1)
    
    # insert second track segment.
    insertTrackSegmentCommand2 = CommandModule.make_inserttracksegment(
                            movieEditorObject, 
                     track: track1,
             source_object: movieImporter2,
              source_track: track0,
             insertiontime: MovieTime.make_movietime(timevalue:0, timescale:1), 
          source_timerange: timeRange)
    processCommands.add_command(insertTrackSegmentCommand2)

    # Now create a pass thru instruction
    passThru1 = VideoLayerInstructions.new
    passThru1.add_passthrulayerinstruction(track: track0)
    passThru1TimeRange = MovieTime.make_movie_timerange(start: timeZero,
                                                    duration: passThruDuration)
    passThru1Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: passThru1TimeRange,
                                         layerinstructions: passThru1)
    processCommands.add_command(passThru1Command)

    dissolveTimeRange = MovieTime.make_movie_timerange(
                                               start: firstTansitionStartTime,
                                            duration: firstTransitionDuration)

    # Now create a dissolve ramp layer instruction.
    dissolveRamp = VideoLayerInstructions.new
    dissolveRamp.add_opacityramplayerinstruction(track: track0, 
                                     startopacityvalue: 1.0,
                                       endopacityvalue: 0.0,
                                             timerange: dissolveTimeRange)
    dissolveRamp.add_passthrulayerinstruction(track: track1)
    dissolveRampCommand = CommandModule.make_addvideoinstruction(
                                                      movieEditorObject,
                                           timerange: dissolveTimeRange,
                                   layerinstructions: dissolveRamp)
    processCommands.add_command(dissolveRampCommand)
    
    # Now create a pass thru instruction
    passThru2 = VideoLayerInstructions.new
    passThru2.add_passthrulayerinstruction(track: track1)
    passThru2TimeRange = MovieTime.make_movie_timerange(
                                              start: secondPassThruStartTime,
                                           duration: passThruDuration)
    passThru2Command = CommandModule.make_addvideoinstruction(
                                                       movieEditorObject,
                                            timerange: passThru2TimeRange,
                                    layerinstructions: passThru2)
    processCommands.add_command(passThru2Command)

    transformRampTimeRange = MovieTime.make_movie_timerange(
                                              start: secondTransitionStartTime,
                                           duration: secondTransitionDuration)
    
    startTransform = MITransformations.make_affinetransform()
    endTransform = MITransformations.make_contexttransformation()
    scaleXY = MIShapes.make_point(0.0, 1.0)
    MITransformations.add_scaletransform(endTransform, scaleXY)
    
    transformRamp = VideoLayerInstructions.new
    transformRamp.add_transformramplayerinstruction(track: track1,
                                starttransformvalue: startTransform,
                                  endtransformvalue: endTransform,
                                          timerange: transformRampTimeRange)
    transformRamp.add_passthrulayerinstruction(track: track0)
    transformRampCommand = CommandModule.make_addvideoinstruction(
                                                     movieEditorObject,
                                          timerange: transformRampTimeRange,
                                  layerinstructions: transformRamp)
    processCommands.add_command(transformRampCommand)

    # Now create a pass thru instruction
    passThru3 = VideoLayerInstructions.new
    passThru3.add_passthrulayerinstruction(track: track0)
    passThru3TimeRange = MovieTime.make_movie_timerange(
                                                start: thirdPassThruStartTime,
                                             duration: thirdPassThruDuration)
    passThru3Command = CommandModule.make_addvideoinstruction(
                                                       movieEditorObject,
                                            timerange: passThru3TimeRange,
                                    layerinstructions: passThru3)
    processCommands.add_command(passThru3Command)

    # Lets create a composition map image so that we can draw it in drawToView
    imageIdentifier = SecureRandom.uuid
    addCompositionImage = CommandModule.make_assignimage_tocollection(
                                                movieEditorObject,
                                    identifier: imageIdentifier)
    processCommands.add_command(addCompositionImage)

    # Now lets export the movie. This command may take some time so it is added
    # to process commands.
    exportMovieCommand = CommandModule.make_movieeditor_export(
                                              movieEditorObject,
                                exportpreset: :AVAssetExportPreset1280x720,
                              exportfilepath: "DummyPath.mov",
                              exportfiletype: :'com.apple.quicktime-movie',
                         pathsubstitutionkey: :exportfilepath)
    processCommands.add_command(exportMovieCommand)


    # The process commands are now done.
    # Create finalize commands list. Save the movie, close objects.
    finalizeCommands = SmigCommands.new
    finalizeCommands.add_tocleanupcommands_closeobject(movieImporter1)
    finalizeCommands.add_tocleanupcommands_closeobject(movieImporter2)
    finalizeCommands.add_tocleanupcommands_closeobject(bitmap)
    finalizeCommands.add_tocleanupcommands_closeobject(movieEditorObject)
    finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                          imageIdentifier)

    # Need to update this to display a view of the composition which has also 
    # been saved and to then overlay drawing of the file path to where the movie
    # is exported to.
    drawToView = MIDrawImageElement.new
    drawToView.set_imagecollection_imagesource(
                                  identifier: imageIdentifier)
    scaleFactor = 600.0 / 1000.0
    destinationRect = MIShapes.make_rectangle(
                       width: "$width",
                      height: "$width * #{scaleFactor}",
                        xloc: 0,
                        yloc: "($height - $width * #{scaleFactor}) * 0.5")

    drawToView.destinationrectangle = destinationRect

    variables = [
      {
        maxvalue: 2.5,
        variablekey: :transdur1,
        defaultvalue: 1.5,
        minvalue: 0.5
      },
      {
        maxvalue: 2.5,
        variablekey: :transdur2,
        defaultvalue: 1.5,
        minvalue: 0.5
      }
    ]

    instructionHash = { setup: setupCommands.commandshash,
                      process: processCommands.commandshash,
                     finalize: finalizeCommands.commandshash,
             drawinstructions: drawToView.elementhash,
                    variables: variables,
               exportfilename: "VideoCompositionMovie.mov"}
  end
  instructionHash
end

f = "~/github/MovingImagesDemo/Zukini Demo/renderer_MovieComposition.json"

fullPath = File.expand_path(f)

open(fullPath, 'w') { |f| f.puts JSON.pretty_generate(make_videocomposition()) }

# puts JSON.pretty_generate(make_applyfilter())

puts "Done"
