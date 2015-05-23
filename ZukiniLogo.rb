require 'moving_images'

include MovingImages
include MICGDrawing

def make_zstroke()
  # The logo height is about 8% larger than width
  # radius1 is same as radius1 for the alternate tear drop.
  # radius2 is same as radius2 for the alternate tear drop.
  startPoint = MIShapes.make_point("0.04 * $fraction * $logowidth", 0)
  pathDrawElement = MIDrawElement.new(:fillpath)
  pathDrawElement.startpoint = startPoint
  
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(
            "$logowidth * 0.285",
            "0.0515 * $logowidth")
  thePath.add_arc(centerPoint: centerPoint,
                       radius: "0.0515 * $logowidth",
                   startAngle: -0.5 * Math::PI,
                     endAngle: -0.20 * Math::PI)
  centerPoint2 = MIShapes.make_point(
            "$logowidth * 1.06",
            "$logowidth * 0.98416")
  thePath.add_arc(centerPoint: centerPoint2,
                       radius: "0.01584 * $logowidth",
                   startAngle: -0.16 * Math::PI,
                     endAngle: 0.5 * Math::PI)
  centerPoint3 = MIShapes.make_point(
            "$logowidth * 0.7915",
            "$logowidth * 0.95")
  thePath.add_arc(centerPoint: centerPoint3,
                       radius: "0.0515 * $logowidth",
                   startAngle: 0.5 * Math::PI,
                     endAngle: 0.8 * Math::PI)
  centerPoint4 = MIShapes.make_point(
            "0.01584 * $logowidth",
            "0.01584 * $logowidth")
  thePath.add_arc(centerPoint: centerPoint4,
                       radius: "0.01584 * $logowidth",
                   startAngle: 0.84 * Math::PI,
                     endAngle: -0.5 * Math::PI)
  thePath.add_closesubpath()
  pathDrawElement.arrayofpathelements = thePath
  pathDrawElement
end

# Variables for teardrop.
#  * logowidth: the width of the logo in pixels
#  * fraction: size of teardrop main stroke as fraction of logowidth. 0.2 - 0.6
#  * r1: Radius of large arc, as a fraction of fraction. 0.2 - 0.5
#  * r2: Radius of small arc, as a fraction of fraction. 0.05 - 0.2
def make_teardroppath()
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(0, 0)
  thePath.add_arc(centerPoint: centerPoint,
         radius: "$logowidth * $fraction * $r1",
     startAngle: "pi_2() - asin($r1 - 0.04)",
       endAngle: "asin($r1 - 0.04) - pi_2()")

  centerPoint2 = MIShapes.make_point("$logowidth * $fraction", 0)
  thePath.add_arc(centerPoint: centerPoint2,
         radius: "$logowidth * $fraction * 0.04",
     startAngle: "asin($r1 - 0.04) - pi_2()",
       endAngle: "pi_2() - asin($r1 - 0.04)")
  thePath.add_closesubpath()

  startPoint = MIShapes.make_point(
        "$logowidth * $fraction * (1.0 + 0.04 * ($r1 - 0.04))",
        "$logowidth * $fraction * 0.04 * cos(asin($r1 - 0.04))")
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
  drawLogo.fillcolor = MIColor.make_rgbacolor(0.05, 0.35, 0.05)

  transformations1 = MITransformations.make_contexttransformation()
  offset = MIShapes.make_point("$logowidth * (1.027 - $fraction * $r1)",
                               "$fraction * $logowidth * $r1")
  MITransformations.add_translatetransform(transformations1, offset)
  angle = "$angle + asin($r1 - 0.04) - pi()"
  MITransformations.add_rotatetransform(transformations1, angle)
  drawElement1 = make_drawteardrop(transformations1)
  
  drawLogo.add_drawelement_toarrayofelements(drawElement1)
  transformations2 = MITransformations.make_contexttransformation()
  offset2 = MIShapes.make_point("$fraction * $logowidth * (0.1 + $r1)",
                                "$logowidth * (1.0 - $fraction * $r1)")
  MITransformations.add_translatetransform(transformations2, offset2)
  angle2 = "$angle + asin($r1 - 0.04)"
  MITransformations.add_rotatetransform(transformations2, angle2)
  drawElement2 = make_drawteardrop(transformations2)
  drawLogo.add_drawelement_toarrayofelements(drawElement2)
  drawLogo.add_drawelement_toarrayofelements(make_zstroke())
  transformations3 = MITransformations.make_contexttransformation()
  offset3 = MIShapes.make_point("($width - $logowidth) * 0.5",
                                "($height - $logowidth) * 0.5")
  MITransformations.add_translatetransform(transformations3, offset3)
  drawLogo.contexttransformations = transformations3
  drawLogo
end

drawTearDrop = make_drawlogo()
puts JSON.pretty_generate(drawTearDrop.elementhash)
