//
//  UIRotaryControl.swift
//  UIRotaryControl
//
//  Created by Gopi Krishnan on 25/12/21.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import Foundation

//Enum for Type of the control.
public enum UIRotaryControlType {
    case fluid // For continuos rotation. This is default value.
    case stepped //For stepped rotary control that stops only at tick marks.
}

//Rotary Class Implemenation
public class UIRotaryControl: UIControl, UIGestureRecognizerDelegate {

   //Variable declarations
    public var type: UIRotaryControlType = .fluid
    public var bgImage : UIImage? { didSet { drawBackground() }}
    public var imageView = UIImageView()
    public var padding : CGFloat = 40
    public var ticksView =  UIView()
    public var pointerColor: UIColor = .white { didSet { drawPointer() }}
    public var pointerLineSize: CGFloat = 5 { didSet { drawPointer() }}
    public var pointerLayer = CAShapeLayer()
    public var pointerView =  UIView()
    public var tooltip = UIView()
    public var tooltipLabel = UILabel()
    public var startAngle = -CGFloat.pi * 11 / 8.0
    public var endAngle = CGFloat.pi * 3 / 8.0
    public var minimumValue: Float = 0.0 { didSet { drawTickMarks() }}
    public var maximumValue: Float = 10.0 { didSet { drawTickMarks() }}
    public var stepperValue: Float = 1.0 { didSet { drawTickMarks() }}
    private var tickMarks = [Float]()
    public var value: Float = 0.0 {
      didSet {
        value = min(maximumValue, max(minimumValue, value))
          drawTickMarks()
          setNeedsLayout()
      }
    }
    
    
    // Overriding super class methods
    
    init(imageName: String) {
        super.init(frame: CGRect.zero)
        bgImage = UIImage(named: imageName)!
        myInit()
    }
    init() {
        super.init(frame: CGRect.zero)
        myInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        myInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    // Custom methods
    
    func myInit() {
       
        if bgImage == nil {
            bgImage = UIImage(named: "bg_normal")!
        }
        drawBackground()
        drawPointer()
        drawTickMarks()
        drawTooltip()
        let gestureRecognizer = RotaryGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        self.addGestureRecognizer(gestureRecognizer)
       
        
        self.isUserInteractionEnabled = true
    }
    
    //Setting the background of the control using Image View.
    func drawBackground() {
        
        //Calculating the size of the Control based on the provided image. If it's bigger than the Screen, we will resize it to fit. If it's too small, we will stretch it to 120px.
        
        let imageSize = (bgImage?.size)!
        let minSize = CGSize(width: 120, height: 120)
        let maxSize = CGSize(width: 280, height: 280)

        if(imageSize.width < minSize.width || imageSize.height < minSize.height )  {
            
            let newWidth = imageSize.width < minSize.width ? minSize.width : imageSize.width
            
            let newHeight = imageSize.height < minSize.height ? minSize.height : imageSize.width
            
            let newSize = CGSize(width: newWidth, height: newHeight)
            
            //Upsizing the smaller image to reasonable 120px
            
            bgImage = UIGraphicsImageRenderer(size: newSize).image { _ in
                bgImage!.draw(in: CGRect(origin: .zero , size: newSize)) }
            
        } else if(imageSize.width > maxSize.width || imageSize.height > maxSize.height )  {
            
            //Provided image is too big for screen size. Let's downsize.
            let newWidth = imageSize.width > maxSize.width ? maxSize.width : imageSize.width
            
            let newHeight = imageSize.height > maxSize.height ? newWidth : imageSize.height
            
            let newSize = CGSize(width: newWidth, height: newHeight)

            //Downsizing
            bgImage = UIGraphicsImageRenderer(size: newSize).image { _ in
                bgImage!.draw(in: CGRect(origin: .zero , size: newSize)) }
        }
        
        imageView.image = bgImage
        imageView.frame = CGRect(origin: CGPoint(x: padding, y: padding), size: bgImage!.size)
        imageView.isUserInteractionEnabled = false
        
        // Include space for tick marks and tool tip
        let newSize = CGSize(width: bgImage!.size.width+(padding*2), height: bgImage!.size.height+(padding*2))
        
        self.frame = CGRect(origin: .zero , size: newSize)
        ticksView.frame = CGRect(origin: .zero , size: newSize)
        ticksView.backgroundColor = .clear
        ticksView.layer.cornerRadius = imageView.frame.width * 0.5
        ticksView.isUserInteractionEnabled = false
        self.addSubview(ticksView)
        self.addSubview(imageView)

    }
    
    
    //Creating a viewLayer for pointer and rotating them based on user interactiion
    func drawPointer() {

        let radius = (min(imageView.bounds.width, imageView.bounds.height) / 2)
        let angle = CGFloat(angleForValue(value))

        pointerView.bounds = CGRect.init(x: center.x, y: center.y, width: radius , height: pointerLineSize)
        pointerView.clipsToBounds = true
        pointerView.layer.anchorPoint = CGPoint(x: 0.0,y :0.0)
        pointerView.layer.position = CGPoint(x: center.x, y: center.y)
        pointerView.transform = CGAffineTransform(rotationAngle: angle)
        pointerView.backgroundColor = pointerColor
        addSubview(pointerView)
        pointerView.layer.zPosition = 100
        pointerLayer.fillColor = UIColor.clear.cgColor
        
    }
    
    func drawTickMarks(){

        ticksView.subviews.forEach { $0.removeFromSuperview() }
        tickMarks = []
        
        tickMarks.append(minimumValue)
        var tick: Float = minimumValue + stepperValue

        //setting stepper ticks if the type is stepped control and if the stepper value is valid, that it can divide the range in to equal ranges. Should be no reminders when dividing the range by stepperValue.
        if type == .stepped && ( (maximumValue-minimumValue).truncatingRemainder(dividingBy:stepperValue) == 0.0) {
            
            while tick < maximumValue {
                tickMarks.append(tick)
                tick = tick + stepperValue
            }
        }
        tickMarks.append(maximumValue)
        
        var angle : CGFloat
        let center = CGPoint (x: ticksView.center.x - 15, y: ticksView.center.y - 15)
        let radius = (bounds.height / 2) - 15
        angle = CGFloat(2 * Float.pi)
        let step = CGFloat(2 * Float.pi) / CGFloat(tickMarks.count)

        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)

        // set objects around circle
        for tickMark in tickMarks {
            let x = cos(angleForTick(tickMark)) * radius + (center.x + 5)
            let y = sin(angleForTick(tickMark)) * radius + (center.y + 5)

            let label = UILabel()
            label.text = "\(tickMark)"
            label.frame.origin.x = x
            label.frame.origin.y = y
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .black
            label.sizeToFit()
            ticksView.addSubview(label)
            angle += step
        }

    }
    
