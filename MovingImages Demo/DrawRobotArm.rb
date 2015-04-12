#!/usr/bin/env ruby

require 'JSON'
require 'tmpdir'
require 'securerandom'

require 'moving_images'

include MovingImages
include MICGDrawing

def drawRobotArm(axelwidth: nil,
             robotarmcolor: nil,
                   armsize: MIShapes.make_size(80, 200),
             axelendoffset: 20)
  # Draw Arm
  arm = MIDrawElement.new(:strokerectangle)
  armOrigin = MIShapes.make_point(-armsize[:width] * 0.5, -axelendoffset)
  arm.rectangle = MIShapes.make_rectangle(origin: armOrigin, size: armsize)
  
  # Draw axel
  # First the circle
  axelRadius = axelwidth * 0.5
  strokeOval = MIDrawElement.new(:strokeoval)
  # strokeOval.linewidth = 2
  # strokeOval.strokecolor = robotarmcolor
  origin = MIShapes.make_point(-axelRadius, -axelRadius)
  axelSize = MIShapes.make_size(axelwidth, axelwidth)
  strokeOval.rectangle = MIShapes.make_rectangle(origin: origin, size: axelSize)

  # Then the cross arms.
  lines = MIDrawElement.new(:drawlines)
  points = []
  points.push(MIShapes.make_point(0, -axelRadius))
  points.push(MIShapes.make_point(0, axelRadius))
  points.push(MIShapes.make_point(-axelRadius, 0))
  points.push(MIShapes.make_point(axelRadius, 0))
  lines.points = points

  # Now put together the elements.
  drawArm = MIDrawElement.new(:arrayofelements)
  drawArm.linewidth = 2.0
  drawArm.strokecolor = robotarmcolor
  drawArm.add_drawelement_toarrayofelements(arm)
  drawArm.add_drawelement_toarrayofelements(strokeOval)
  drawArm.add_drawelement_toarrayofelements(lines)
  drawArm
end

def drawRobotArm2(axelwidth: nil,
              robotarmcolor: nil,
                    armsize: MIShapes.make_size(80, 200),
              axelendoffset: 20,
                  nextangle: nil)
  # Draw Arm
  arm = MIDrawElement.new(:fillandstrokepath)
  # Assume arm is 20 pixels narrower at far end.
  
  bigRadius = armsize[:width] * 0.5
  littleRadius = (armsize[:width] - 20) * 0.5
  arm.startpoint = MIShapes.make_point(-bigRadius, 0)
  armPath = MIPath.new
#  armPath.add_lineto(MIShapes.make_point(-littleRadius,
#                                         armsize[:height] - littleRadius))
  centerPoint = MIShapes.make_point(0, armsize[:height] - bigRadius)
  armPath.add_arc(centerPoint: centerPoint,
                       radius: littleRadius,
                   startAngle: Math::PI,
                     endAngle: 0,
                  isClockwise: true) #-0.5 * Math::PI)
#  armPath.add_arc(centerPoint: centerPoint,
#                       radius: littleRadius,
#                   startAngle: 0.5 * Math::PI,
#                     endAngle: 0.0) #-0.5 * Math::PI)
  centerPoint2 = MIShapes.make_point(0, 0)
  armPath.add_arc(centerPoint: centerPoint2,
                       radius: bigRadius,
                   startAngle: 0,
                     endAngle: -Math::PI,
                  isClockwise: true)
#  armPath.add_arc(centerPoint: centerPoint2,
#                       radius: bigRadius,
#                   startAngle: -0.5 * Math::PI,
#                     endAngle: -Math::PI)
  armPath.add_closesubpath()
  arm.arrayofpathelements = armPath.patharray
  
  # Draw axel
  # First the circle
  axelRadius = axelwidth * 0.5
  strokeOval = MIDrawElement.new(:strokeoval)
  # strokeOval.linewidth = 2
  # strokeOval.strokecolor = robotarmcolor
  origin = MIShapes.make_point(-axelRadius, -axelRadius)
  axelSize = MIShapes.make_size(axelwidth, axelwidth)
  strokeOval.rectangle = MIShapes.make_rectangle(origin: origin, size: axelSize)

  # Then the cross arms.
  lines = MIDrawElement.new(:drawlines)
  points = []
  points.push(MIShapes.make_point(0, -axelRadius))
  points.push(MIShapes.make_point(0, axelRadius))
  points.push(MIShapes.make_point(-axelRadius, 0))
  points.push(MIShapes.make_point(axelRadius, 0))
  lines.points = points

  # Now put together the elements.
  drawArm = MIDrawElement.new(:arrayofelements)
  drawArm.linewidth = 2.0
  drawArm.strokecolor = robotarmcolor
  drawArm.fillcolor = MIColor.make_rgbacolor(1,1,1)
  drawArm.add_drawelement_toarrayofelements(arm)
  drawArm.add_drawelement_toarrayofelements(strokeOval)
  drawArm.add_drawelement_toarrayofelements(lines)
  drawArm
end

def drawRobotArms()
  firstAxelWidth = 20.0
  firstAxelToAxelLength = 160.0
  axelInset = 20
