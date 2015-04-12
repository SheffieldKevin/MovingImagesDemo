#!/usr/bin/env ruby

require 'JSON'
require 'tmpdir'
require 'securerandom'

require 'moving_images'

include MovingImages
include MICGDrawing

def drawAxel(axelwidth: 20)
  # This draws the axel centered on 0,0. Use translate transform to position.
  # Use rotate transform to rotate.
  # This inherits the stroke color and line width of the containing draw array element.
  drawAxel = MIDrawElement.new(:arrayofelements)
  axelRadius = axelwidth * 0.5
  strokeOval = MIDrawElement.new(:strokeoval)
  origin = MIShapes.make_point(-axelRadius, -axelRadius)
  axelSize = MIShapes.make_size(axelwidth, axelwidth)
  strokeOval.rectangle = MIShapes.make_rectangle(origin: origin, size: axelSize)
  drawAxel.add_drawelement_toarrayofelements(strokeOval)
  # Then the cross arms.
  lines = MIDrawElement.new(:drawlines)
  points = []
  points.push(MIShapes.make_point(0, -axelRadius))
  points.push(MIShapes.make_point(0, axelRadius))
  points.push(MIShapes.make_point(-axelRadius, 0))
  points.push(MIShapes.make_point(axelRadius, 0))
  lines.points = points
  drawAxel.add_drawelement_toarrayofelements(lines)
  drawAxel
end

def drawRobotArm2(axelwidth: nil,
              robotarmcolor: nil,
                    armsize: MIShapes.make_size(80, 200),
              axelendoffset: 20,
                  nextangle: nil,
               inserteddraw: nil)
  # Draw Arm
  arm = MIDrawElement.new(:fillandstrokepath)

  # Assume arm is 20 pixels narrower at far end.
  
  bigRadius = armsize[:width] * 0.5
  littleRadius = (armsize[:width] - 20) * 0.5
  arm.startpoint = MIShapes.make_point(-bigRadius, 0)
  armPath = MIPath.new

  centerPoint = MIShapes.make_point(0, armsize[:height] - bigRadius)
  armPath.add_arc(centerPoint: centerPoint,
                       radius: littleRadius,
                   startAngle: Math::PI,
                     endAngle: 0,
                  isClockwise: true) #-0.5 * Math::PI)

  centerPoint2 = MIShapes.make_point(0, 0)
  armPath.add_arc(centerPoint: centerPoint2,
                       radius: bigRadius,
                   startAngle: 0,
                     endAngle: -Math::PI,
                  isClockwise: true)
  armPath.add_closesubpath()
  arm.arrayofpathelements = armPath.patharray

  # The axel at the other end if needed. Used when drawing second robot arm
  # but allowing third arm axel to be visible.
  axel2 = nil
  unless nextangle.nil?
    axelwidth2 = axelwidth - 2.0
    axel2 = drawAxel(axelwidth: axelwidth2)
    transform = MITransformations.make_contexttransformation
    MITransformations.add_translatetransform(transform, centerPoint)
    MITransformations.add_rotatetransform(transform, nextangle)
    axel2.contexttransformations = transform
  end

  # Now put together the elements.
  drawArm = MIDrawElement.new(:arrayofelements)
  drawArm.add_drawelement_toarrayofelements(inserteddraw) unless inserteddraw.nil?
  drawArm.linewidth = 2.0
  drawArm.strokecolor = robotarmcolor
  drawArm.fillcolor = MIColor.make_rgbacolor(1,1,1)
  drawArm.add_drawelement_toarrayofelements(arm)
  drawArm.add_drawelement_toarrayofelements(drawAxel(axelwidth: axelwidth))
  drawArm.add_drawelement_toarrayofelements(axel2) unless axel2.nil?
  drawArm
end

def drawRobotArms()
  axelInset = 20
  robotArmColor = MIColor.make_rgbacolor(0.6, 0.6, 0.6)

  firstAxelWidth = 20.0
  firstAxelToAxelLength = 160.0
  secondAxelWidth = 18
  secondAxelToAxelLength = 110
  thirdAxelWidth = 16
  thirdAxelToAxelLength = 80

  firstArmSize = MIShapes.make_size(80, firstAxelToAxelLength + 40)
  drawFirstRobotArm = drawRobotArm2(axelwidth: firstAxelWidth,
                                robotarmcolor: robotArmColor,
                                      armsize: firstArmSize)
  transformations = MITransformations.make_contexttransformation
  MITransformations.add_translatetransform(transformations, MIShapes.make_point(80, 40))

  MITransformations.add_rotatetransform(transformations, -30.0/180.0 * Math::PI)
  drawFirstRobotArm.contexttransformations = transformations
  
  # The slightly odd order in which the arms are generated here is due to
  # wanting the second robot arm to be drawn last. This means the first arm
  # needs to be drawn first, then the third arm, and then the second but with
  # the axel for the third arm made visible.
  
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

  secondArmSize = MIShapes.make_size(60, secondAxelToAxelLength + 30)
  drawSecondRobotArm = drawRobotArm2(axelwidth: secondAxelWidth,
                                 robotarmcolor: robotArmColor,
                                       armsize: secondArmSize,
                                 axelendoffset: axelInset,
                                     nextangle: "$secondangle",
                                  inserteddraw: drawThirdRobotArm)
  transformations2 = MITransformations.make_contexttransformation
  MITransformations.add_translatetransform(transformations2,
                                           MIShapes.make_point(0, firstAxelToAxelLength))
  MITransformations.add_rotatetransform(transformations2, "$firstangle")
  drawSecondRobotArm.contexttransformations = transformations2
  drawFirstRobotArm.add_drawelement_toarrayofelements(drawSecondRobotArm)

  puts JSON.pretty_generate(drawFirstRobotArm.elementhash)
end

drawRobotArms()
