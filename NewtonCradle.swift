//
//  NewtonCradle.swift
//  NewtonDradle
//
//  Created by chino on 2016/04/10.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit

class NewtonCradle: UIView {
    
    var colors = [UIColor]()
    var balls  = [UIView]()
    
    var ballsToAttachmentBehaviors = [UIView: UIAttachmentBehavior]()   //球体ごとの吊るしセット
    
    var animator: UIDynamicAnimator?
    let collisionBehavior: UICollisionBehavior
    let gravityBehavior: UIGravityBehavior
    let itemBehavior: UIDynamicItemBehavior
    var snapBehavior: UISnapBehavior?
    
    //吊るし状態
    var attachmentBehaviors: [UIAttachmentBehavior] {
        get {
            /* アクセス時に初期化 */
            var attachmentBehaviors = [UIAttachmentBehavior]()
            for ball in balls {
                guard let attachmentBehavior = ballsToAttachmentBehaviors[ball] else { fatalError() }
                attachmentBehaviors.append(attachmentBehavior)
            }
            return attachmentBehaviors
        }
    }
    
    var ballSize = CGSize(width: 80, height: 80) {
        didSet {
            layoutBalls()
        }
    }
    
    init(colors: [UIColor], viewFrame: CGRect) {
        self.colors = colors
        collisionBehavior = UICollisionBehavior(items: [])
        gravityBehavior   = UIGravityBehavior(items: [])
        itemBehavior      = UIDynamicItemBehavior(items: [])

        gravityBehavior.angle = CGFloat(M_PI_2)
        gravityBehavior.magnitude = 1.0
        itemBehavior.elasticity = 1.0
        itemBehavior.resistance = 0.2

        super.init(frame: viewFrame)
        backgroundColor = UIColor.blackColor()
        
        animator = UIDynamicAnimator(referenceView: self)
        animator?.addBehavior(collisionBehavior)
        animator?.addBehavior(gravityBehavior)
        animator?.addBehavior(itemBehavior)
        
        createBallViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //球体を生成
    func createBallViews() {
        for color in colors {
            let ball = UIView(frame: CGRect.zero)
            ball.addObserver(self, forKeyPath: "CENTER", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
            ball.backgroundColor = color

            addSubview(ball)
            balls.append(ball)
            
            layoutBalls()
        }
    }

    //MARK: Ball Layout
    
    /* 球体を描画 */
    func layoutBalls() {
        let requiredWidth = CGFloat(balls.count) * ballSize.width   //必要になる画面幅
        for (index, ball) in balls.enumerate() {
            //初期化
            if let attachmentBehavior = ballsToAttachmentBehaviors[ball] {
                animator?.removeBehavior(attachmentBehavior)
            }
            collisionBehavior.removeItem(ball)
            gravityBehavior.removeItem(ball)
            itemBehavior.removeItem(ball)
            
            //ballの水平位置
            let left = (bounds.width - requiredWidth) / 2.0
            let ball_xOrigin = left + (CGFloat(index) * ballSize.width)
            ball.frame = CGRect(x: ball_xOrigin, y: bounds.midY, width: ballSize.width, height: ballSize.height)
            ball.layer.cornerRadius =  ball.bounds.width / 2.0
            
            //吊るし（ballの真上から）
            let attachPoint = CGPoint(x: ball.frame.midX, y: bounds.midY - 100)
            let attachmentBehavior = UIAttachmentBehavior(item: ball, attachedToAnchor: attachPoint)
            ballsToAttachmentBehaviors[ball] = attachmentBehavior
            animator?.addBehavior(attachmentBehavior)
            
            //物理法則
            collisionBehavior.addItem(ball)
            gravityBehavior.addItem(ball)
            itemBehavior.addItem(ball)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "CENTER" {
            setNeedsDisplay()
            print("描画")
        }
    }
    
    //吊るしビューを描画
    override func drawRect(rect: CGRect) {
        //コンテキスト取得
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        for ball in balls {
        //全ての球体に対して
            //吊るしを取得
            guard let attachBehavior = ballsToAttachmentBehaviors[ball] else { fatalError() }
            let anchorPoint = attachBehavior.anchorPoint    //吊るし位置
            
            CGContextMoveToPoint(context, anchorPoint.x, anchorPoint.y)
            CGContextAddLineToPoint(context, ball.center.x, ball.center.y)
            CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
            CGContextSetLineWidth(context, 5.0)
            CGContextStrokePath(context)
            
            let attach_DotWidth = CGFloat(15.0)
            let attach_DotOrigin = CGPoint(x: anchorPoint.x - (attach_DotWidth / 2), y: anchorPoint.y - (attach_DotWidth / 2))
            let size = CGSize(width: attach_DotWidth, height: attach_DotWidth)
            let attach_DotRect = CGRect(origin: attach_DotOrigin, size: size)
            
            CGContextSetFillColorWithColor(context, UIColor.lightGrayColor().CGColor)
            CGContextFillEllipseInRect(context, attach_DotRect)
        }
        
        CGContextRestoreGState(context)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touchLocation = touches.first?.locationInView(superview) else { return }
        for ball in balls {
            if (CGRectContainsPoint(ball.frame, touchLocation)) {
                snapBehavior = UISnapBehavior(item: ball, snapToPoint: touchLocation)
                animator?.addBehavior(snapBehavior!)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touchLocation = touches.first?.locationInView(superview) else { return }
        if let snapBehavior = snapBehavior {
            snapBehavior.snapPoint = touchLocation
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let snapBehavior = snapBehavior else {
            self.snapBehavior = nil
            return
        }
        animator?.removeBehavior(snapBehavior)
    }
    
    
}
