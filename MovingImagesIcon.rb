require 'moving_images'

include MovingImages
include MICGDrawing

def make_teardroppath()
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(0, 0)
  thePath.add_arc(centerPoint: centerPoint,
         radius: "0.479 * $iconwidth / (2.966 * $scalefactor)",
     startAngle: "pi_2() - asin(0.479 - 0.04)",
       endAngle: "asin(0.479 - 0.04) - pi_2()")

  centerPoint2 = MIShapes.make_point("$iconwidth / (2.966 * $scalefactor)", 0)
  thePath.add_arc(centerPoint: centerPoint2,
         radius: "0.04 * $iconwidth / (2.966 * $scalefactor)",
     startAngle: "asin(0.479 - 0.04) - pi_2()",
       endAngle: "pi_2() - asin(0.479 - 0.04)")
  thePath.add_closesubpath()

  startPoint = MIShapes.make_point(
        "$iconwidth / (2.966 * $scalefactor) * (1.0 + 0.04 * (0.479 - 0.04))",
        "$iconwidth / (2.966 * $scalefactor) * 0.04 * cos(asin(0.479 - 0.04))")
  return startPoint, thePath
end

def make_drawteardrop(transformations)
  startPoint, thePath = make_teardroppath()
  pathDrawElement = MIDrawElement.new(:fillpath)
  pathDrawElement.arrayofpathelements = thePath
  pathDrawElement.startpoint = startPoint
  pathDrawElement.contexttransformations = transformations
  pathDrawElement
end

def make_drawlogo()
  drawLogo = MIDrawElement.new(:arrayofelements)
  drawLogo.fillcolor = MIColor.make_rgbacolor(0.82, 0.53, 0.1)

  offset = MIShapes.make_point("-$iconwidth * ($scalefactor + 2.0) * 0.1667", 0)
  6.times do |i|
    transformations = MITransformations.make_contexttransformation()
    angle = i.to_f * 60.0 / 180.0 * Math::PI
    MITransformations.add_rotatetransform(transformations, angle)
    MITransformations.add_translatetransform(transformations, offset)
    drawElement = make_drawteardrop(transformations)
    drawLogo.add_drawelement_toarrayofelements(drawElement)
  end

  transformationIcon = MITransformations.make_contexttransformation()
  centrePoint = MIShapes.make_point("$width * 0.5",
                                    "$height * 0.5")
  MITransformations.add_translatetransform(transformationIcon, centrePoint)
  MITransformations.add_rotatetransform(transformationIcon, "$angle")
  drawLogo.contexttransformations = transformationIcon
  drawLogo
end

drawTearDrop = make_drawlogo()
puts JSON.pretty_generate(drawTearDrop.elementhash)
