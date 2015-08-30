//
//  TableViewCell.swift
//  Break It Down
//
//  Created by Rob Norback on 8/29/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

import UIKit
import QuartzCore

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate {
    // indicates that the given item has been deleted
    func toDoItemsDeleted(toDoItem: ToDoItem)
}

class TableViewCell: UITableViewCell {

    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false, completeOnDragRelease = false
    var tickLabel:UILabel, crossLabel:UILabel
    // The object that acts as delegate for this cell
    var delegate: TableViewCellDelegate?
    // Item that this cell renders
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.text
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.hidden = !label.strikeThrough
        }
    }
    var label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle , reuseIdentifier: String?) {
        label = StrikeThroughText(frame: CGRect.nullRect)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.backgroundColor = UIColor.clearColor()
        
        func createCuesLabel() -> UILabel {
            let label = UILabel(frame: CGRect.nullRect)
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColor.clearColor()
            label.font = UIFont.boldSystemFontOfSize(32.0)
            return label
        }
        
        tickLabel = createCuesLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .Right
        crossLabel = createCuesLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .Left
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        addSubview(tickLabel)
        addSubview(crossLabel)
        
        // remove the default blue highlight for selected cells
        selectionStyle = .None
        
        // gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1,color2,color3,color4]
        gradientLayer.locations = [0.0,0.01,0.95,1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        // add a layer that renders a green background when an item is complete
        itemCompleteLayer = CALayer(layer: layer)//try doing just the bounds
        itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).CGColor
        itemCompleteLayer.hidden = true
        layer.insertSublayer(itemCompleteLayer, atIndex: 0)
        
        // add pan gesture recognizer
        var pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        pan.delegate = self
        addGestureRecognizer(pan)
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0
    let kUICuesWidth: CGFloat = 50.0
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width-kLabelLeftMargin, height: bounds.size.height)
        tickLabel.frame = CGRect(x: -kUICuesMargin - kUICuesWidth, y: 0, width: kUICuesWidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0, width: kUICuesWidth, height: bounds.size.height)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            originalCenter = center
        }
        
        if recognizer.state == .Changed {
            // this is how you get movement of a pan gesture
            let translation = recognizer.translationInView(self)
            // you should move the cell the same amount that the pan gesture moves
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            // if frame.x is more than half the width of the cell off the screen (to the left), then delete it
            deleteOnDragRelease = frame.origin.x < -frame.size.width/8.0
            // if the the frame.x is more then hack the frame size, then complete it
            completeOnDragRelease = frame.origin.x > frame.size.width/8.0
            
            // fade the contextual clues
            let cueAlpha = fabs(frame.origin.x)/(frame.size.width/8.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            
            // indicate when the user has pulled the item far enough to invoke the given action
            tickLabel.textColor = completeOnDragRelease ? UIColor.greenColor() : UIColor.whiteColor()
            crossLabel.textColor = deleteOnDragRelease ? UIColor.redColor() : UIColor.whiteColor()
        }
        
        if recognizer.state == .Ended {
            // the frame the cell had before the user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                if completeOnDragRelease {
                    if  label.strikeThrough {
                        toDoItem?.completed = false;
                        label.strikeThrough = false;
                        itemCompleteLayer.hidden = true;
                    } else {
                        toDoItem?.completed = true;
                        label.strikeThrough = true;
                        itemCompleteLayer.hidden = false;
                    }
                }
                // if the item is not being deleted or completed, snap back to the original location
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    // notify the delegate that this item should be deleted
                    delegate!.toDoItemsDeleted(toDoItem!)
                }
            }
        }
    }
    
    // Ensures that the pan gesture is in the x-direction and not the y
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecoginizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecoginizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}
