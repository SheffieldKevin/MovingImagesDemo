#!/usr/bin/env ruby
# Returns a path.
require 'moving_images'
include Math
include MovingImages

def make_arcpath(inBox: { size: { width: 120, height: 120 },
                        origin: { x: 0, y: 0 } },
                radius: 50.0)
  thePath = MIPath.new
  halfWidth = inBox[:size][:width] * 0.5
  halfHeight = inBox[:size][:height] * 0.5
  
  centerPoint = MIShapes.make_point(halfWidth + inBox[:origin][:x],
                                    halfHeight + inBox[:origin][:y])
  thePath.add_arc(centerPoint: centerPoint,
                       radius: radius,
                   startAngle: 1.25 * Math::PI,
                     endAngle: -0.25 * Math::PI,
                  isClockwise: true)
  return thePath
end

def make_arcpath_equation(inBox: { size: { width: 120, height: 120 },
                          origin: { x: 0, y: 0 } },
                radius: 50.0)
  thePath = MIPath.new
  halfWidth = inBox[:size][:width] * 0.5
  halfHeight = inBox[:size][:height] * 0.5
  
  centerPoint = MIShapes.make_point(halfWidth + inBox[:origin][:x],
                                    halfHeight + inBox[:origin][:y])
  scaleFactor = (1.5 * Math::PI)
  startAngle = 1.25 * Math::PI
  thePath.add_arc(centerPoint: centerPoint,
                       radius: radius,
                   startAngle: startAngle,
                     endAngle: "#{startAngle} - #{scaleFactor} * $controlValue",
                  isClockwise: true)
  return thePath
end

$radius = 54.0
$theWidth = 140.0
$theHeight = 140.0
$fontSize = 20

# Returns a draw element object command
def create_pathdrawelement(line_width: 16.0, stroke_color: nil)
  strokeColor = stroke_color unless stroke_color.nil?
  strokeColor =  MIColor.make_rgbacolor(0.2, 0.2, 0.2) if stroke_color.nil?
  arcBox = MIShapes.make_rectangle(width: $theWidth, height: $theHeight)
  startX = $theWidth * 0.5 + $radius * Math.sin(-0.75 * Math::PI)
  startY = $theHeight * 0.5 + $radius * Math.cos(-0.75 * Math::PI)
  startPoint = MIShapes.make_point(startX, startY)
  arcBBox = MIShapes.make_rectangle(width: $theWidth, height: $theHeight)
  thePath = make_arcpath(inBox: arcBBox, radius: $radius)
  pathDrawElement = MIDrawElement.new(:strokepath)
  pathDrawElement.arrayofpathelements = thePath
  pathDrawElement.startpoint = startPoint
  pathDrawElement.linewidth = line_width
  pathDrawElement.linecap = :kCGLineCapRound
  pathDrawElement.strokecolor = strokeColor
  pathDrawElement
end

def create_pathdrawelement_withequation(line_width: 16.0, stroke_color: nil)
  strokeColor = stroke_color unless stroke_color.nil?
  strokeColor =  MIColor.make_rgbacolor(0.2, 0.2, 0.2) if stroke_color.nil?
  arcBox = MIShapes.make_rectangle(width: $theWidth, height: $theHeight)
  startX = $theWidth * 0.5 + $radius * Math.sin(-0.75 * Math::PI)
  startY = $theHeight * 0.5 + $radius * Math.cos(-0.75 * Math::PI)
  startPoint = MIShapes.make_point(startX, startY)
  arcBBox = MIShapes.make_rectangle(width: $theWidth, height: $theHeight)
  thePath = make_arcpath_equation(inBox: arcBBox, radius: $radius)
  pathDrawElement = MIDrawElement.new(:strokepath)
  pathDrawElement.arrayofpathelements = thePath
  pathDrawElement.startpoint = startPoint
  pathDrawElement.linewidth = line_width
  pathDrawElement.linecap = :kCGLineCapRound
  pathDrawElement.strokecolor = strokeColor
  pathDrawElement
end

def create_drawtextelement()
  drawString = MIDrawBasicStringElement.new()
  drawString.stringtext = "Baskerville"
  drawString.textsubstitutionkey = "controltext"
  drawString.postscriptfontname= 'Baskerville'
  drawString.userinterfacefont = 'kCTFontUIFontSystem'
  drawString.fontsize = $fontSize
  drawString.textalignment = :kCTTextAlignmentCenter
  drawString.fillcolor = MIColor.make_rgbacolor(0,0,0)
  pathElementList = MIPath.new
  rectOrigin = MIShapes.make_point(0, ($theHeight - $fontSize) / 2.0)
  rectSize = MIShapes.make_size($theWidth, $fontSize + 6)
  pathRect = MIShapes.make_rectangle(origin: rectOrigin, size: rectSize)
  pathElementList.add_rectangle(pathRect)
  drawString.arrayofpathelements = pathElementList
  drawString.point_textdrawnfrom = rectOrigin
  drawString
end

drawElement1 = create_pathdrawelement(line_width:28)
drawElement2 = create_pathdrawelement(line_width:20,
                                    stroke_color:MIColor.make_rgbacolor(1,1,1))
drawElement3 = create_pathdrawelement_withequation(
                                line_width:14,
                              stroke_color:MIColor.make_rgbacolor(0.2,0.85,0.1))
drawString = create_drawtextelement()

arrayOfElements = MIDrawElement.new(:arrayofelements)
arrayOfElements.add_drawelement_toarrayofelements(drawElement1)
arrayOfElements.add_drawelement_toarrayofelements(drawElement2)
arrayOfElements.add_drawelement_toarrayofelements(drawElement3)
arrayOfElements.add_drawelement_toarrayofelements(drawString)

puts JSON.pretty_generate(arrayOfElements.elementhash)