#  firstArmSize = MIShapes.make_size(80, firstAxelToAxelLength + 2.0 * axelInset)
  firstArmSize = MIShapes.make_size(80, firstAxelToAxelLength + 40)
  robotArmColor = MIColor.make_rgbacolor(0.6, 0.6, 0.6)
#  drawFirstRobotArm = drawRobotArm(axelwidth: firstAxelWidth,
  drawFirstRobotArm = drawRobotArm2(axelwidth: firstAxelWidth,
                                robotarmcolor: robotArmColor,
                                      armsize: firstArmSize)
  transformations = MITransformations.make_contexttransformation
  MITransformations.add_translatetransform(transformations, MIShapes.make_point(80, 40))
#  MITransformations.add_rotatetransform(transformations, "$firstangle")
  MITransformations.add_rotatetransform(transformations, -30.0/180.0 * Math::PI)
  drawFirstRobotArm.contexttransformations = transformations
  
  secondAxelWidth = 18
  secondAxelToAxelLength = 110
#  secondArmSize = MIShapes.make_size(80, secondAxelToAxelLength + 2.0 * axelInset)
  secondArmSize = MIShapes.make_size(60, secondAxelToAxelLength + 30)
#  drawSecondRobotArm = drawRobotArm(axelwidth: secondAxelWidth,
  drawSecondRobotArm = drawRobotArm2(axelwidth: secondAxelWidth,
                                 robotarmcolor: robotArmColor,
                                       armsize: secondArmSize,
                                 axelendoffset: axelInset)
  transformations2 = MITransformations.make_contexttransformation
  MITransformations.add_translatetransform(transformations2,
                                           MIShapes.make_point(0, firstAxelToAxelLength))
  MITransformations.add_rotatetransform(transformations2, "$firstangle")
  drawSecondRobotArm.contexttransformations = transformations2
  drawFirstRobotArm.add_drawelement_toarrayofelements(drawSecondRobotArm)
  
  thirdAxelWidth = 16
  thirdAxelToAxelLength = 80
#  secondArmSize = MIShapes.make_size(80, secondAxelToAxelLength + 2.0 * axelInset)
  thirdArmSize = MIShapes.make_size(40, thirdAxelToAxelLength + 20)
  drawThirdRobotArm = drawRobotArm2(axelwidth: thirdAxelWidth,
                                robotarmcolor: robotArmColor,
                                      armsize: thirdArmSize,
                                axelendoffset: axelInset)
  transformations3 = MITransformations.make_contexttransformation
  MITransformations.add_translatetransform(transformations3,
                                           MIShapes.make_point(0, secondAxelToAxelLength))
  MITransformations.add_rotatetransform(transformations3, "$secondangle")
  drawThirdRobotArm.contexttransformations = transformations3
  drawSecondRobotArm.add_drawelement_toarrayofelements(drawThirdRobotArm)

  puts JSON.pretty_generate(drawFirstRobotArm.elementhash)
end

=begin
def drawRobotArms()
  axelInset = 20
  robotArmColor = MIColor.make_rgbacolor(0.6, 0.6, 0.6)
  firstAxelToAxelLength = 160.0

  secondAxelWidth = 18
  secondAxelToAxelLength = 110
  secondArmSize = MIShapes.make_size(60, secondAxelToAxelLength + 2.0 * axelInset)
  drawSecondRobotArm = MIDrawElement.new(:arrayofelements)
  drawSecondRobotArm = drawRobotArm(drawarm: drawSecondRobotArm,
                                  axelwidth: secondAxelWidth,
                              robotarmcolor: robotArmColor,
                                    armsize: secondArmSize,
                              axelendoffset: axelInset)
  transformations2 = MITransformations.make_contexttransformation
  MITransformations.add_translatetransform(transformations2,
                                           MIShapes.make_point(0, firstAxelToAxelLength))
  MITransformations.add_rotatetransform(transformations2, "$firstangle")
  drawSecondRobotArm.contexttransformations = transformations2

  firstAxelWidth = 20.0
  firstArmSize = MIShapes.make_size(80, firstAxelToAxelLength + 2.0 * axelInset)
  drawFirstRobotArm = MIDrawElement.new(:arrayofelements)
  drawFirstRobotArm.add_drawelement_toarrayofelements(drawSecondRobotArm)
  drawFirstRobotArm = drawRobotArm(drawarm: drawFirstRobotArm,
                                 axelwidth: firstAxelWidth,
                             robotarmcolor: robotArmColor,
                                   armsize: firstArmSize)
  transformations = MITransformations.make_contexttransformation
  MITransformations.add_translatetransform(transformations, MIShapes.make_point(80, 40))
#  MITransformations.add_rotatetransform(transformations, "$firstangle")
  MITransformations.add_rotatetransform(transformations, -30.0/180.0 * Math::PI)
  drawFirstRobotArm.contexttransformations = transformations
  drawFirstRobotArm.add_drawelement_toarrayofelements(drawSecondRobotArm)
  puts JSON.pretty_generate(drawFirstRobotArm.elementhash)
end
=end
drawRobotArms()
