require 'moving_images'

include MovingImages
include MICGDrawing

# Variables for teardrop.
#  * logowidth: the width of the logo in pixels
#  * fraction: size of teardrop main stroke as fraction of logowidth. 0.2 - 0.6
#  * 0.479: Radius of large arc.
#  * 0.04: Radius of small arc.
def make_teardroppath()
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(0, 0)
  thePath.add_arc(centerPoint: centerPoint,
         radius: "0.479 * $iconwidth * $fraction",
     startAngle: "pi_2() - asin(0.479 - 0.04)",
       endAngle: "asin(0.479 - 0.04) - pi_2()")

  centerPoint2 = MIShapes.make_point("$iconwidth * $fraction", 0)
  thePath.add_arc(centerPoint: centerPoint2,
         radius: "0.04 * $iconwidth * $fraction",
     startAngle: "asin(0.479 - 0.04) - pi_2()",
       endAngle: "pi_2() - asin(0.479 - 0.04)")
  thePath.add_closesubpath()

  startPoint = MIShapes.make_point(
        "$iconwidth * $fraction * (1.0 + 0.04 * (0.479 - 0.04))",
        "$iconwidth * $fraction * 0.04 * cos(asin(0.479 - 0.04))")
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
  drawLogo.fillcolor = MIColor.make_rgbacolor(0.8, 0.42, 0.14)

  offset = MIShapes.make_point("-$iconwidth * $fraction * 1.2", 0)
  6.times do |i|
    transformations = MITransformations.make_contexttransformation()
    angle = i.to_f * 60.0 / 180.0 * Math::PI
    MITransformations.add_rotatetransform(transformations, angle)
    MITransformations.add_translatetransform(transformations, offset)
    drawElement = make_drawteardrop(transformations)
    drawLogo.add_drawelement_toarrayofelements(drawElement)
  end

  transformations3 = MITransformations.make_contexttransformation()
  offset3 = MIShapes.make_point("$width * 0.5",
                                "$height * 0.5")
  MITransformations.add_translatetransform(transformations3, offset3)
  drawLogo.contexttransformations = transformations3
  drawLogo
end

drawTearDrop = make_drawlogo()
puts JSON.pretty_generate(drawTearDrop.elementhash)