    func drawTooltip() {
   
        tooltipLabel.font = UIFont.systemFont(ofSize: 12)
        tooltipLabel.textColor = .black
        tooltipLabel.textAlignment = .center
        tooltipLabel.layer.backgroundColor = UIColor.yellow.cgColor
        tooltipLabel.layer.cornerRadius = 10
        
        tooltip.addSubview(tooltipLabel)
        tooltipLabel.translatesAutoresizingMaskIntoConstraints = false
        tooltipLabel.bottomAnchor.constraint(equalTo: tooltip.bottomAnchor, constant: -16).isActive = true
        tooltipLabel.topAnchor.constraint(equalTo: tooltip.topAnchor).isActive = true
        tooltipLabel.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor).isActive = true
        tooltipLabel.trailingAnchor.constraint(equalTo: tooltip.trailingAnchor).isActive = true
        
        let labelHeight = 40.0
        let labelWidth = 80.0
        
        let pointerTip = CGPoint(x: labelWidth / 2, y: labelHeight + Double(8))
        let pointerBaseLeft = CGPoint(x: labelWidth / 2 - Double(14 / 2), y: labelHeight)
        let pointerBaseRight = CGPoint(x: labelWidth / 2 + Double(14) / 2, y: labelHeight)
        
        let pointerPath = UIBezierPath()
        pointerPath.move(to: pointerBaseLeft)
        pointerPath.addLine(to: pointerTip)
        pointerPath.addLine(to: pointerBaseRight)
        pointerPath.close()
        
