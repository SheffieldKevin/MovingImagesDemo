require 'moving_images'

include MovingImages
include MICGDrawing

def make_zstroke()
  startPoint = MIShapes.make_point("0.01692 * $logowidth", 0)
  pathDrawElement = MIDrawElement.new(:fillpath)
  pathDrawElement.startpoint = startPoint
  
  thePath = MIPath.new
  centerPoint = MIShapes.make_point(
            "0.285 * $logowidth",
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
            "$logowidth * 0.9482")
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
         radius: "$logowidth * 0.20262",
     startAngle: Math::PI * 0.5 - 0.4545,
       endAngle: 0.4545 - Math::PI * 0.5)

  centerPoint2 = MIShapes.make_point("$logowidth * 0.423", 0)
  thePath.add_arc(centerPoint: centerPoint2,
         radius: "$logowidth * 0.01692",
     startAngle: 0.4545 - Math::PI * 0.5,
       endAngle: Math::PI * 0.5 - 0.4545)
  thePath.add_closesubpath()

  startPoint = MIShapes.make_point(
        "$logowidth * 0.43043",
        "$logowidth * 0.01520")
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

def make_drawlogo(inAngle, logowidth)
  drawLogo = MIDrawElement.new(:arrayofelements)
  drawLogo.fillcolor = MIColor.make_rgbacolor(0.05, 0.35, 0.05)

  transformations1 = MITransformations.make_contexttransformation()
  offset = MIShapes.make_point("$logowidth * 0.82438",
                               "0.20262 * $logowidth")
  MITransformations.add_translatetransform(transformations1, offset)
#  angle = "max($angle, 2.02) * 2.0 - 6.7271"
  angle = [inAngle, 2.02].max * 2.0 - 6.7271
  MITransformations.add_rotatetransform(transformations1, angle)
  drawElement1 = make_drawteardrop(transformations1)
  
  drawLogo.add_drawelement_toarrayofelements(drawElement1)
  transformations2 = MITransformations.make_contexttransformation()
  offset2 = MIShapes.make_point("0.2449 * $logowidth",
                                "$logowidth * 0.79738")
  MITransformations.add_translatetransform(transformations2, offset2)
#  angle2 = "min($angle, 2.02) * 2.0 + 0.4545"
  angle2 = [inAngle, 2.02].min * 2.0 + 0.4545
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



drawLogo = make_drawlogo(0, 600)
puts JSON.pretty_generate(drawLogo.elementhash)
