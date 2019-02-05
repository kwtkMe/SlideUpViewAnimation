//
//  ViewController.swift
//  SlideUpViewAnimation
//
//  Created by RIVER on 2019/02/05.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

enum State {
    case normal
    case selected
    case expanded
}

class ViewController: UIViewController {

    // Constant
    let slideView_Height: CGFloat = 100.0
    
    // UI
    var slideView = UIView()
    var normalView = NormalView()
    var selectedView = SelectedView()
    var expandedView = ExpandedView()
    
    // Tracks all running aninmators
    var state: State = .normal
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initSubViews()
        self.addGestures()
    }
    
    private func initSubViews() {
        slideView.frame = collapsedFrame()
        slideView.backgroundColor = .white
        self.view.addSubview(slideView)
        
        normalView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: self.view.frame.width,
                                  height: 60)
        slideView.addSubview(normalView)
    }
    
    private func addGestures() {
        
    }
    
    private func collapsedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - slideView_Height,
            width: self.view.frame.width,
            height: slideView_Height)
    }
    
    private func expandedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: slideView_Height,
            width: self.view.frame.width,
            height: self.view.frame.height - slideView_Height
        )
    }

    @IBAction func tapButton(_ sender: UIButton) {
        
    }
    
}