        let pointer = CAShapeLayer()
        pointer.path = pointerPath.cgPath
        pointer.fillColor = UIColor.yellow.cgColor
        tooltip.layer.addSublayer(pointer)
        self.addSubview(tooltip)
        tooltip.isUserInteractionEnabled = false
        tooltip.isHidden = true
        tooltip.layer.zPosition = 150
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        tooltip.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20).isActive = true
        tooltip.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        tooltip.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        tooltip.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        
        
    }
    
    @objc func handleGesture(_ gesture: RotaryGestureRecognizer) {

        let midPointAngle = (2 * CGFloat.pi + startAngle - endAngle) / 2 + endAngle
        var boundedAngle = gesture.touchAngle
        if boundedAngle > midPointAngle {
          boundedAngle -= 2 * CGFloat.pi
        } else if boundedAngle < (midPointAngle - 2 * CGFloat.pi) {
          boundedAngle += 2 * CGFloat.pi
        }
        
        boundedAngle = min(endAngle, max(startAngle, boundedAngle))
        value = min(maximumValue, max(minimumValue, valueForAngle(boundedAngle)))

        if type == .stepped {
            
                let stepValue = ((value-minimumValue)/stepperValue).rounded()
                value = minimumValue + (stepperValue * stepValue)
                tooltipLabel.text = String(format: "%.2f",value)
            
        } else {
            tooltipLabel.text = String(format: "%.2f",value)

        }
        let angle = CGFloat(angleForValue(value))
        pointerView.transform = CGAffineTransform(rotationAngle: angle)

        // Inform changes if the implementing view controller needs it.
        if type == .fluid {
        sendActions(for: .valueChanged)
        } else {
            if gesture.state == .ended || gesture.state == .cancelled {
              sendActions(for: .valueChanged)
                tooltip.isHidden = true
            }
        }
      
      if gesture.state == .began {
        sendActions(for: .editingDidBegin)
          tooltipLabel.text = String(format: "%.2f",value)
          tooltip.isHidden = false
      }
      
      if gesture.state == .ended {
        sendActions(for: .editingDidEnd)
          tooltip.isHidden = true

      }
    }
    
    // MARK: Value/Angle conversion
    
    public func valueForAngle(_ angle: CGFloat) -> Float {
      let angleRange = Float(endAngle - startAngle)
      let valueRange = maximumValue - minimumValue
      return Float(angle - startAngle) / angleRange * valueRange + minimumValue
    }
    
    public func angleForValue(_ value: Float) -> CGFloat {
      let angleRange = endAngle - startAngle
      let valueRange = CGFloat(maximumValue - minimumValue)
      return CGFloat(value - minimumValue) / valueRange * angleRange + startAngle
    }
    public func angleForTick(_ tick: Float) -> CGFloat {
      let angleRange = endAngle - startAngle
      let valueRange = CGFloat(maximumValue - minimumValue)
      return CGFloat(tick - minimumValue) / valueRange * angleRange + startAngle
    }
    
}

/// Custom gesture recognizer for the Rotary Control.
public class RotaryGestureRecognizer: UIPanGestureRecognizer {
  public var touchAngle: CGFloat = 0
  public var diagonalChange: CGSize = .zero
  private var lastTouchPoint: CGPoint = .zero
  
  // MARK: UIGestureRecognizerSubclass
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    state = .began
    guard let touch = touches.first else { return }
    lastTouchPoint = touch.location(in: view)
    updateTouchAngleWithTouches(touches)
  }
  
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
    state = .changed
    guard let touchPoint = touches.first?.location(in: view) else { return }
    diagonalChange.width = (touchPoint.x - lastTouchPoint.x)
    diagonalChange.height = (touchPoint.y - lastTouchPoint.y)
    lastTouchPoint = touchPoint
    updateTouchAngleWithTouches(touches)
  }
  
  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
    state = .ended

  }
  
  private func updateTouchAngleWithTouches(_ touches: Set<UITouch>) {
    guard let touch = touches.first else { return }
    let touchPoint = touch.location(in: view)
    touchAngle = calculateAngleToPoint(touchPoint)
  }
  
  private func calculateAngleToPoint(_ point: CGPoint) -> CGFloat {
    let centerOffset = CGPoint(x: point.x - view!.bounds.midX, y: point.y - view!.bounds.midY)
    return atan2(centerOffset.y, centerOffset.x)
  }
  
  // MARK: Lifecycle
  
  public init() {
    super.init(target: nil, action: nil)
    maximumNumberOfTouches = 1
    minimumNumberOfTouches = 1
  }
  
  public override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
    maximumNumberOfTouches = 1
    minimumNumberOfTouches = 1
  }
}
