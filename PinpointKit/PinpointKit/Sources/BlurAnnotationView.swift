//
//  BlurAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/30/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit
import GLKit
import CoreImage

public class BlurAnnotationView: AnnotationView, GLKViewDelegate {

    // MARK: - Properties

    let EAGLContext: OpenGLES.EAGLContext

    let GLKView: GLKit.GLKView
    
    let CIContext: CoreImage.CIContext

    var annotation: BlurAnnotation? {
        didSet {
            setNeedsDisplay()
            
            let layer = CAShapeLayer()
            layer.path = annotation.map { UIBezierPath(rect: $0.frame) }?.CGPath
            GLKView.layer.mask = layer
        }
    }
    
    var drawsBorder = false {
        didSet {
            if drawsBorder != oldValue {
                setNeedsDisplay()
            }
        }
    }

    override var annotationFrame: CGRect? {
        return annotation?.frame
    }
    
    var touchTargetFrame: CGRect? {
        let size = frame.size
        let maximumWidth = max(4.0, min(size.width, size.height) * 0.075)
        let outsideStrokeWidth = min(maximumWidth, 14.0) * 1.5
        
        return annotationFrame.map { UIEdgeInsetsInsetRect($0, UIEdgeInsets(top: -outsideStrokeWidth, left: -outsideStrokeWidth, bottom: -outsideStrokeWidth, right: -outsideStrokeWidth)) }
    }
    
    // MARK: - Initializers

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    public override init(frame: CGRect) {
        let bounds = CGRect(origin: CGPoint.zero, size: frame.size)

        EAGLContext = OpenGLES.EAGLContext(API: .OpenGLES2)
        GLKView = GLKit.GLKView(frame: bounds, context: EAGLContext)
        CIContext = CoreImage.CIContext(EAGLContext: EAGLContext, options: [
            kCIContextUseSoftwareRenderer: false
        ])

        super.init(frame: frame)

        opaque = false
        
        GLKView.userInteractionEnabled = false
        GLKView.delegate = self
        GLKView.contentMode = .Redraw
        addSubview(GLKView)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UIView

    override public func layoutSubviews() {
        super.layoutSubviews()
        GLKView.frame = bounds
    }

    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let frame = touchTargetFrame
        
        return frame.map { $0.contains(point) } ?? false
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if drawsBorder {
            let context = UIGraphicsGetCurrentContext()
            tintColor?.colorWithAlphaComponent(self.dynamicType.BorderAlpha).setStroke()
            
            // Since this draws under the GLKView, and strokes extend both inside and outside, we have to double the intended width.
            let strokeWidth: CGFloat = 1.0
            CGContextSetLineWidth(context, strokeWidth * 2.0)
            
            let rect = annotationFrame ?? CGRect.zero
            CGContextStrokeRect(context, rect)
        }
    }
        
    // MARK: - AnnotationView

    override func setSecondControlPoint(point: CGPoint) {
        annotation = annotation.map {
            BlurAnnotation(startLocation: $0.startLocation, endLocation: point, image: $0.image)
        }
    }

    override func moveControlPoints(translation: CGPoint) {
        annotation = annotation.map {
            let startLocation = CGPoint(x: $0.startLocation.x + translation.x, y: $0.startLocation.y + translation.y)
            let endLocation = CGPoint(x: $0.endLocation.x + translation.x, y: $0.endLocation.y + translation.y)
            return BlurAnnotation(startLocation: startLocation, endLocation: endLocation, image: $0.image)
        }
    }

    override func scaleControlPoints(scale: CGFloat) {
        annotation = annotation.map {
            let startLocation = $0.scaledPoint($0.startLocation, scale: scale)
            let endLocation = $0.scaledPoint($0.endLocation, scale: scale)
            return BlurAnnotation(startLocation: startLocation, endLocation: endLocation, image: $0.image)
        }
    }

    // MARK: - GLKViewDelegate

    public func glkView(view: GLKit.GLKView, drawInRect rect: CGRect) {
        glClearColor(0, 0, 0, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        if let image = annotation?.blurredImage {
            let drawableRect = CGRect(x: 0, y: 0, width: view.drawableWidth, height: view.drawableHeight)
            CIContext.drawImage(image, inRect: drawableRect, fromRect: image.extent)
        }
    }
}
