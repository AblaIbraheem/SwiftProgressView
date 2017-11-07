//
//  ProgressPieView.swift
//  Test
//
//  Created by Julie on 31/10/17.
//  Copyright © 2017 ZHOU DENGFENG DEREK. All rights reserved.
//

import UIKit

public class ProgressPieView: ProgressView {
    
    private var displayLink: CADisplayLink?
    private var animationFromValue: CGFloat = 0
    private var animationToValue: CGFloat = 0
    private var animationStartTime: CFTimeInterval = 0
    
    private var progressLayer: CAShapeLayer!
    private var backgroundLayer: CAShapeLayer!
    
    override public var progressColor: UIColor {
        didSet {
            progressLayer.fillColor = progressColor.cgColor
            progressLayer.strokeColor = progressColor.cgColor
            setNeedsDisplay()
        }
    }
    
    override public var circleColor: UIColor {
        didSet {
            backgroundLayer.strokeColor = circleColor.cgColor
            setNeedsDisplay()
        }
    }
        
    public override var circleLineWidth: CGFloat {
        didSet {
            backgroundLayer.lineWidth = circleLineWidth
            setNeedsDisplay()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer.strokeColor = circleColor.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = kCALineCapRound
        backgroundLayer.lineWidth = circleLineWidth
        layer.addSublayer(backgroundLayer)
        
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = progressColor.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(progressLayer)
    }
    
    // MARK: - Public
    public override func setProgress(_ progress: CGFloat, animated: Bool) {
        if self.progress == progress { return }
        
        if !animated {
            if displayLink != nil {
                displayLink!.invalidate()
                displayLink = nil
            }
            self.progress = progress
            setNeedsDisplay()
        } else {
            animationStartTime = CACurrentMediaTime()
            animationFromValue = self.progress
            animationToValue = progress
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(self.animationProgress(_:)))
                displayLink!.add(to: RunLoop.main, forMode: .commonModes)
            }
        }
    }
    
    @objc private func animationProgress(_ sender: CADisplayLink) {
        DispatchQueue.main.async {
            let dt = CGFloat(self.displayLink!.timestamp - self.animationStartTime) / self.animationDuration
            if dt >= 1.0 {
                self.displayLink!.invalidate()
                self.displayLink = nil
                self.progress = self.animationToValue
                self.setNeedsDisplay()
            } else {
                self.progress = self.animationFromValue + dt * (self.animationToValue - self.animationFromValue)
                self.setNeedsDisplay()
            }
        }
    }
    
    // MARK: - Drawing
    private var centerPoint: CGPoint {
        var center: CGPoint = .zero
        center.x = (bounds.size.width - bounds.origin.x) / 2
        center.y = (bounds.size.height - bounds.origin.y) / 2
        return center
    }

    override public func draw(_ rect: CGRect) {
        drawBackground()
        drawProgress()
    }
    
    private func drawBackground() {
        let start = -CGFloat.pi / 2.0
        let end = start + (2.0 * CGFloat.pi)
        let radius = (bounds.size.width - circleLineWidth) / 2

        let path = UIBezierPath()
        path.lineWidth = circleLineWidth
        path.lineCapStyle = .round
        path.addArc(withCenter: centerPoint, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        
        backgroundLayer.path = path.cgPath
    }
    
    private func drawProgress() {
        let start = -CGFloat.pi / 2.0
        let end = start + (2.0 * CGFloat.pi * progress)
        let radius = (bounds.size.width / 2.0) - circleLineWidth
        
        let path = UIBezierPath()
        path.move(to: centerPoint)
        path.addArc(withCenter: centerPoint, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        path.close()
        
        progressLayer.path = path.cgPath
    }
}

