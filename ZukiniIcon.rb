require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule

def make_teardroppath(iconwidth)
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(0, 0)
  thePath.add_arc(centerPoint: centerPoint,
         radius: 0.18352 * iconwidth,
     startAngle: 1.11631,
       endAngle: -1.11631)

  centerPoint2 = MIShapes.make_point(iconwidth * 0.38313, 0)
  thePath.add_arc(centerPoint: centerPoint2,
         radius: 0.015325 * iconwidth,
     startAngle: -1.11631,
       endAngle: 1.11631)
  thePath.add_closesubpath()

  startPoint = MIShapes.make_point(iconwidth * 0.389858, iconwidth * 0.0137695)
  return startPoint, thePath
end

def make_drawteardrop(transformations, iconwidth)
  startPoint, thePath = make_teardroppath(iconwidth)
  pathDrawElement = MIDrawElement.new(:fillpath)
  pathDrawElement.arrayofpathelements = thePath
  pathDrawElement.startpoint = startPoint
  pathDrawElement.contexttransformations = transformations
  pathDrawElement
end

def make_drawlogo(bitmapsize)
  iconwidth = 0.74074074 * bitmapsize
  drawLogo = MIDrawElement.new(:arrayofelements)
  drawLogo.fillcolor = MIColor.make_rgbacolor(0.82, 0.53, 0.1)

  offset = MIShapes.make_point(-iconwidth * 0.480096, 0)
  6.times do |i|
    transformations = MITransformations.make_contexttransformation()
    angle = i.to_f * 60.0 / 180.0 * Math::PI
    MITransformations.add_rotatetransform(transformations, angle)
    MITransformations.add_translatetransform(transformations, offset)
    drawElement = make_drawteardrop(transformations, iconwidth)
    drawLogo.add_drawelement_toarrayofelements(drawElement)
  end

  transformationIcon = MITransformations.make_contexttransformation()
#  centrePoint = MIShapes.make_point("$width * 0.5", "$height * 0.5")
#  modIconWidth = iconwidth * 1.35 # 1/1.35 = 0.74074074
  centrePoint = MIShapes.make_point(bitmapsize * 0.5, bitmapsize * 0.5)
  MITransformations.add_translatetransform(transformationIcon, centrePoint)
  MITransformations.add_rotatetransform(transformationIcon, 0.526)
  drawLogo.contexttransformations = transformationIcon
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

def make_transparentpngicon()
  # Constants
  logoSize = 128
  bitmapSize = MIShapes.make_size(logoSize, logoSize)
  
  # Command list setup
  logoCommands = SmigCommands.new
  
  # Make the create bitmap context command
  bitmap = logoCommands.make_createbitmapcontext(size: bitmapSize,
                      preset: :PlatformDefaultBitmapContext)

  # Make the background transparent.
  color = MIColor.make_rgbacolor(0,0,0, a: 0)
  drawElement = make_fillbackground_drawelement(bitmap, bitmapSize, color)
  setBackgroundTransparent = CommandModule.make_drawelement(bitmap,
                                              drawinstructions: drawElement)
  logoCommands.add_command(setBackgroundTransparent)

  # Make the create export command.
  exporter = logoCommands.make_createexporter(
                      "~/Desktop/ZukiniIconTransparent#{logoSize}.png",
         export_type: :"public.png")

  # Create the drawing commands
  drawLogo = make_drawlogo(logoSize)
  drawCommand = CommandModule.make_drawelement(bitmap,
                             drawinstructions: drawLogo)
  logoCommands.add_command(drawCommand)
  
  # Add the image to the exporter object
  add_image = CommandModule.make_addimage(exporter, bitmap)
  logoCommands.add_command(add_image)
  
  # Export the Icon
  logoCommands.add_command(CommandModule.make_export(exporter))
  Smig.perform_commands(logoCommands)
end

make_transparentpngicon()

# drawTearDrop = make_drawlogo(370.0)
# puts JSON.pretty_generate(drawTearDrop.elementhash)
