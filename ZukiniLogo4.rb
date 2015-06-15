require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule

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

def make_drawlogo(inAngle, bitmapSize, scaleFactor)
  logowidth = bitmapSize * scaleFactor
  drawLogo = MIDrawElement.new(:arrayofelements)
  drawLogo.fillcolor = MIColor.make_rgbacolor(0.05, 0.35, 0.05)

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
  offset3 = MIShapes.make_point((bitmapSize - logowidth * 1.07) * 0.5,
                                (bitmapSize - logowidth) * 0.5)
  MITransformations.add_translatetransform(transformations3, offset3)
  drawLogo.contexttransformations = transformations3
  drawLogo
end

def make_fillbackground_drawelement(bitmap, bitmapSize, color)
  rect = MIShapes.make_rectangle(xloc: 0, yloc: 0, size: bitmapSize)
  drawElement = MIDrawElement.new(:fillrectangle)
  drawElement.fillcolor = color
  drawElement.rectangle = rect
  drawElement.blendmode = :kCGBlendModeCopy
  drawElement
end

def make_giflogo()
  # Constants
  logoSize = 800
  bitmapSize = MIShapes.make_size(logoSize, logoSize)
  
  # Command list setup. The objects created in the setup commands we want to
  # remain after the setup commands have completed, so we will need to remember
  # to remove those objects in the finalize command.
  setupCommands = SmigCommands.new
  
  # Make the create bitmap context command.
  bitmap = setupCommands.make_createbitmapcontext(
                                    size: bitmapSize,
                                  preset: :PlatformDefaultBitmapContext,
                            addtocleanup: false)

  # Make the create export command.
  # The exporter needs to be created in the setup so that that individual
  # gif frames can be added to it in the processing commands.
  # The filename at this point will be replaced with a full path by the time
  # the finalize commands are being run.
  exporter = setupCommands.make_createexporter("ZukiniLogoAnimated.gif",
                                  export_type: :'com.compuserve.gif',
                                 addtocleanup: false)

  # A loopcount of 0 means repeat indefinitely.
  fileproperties = { '{GIF}' => { LoopCount: 0 } }
  addGIFFileproperty = CommandModule.make_set_objectproperty(
                                         exporter,
                            propertykey: :dictionary,
                          propertyvalue: fileproperties)
  setupCommands.add_command(addGIFFileproperty)

  processCommands = SmigCommands.new
  processCommands.run_asynchronously = true
  
  firstFrameHash = { :'{GIF}' => { DelayTime: 2.0 } }
  frameHash = { :'{GIF}' => { DelayTime: 0.1 } }

  rect = MIShapes.make_rectangle(xloc: 0, yloc: 0, size: bitmapSize)
  bColor = MIColor.make_rgbacolor(1,1,1, a: 1)
  drawBackElement = make_fillbackground_drawelement(bitmap, bitmapSize, bColor)
  
  # Create the drawing commands
  drawLogo = make_drawlogo(0.0, logoSize, 0.65)
  drawCommand = CommandModule.make_drawelement(bitmap,
                             drawinstructions: drawLogo)
  processCommands.add_command(drawCommand)
  
  imageIdentifier = SecureRandom.uuid
  
  assignImageToCollection = CommandModule.make_assignimage_tocollection(
                                                  bitmap,
                                      identifier: imageIdentifier)
  processCommands.add_command(assignImageToCollection)

  # Add the image to the exporter object
  add_image = CommandModule.make_addimage(exporter, bitmap)
  processCommands.add_command(add_image)

  addFrameProperty = CommandModule.make_set_objectproperties(exporter, 
      firstFrameHash, imageindex: 0)
  processCommands.add_command(addFrameProperty)

  numFrames = 30
  numFramesFInv = 1.0 / (numFrames.to_f - 1.0)
  numFrames.times do |i|
    # Create the drawing commands
    setBackground = CommandModule.make_drawelement(bitmap,
                                              drawinstructions: drawBackElement)
    processCommands.add_command(setBackground)
    drawLogo = make_drawlogo(4.04 * i.to_f * numFramesFInv, logoSize, 0.65)
    drawCommand = CommandModule.make_drawelement(bitmap,
                               drawinstructions: drawLogo)
    processCommands.add_command(drawCommand)

    processCommands.add_command(assignImageToCollection)

    # Add the image to the exporter object
    add_image = CommandModule.make_addimage(exporter, bitmap)
    processCommands.add_command(add_image)

    addFrameProperty = CommandModule.make_set_objectproperties(exporter, 
        frameHash, imageindex: i + 1)
    processCommands.add_command(addFrameProperty)
  end

  numFrames.times do |i|
    # Create the drawing commands
    setBackground = CommandModule.make_drawelement(bitmap,
                                              drawinstructions: drawBackElement)
    processCommands.add_command(setBackground)
    drawLogo = make_drawlogo(4.04 - 4.04 * i.to_f * numFramesFInv,
      logoSize, 0.65)
    drawCommand = CommandModule.make_drawelement(bitmap,
                               drawinstructions: drawLogo)
    processCommands.add_command(drawCommand)

    processCommands.add_command(assignImageToCollection)

    # Add the image to the exporter object
    add_image = CommandModule.make_addimage(exporter, bitmap)
    processCommands.add_command(add_image)

    addFrameProperty = CommandModule.make_set_objectproperties(exporter, 
        frameHash, imageindex: i + numFrames + 1)
    processCommands.add_command(addFrameProperty)
  end

  # Prepare the finalize commands
  finalizeCommands = SmigCommands.new
  setupExportPathSubstitution = CommandModule.make_set_objectproperty(
    exporter, propertykey: :file, propertyvalue: "~/Desktop/ZukiniLogo.gif")
  setupExportPathSubstitution.add_option(key: :pathsubstitution,
                                       value: :exportfilepath)
  finalizeCommands.add_command(setupExportPathSubstitution)
  finalizeCommands.add_command(CommandModule.make_export(exporter))
  finalizeCommands.add_tocleanupcommands_closeobject(bitmap)
  finalizeCommands.add_tocleanupcommands_closeobject(exporter)
  finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                              imageIdentifier)
  drawImageElement = MIDrawImageElement.new
  drawImageElement.set_imagecollection_imagesource(identifier: imageIdentifier)
  destinationRect = MIShapes.make_rectangle(size: bitmapSize,
                                      xloc: "($width - #{logoSize}) * 0.5",
                                      yloc: "($height - #{logoSize}) * 0.5")
  drawImageElement.destinationrectangle = destinationRect
  instructionHash = { setup: setupCommands.commandshash,
                    process: processCommands.commandshash,
                   finalize: finalizeCommands.commandshash,
           drawinstructions: drawImageElement.elementhash,
             exportfilename: "ZukiniLogo.gif"}
  instructionHash
end

puts JSON.pretty_generate(make_giflogo())
