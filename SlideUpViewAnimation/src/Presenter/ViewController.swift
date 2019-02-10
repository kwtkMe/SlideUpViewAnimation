//
//  ViewController.swift
//  SlideUpViewAnimation
//
//  Created by RIVER on 2019/02/05.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

enum SlideViewState {
    case normal
    case selected
}

enum SelectedViewState {
    case collapased
    case expanded
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
    @IBOutlet weak var changeStateButton: UIButton!
    // Tracks all running aninmators
    var State_SlideView: SlideViewState = .normal
    var State_SelectedView: SelectedViewState = .collapased
    var progressWhenInterrupted: CGFloat = 0
    var runningAnimators = [UIViewPropertyAnimator]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubViews()
        addGestures()
    }
    
    private func initSubViews() {
        // StateButton の初期設定
        
        // SlideViewを初期化
        slideView.layer.cornerRadius = 10
        slideView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        slideView.layer.masksToBounds = true
        slideView.frame = collapsedFrame()
        self.view.addSubview(slideView)
        // SlideViewの子要素を初期化
        normalView.layer.cornerRadius = 10
        normalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        normalView.layer.masksToBounds = true
        normalView.frame = CGRect(x: 0, y: 0,
                                  width: self.view.frame.width,
                                  height: 100)
        
        selectedView.layer.cornerRadius = 10
        selectedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectedView.layer.masksToBounds = true
        selectedView.frame = CGRect(x: 0, y: 0,
                                    width: self.view.frame.width,
                                    height: 100)
        
        selectedExView.frame = CGRect(x: 0, y: 60,
                                      width: self.view.frame.width,
                                      height: 500)
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
    
    private func changeSlideViewState() -> SlideViewState {
        switch self.State_SlideView {
        case .normal:
            return .selected
        case .selected:
            return .normal
        }
    }
    
    private func changeSelectedViewState() -> SelectedViewState {
        switch State_SelectedView {
        case .collapased:
            return .expanded
        case .expanded:
            return .collapased
        }
    }
    
    private func addFrameAnimator(state: SelectedViewState, duration: TimeInterval) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .collapased:
                self.slideView.frame = self.collapsedFrame()
            case .expanded:
                self.slideView.frame = self.expandedFrame()
            }
        }
        frameAnimator.addCompletion({ (position) in
            switch position {
            case .start:
                break
            case .end:
                self.State_SelectedView = self.changeSelectedViewState()
            default:
                break
            }
            self.runningAnimators.removeAll()
        })
        runningAnimators.append(frameAnimator)
    }
    
    func animateTransitionIfNeeded(state: SelectedViewState, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.addFrameAnimator(state: state, duration: duration)

        }
    }
    
    // MARK: Gesture
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
    }

    @IBAction func tapButton(_ sender: UIButton) {
        self.State_SelectedView = changeSelectedViewState()
        
        for subview in slideView.subviews {
            subview.removeFromSuperview()
        }
        
        switch self.State_SelectedView {
        case .collapased:
            slideView.frame = collapsedFrame()
            slideView.addSubview(selectedView)
        case .expanded:
            slideView.frame = expandedFrame()
            slideView.addSubview(selectedView)
            slideView.addSubview(selectedExView)
        }
    }
    
}

