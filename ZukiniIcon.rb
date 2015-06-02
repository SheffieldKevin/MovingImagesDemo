require 'moving_images'

include MovingImages
include MICGDrawing

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

def make_drawlogo(iconwidth)
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
  modIconWidth = iconwidth * 1.35 # 1/1.35 = 0.74074074
  centrePoint = MIShapes.make_point(modIconWidth * 0.5, modIconWidth * 0.5)
  MITransformations.add_translatetransform(transformationIcon, centrePoint)
  MITransformations.add_rotatetransform(transformationIcon, 0.526)
  drawLogo.contexttransformations = transformationIcon
  drawLogo
end

drawTearDrop = make_drawlogo(370.0)
puts JSON.pretty_generate(drawTearDrop.elementhash)
