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
}

class ViewController: UIViewController {

    // Constant
    let slideView_normal_Height: CGFloat = 100.0
    let slideView_selected_Height: CGFloat = 500.0
    let animatorDuration: TimeInterval = 1
    
    // UI
    var slideView = UIView()
    var normalView = NormalView()
    var selectedView = SelectedView()
    var selectedExView = SelectedExView()
    
    // Tracks all running aninmators
    var state: State = .normal
    var progressWhenInterrupted: CGFloat = 0
    var runningAnimators = [UIViewPropertyAnimator]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubViews()
        addGestures()
    }
    
    private func initSubViews() {
        self.view.addSubview(slideView)
        slideView.layer.cornerRadius = 10
        slideView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        slideView.layer.masksToBounds = true
        slideView.frame = collapsedFrame()
        
        normalView.layer.cornerRadius = 10
        normalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        normalView.layer.masksToBounds = true
        normalView.frame = CGRect(x: 0, y: 0,
                                  width: self.view.frame.width,
                                  height: 80)
        selectedView.layer.cornerRadius = 10
        selectedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectedView.layer.masksToBounds = true
        selectedView.frame = CGRect(x: 0, y: 0,
                                    width: self.view.frame.width,
                                    height: 60)
        selectedExView.frame = CGRect(x: 0, y: 60,
                                      width: self.view.frame.width,
                                      height: 500)
        
        addNormalView()
    }
    
    private func addGestures() {
        // Tap gesture
        slideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:))))
        
        // Pan gesutre
        slideView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:))))
    }
    
    private func collapsedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - slideView_normal_Height,
            width: self.view.frame.width,
            height: slideView_normal_Height)
    }
    
    private func expandedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - slideView_selected_Height,
            width: self.view.frame.width,
            height: slideView_selected_Height
        )
    }
    
    private func addNormalView() {
        slideView.addSubview(normalView)
    }
    
    private func addSelectedView() {
        slideView.addSubview(selectedView)
        slideView.addSubview(selectedExView)
    }
    
    private func nextState() -> State {
        switch self.state {
        case .normal:
            return .selected
        case .selected:
            return .normal
        }
    }
    
    private func addFrameAnimator(state: State, duration: TimeInterval) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .normal:
                self.slideView.frame = self.expandedFrame()
            case .selected:
                self.slideView.frame = self.collapsedFrame()
            }
        }
        frameAnimator.addCompletion({ (position) in
            switch position {
            case .start:
                break
            case .end:
                self.state = self.nextState()
            default:
                break
            }
            self.runningAnimators.removeAll()
        })
        runningAnimators.append(frameAnimator)
    }
    
    func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.addFrameAnimator(state: state, duration: duration)
            //self.addKeyFrameAnimator(state: state, duration: duration)
        }
    }
    
    // MARK: Gesture
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
    }

    @IBAction func tapButton(_ sender: UIButton) {
        self.state = nextState()
        
        switch self.state {
        case .normal:
            slideView.frame = collapsedFrame()
            addNormalView()
        case .selected:
            slideView.frame = expandedFrame()
            addSelectedView()
        }
    }
    
}

