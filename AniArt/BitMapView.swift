//
//  BitMapViewController.swift
//  AniArt
//
//  Created by Matthew Reilly on 12/18/18.
//  Copyright © 2018 UghThatOneGuy. All rights reserved.
//

import UIKit
import Swift

class BitMapView: UIView, UIGestureRecognizerDelegate {
    var timer = Timer()
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var undoneLines = [Line]()
    var pastLines = [Line]()
    var frames = [Frame]()
    var images = [UIImage]()
    var currentFrameIndex = 0
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var pastLineColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var selectedLineIndex: Int? {
        didSet {
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    var moveRecognizer: UIPanGestureRecognizer!
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(BitMapView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(tapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                               action: #selector(BitMapView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(BitMapView.moveLine(_:)))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func saveFrame(){
        if currentFrameIndex == frames.count{
            frames.append(Frame(lines: finishedLines, undoQueue: undoneLines))
            //images.append(self.asImage())
        } else {
            frames[currentFrameIndex] = Frame(lines: finishedLines, undoQueue: undoneLines)
            //images[currentFrameIndex] = self.asImage()
        }
    }
    
    @IBAction func playCurrentFrames(sender: UIButton){
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(nextFrame), userInfo: nil, repeats: true)
        /*let currentLines = frames[currentFrameIndex].lines
        for i in 0..<frames.count{
            
            finishedLines = frames[i].lines
            setNeedsDisplay()
        }*/
        timer.invalidate()
        //finishedLines = currentLines
    }
    
    /*func timerAction() {
        counter += 1
        label.text = "\(currentFrameIndex)"
    }*/
    
    @IBAction func undoLine(){
        if finishedLines.count > 0{
            undoneLines.append(finishedLines[finishedLines.count - 1])
            finishedLines.removeLast()
        }
        setNeedsDisplay()
    }
    
    @IBAction func redoLine(){
        if undoneLines.count > 0{
            finishedLines.append(undoneLines[undoneLines.count - 1])
            undoneLines.removeLast()
        }
        setNeedsDisplay()
    }
    
    @IBAction func newFrame(){
        frames.append(Frame(lines: finishedLines, undoQueue: undoneLines))
        finishedLines.removeAll()
        undoneLines.removeAll()
        currentFrameIndex += 1
        if currentFrameIndex > 0 || currentFrameIndex > 1 || currentFrameIndex > 2{
            pastLines = frames[currentFrameIndex - 1].lines
        }
        setNeedsDisplay()
    }
    
    @IBAction func nextFrame(){
        saveFrame()
        if currentFrameIndex < (frames.count - 1){
            currentFrameIndex += 1
            finishedLines = frames[currentFrameIndex].lines
            undoneLines = frames[currentFrameIndex].undoQueue
        }
        if currentFrameIndex > 0 || currentFrameIndex > 1 || currentFrameIndex > 2{
            pastLines = frames[currentFrameIndex - 1].lines
        }
        setNeedsDisplay()
    }
    
    @IBAction func previousFrame(){
        saveFrame()
        if currentFrameIndex > 0{
            currentFrameIndex -= 1
            finishedLines = frames[currentFrameIndex].lines
            undoneLines = frames[currentFrameIndex].undoQueue
        }
        if currentFrameIndex > 0 || currentFrameIndex > 1 || currentFrameIndex > 2{
            pastLines = frames[currentFrameIndex - 1].lines
        }
        
        setNeedsDisplay()
    }
    

    
    @objc func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("Recognized a pan")
        
        // If a line is selected...
        if let index = selectedLineIndex {
            // When the pan recognizer changes its position...
            if gestureRecognizer.state == .changed {
                // How far has the pan moved?
                let translation = gestureRecognizer.translation(in: self)
                
                // Add the translation to the current beginning and end points of the line
                // Make sure there are no copy and paste typos!
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                // Redraw the screen
                setNeedsDisplay()
            }
        } else {
            // If no line is selected, do not do anything
            return
        }
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a long press")
        
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)
            
            if selectedLineIndex != nil {
                currentLines.removeAll()
            }
        } else if gestureRecognizer.state == .ended {
            selectedLineIndex = nil
        }
        
        setNeedsDisplay()
    }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        // Grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil {
            
            // Make ourselves the target of menu item action messages
            becomeFirstResponder()
            
            // Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(BitMapView.deleteLine(_:)))
            menu.menuItems = [deleteItem]
            
            // Tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.setTargetRect(targetRect, in: self)
            menu.setMenuVisible(true, animated: true)
        } else {
            // Hide the menu if no line is selected
            menu.setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
    
    @objc func deleteLine(_ sender: UIMenuController) {
        // Remove the selected line from the list of finishedLines
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            // Redraw everything
            setNeedsDisplay()
        }
    }
    
    func stroke(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    func indexOfLine(at point: CGPoint) -> Int? {
        
        // Find a line close to point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
            
            // Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 5.0 {
                    return index
                }
            }
        }
        
        // If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
    override func draw(_ rect: CGRect) {
        finishedLineColor.setStroke()
        for line in finishedLines {
            stroke(line)
        }
        
        pastLineColor.setStroke()
        for pastline in pastLines{
            stroke(pastline)
        }
        
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            stroke(line)
        }
        
        if let index = selectedLineIndex {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(#function)
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a print statement to see the order of events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key] {
                line.end = touch.location(in: self)
                
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Let's put in a log statement to see the order of events
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
}

extension UIView {
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
