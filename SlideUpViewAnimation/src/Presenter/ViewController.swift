//
//  ViewController.swift
//  SlideUpViewAnimation
//
//  Created by RIVER on 2019/02/05.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

enum SlideViewState {
    case collapased
    case expanded
}

class ViewController: UIViewController {
    // UI
    var slideView = UIView()
    var contentsScrollView = UIScrollView()
    var normalView = NormalView()
    var selectedHeaderView = SelectedHeaderView()
    var selectedContentsView = SelectedContentsView()
    @IBOutlet weak var changeStateButton: UIButton!
    // UI Constant
    var state_SelectedView: SlideViewState = .collapased
    final let Height_slideView_collapsed: CGFloat = 80.0
    final let Height_slideView_expanded: CGFloat = 300.0
    final let Height_selectedContentsView: CGFloat = 500.0
    final func colleapsedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - Height_slideView_collapsed,
            width: self.view.frame.width,
            height: Height_slideView_collapsed)
    }
    
    final func expandedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - Height_slideView_expanded,
            width: self.view.frame.width,
            height: Height_slideView_expanded
        )
    }
    // Tracks all running aninmators
    let animatorDuration: TimeInterval = 1
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
        slideView.frame = colleapsedFrame()
        self.view.addSubview(slideView)
    
        // SlideViewの子要素を初期化
        normalView.layer.cornerRadius = 10
        normalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        normalView.layer.masksToBounds = true
        normalView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Height_slideView_collapsed)
        selectedHeaderView.layer.cornerRadius = 10
        selectedHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectedHeaderView.layer.masksToBounds = true
        selectedHeaderView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Height_slideView_collapsed)
        // .expanded のContents部分を表示させるためのスクロールビューを定義
        contentsScrollView.bounces = false
        contentsScrollView.isScrollEnabled = true
        contentsScrollView.contentSize = CGSize(width: self.view.frame.width, height: 380)
        contentsScrollView.frame
            = CGRect(x: 0, y: selectedHeaderView.frame.maxY, width: self.view.frame.width, height: Height_slideView_expanded - Height_slideView_collapsed)
        selectedContentsView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Height_selectedContentsView)
        
        switch self.state_SelectedView {
        case .collapased:
            slideView.frame = colleapsedFrame()
            slideView.addSubview(selectedHeaderView)
        case .expanded:
            slideView.frame = expandedFrame()
            slideView.addSubview(selectedHeaderView)
            slideView.addSubview(contentsScrollView)
            contentsScrollView.addSubview(selectedContentsView)
        }
    }
    
    private func addGestures() {
        // Tap gesture
        slideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:))))
        
        // Pan gesutre
        slideView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:))))
    }
    
    private func changeSlideViewState() -> SlideViewState {
        switch state_SelectedView {
        case .collapased:
            return .expanded
        case .expanded:
            return .collapased
        }
    }
    
    private func addFrameAnimator(state: SlideViewState, duration: TimeInterval) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .collapased:
                self.slideView.frame = self.colleapsedFrame()
            case .expanded:
                self.slideView.frame = self.expandedFrame()
            }
        }
        frameAnimator.addCompletion({ (position) in
            switch position {
            case .start:
                break
            case .end:
                self.state_SelectedView = self.changeSlideViewState()
            default:
                break
            }
            self.runningAnimators.removeAll()
        })
        runningAnimators.append(frameAnimator)
    }
    
    func animateTransitionIfNeeded(state: SlideViewState, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.addFrameAnimator(state: state, duration: duration)
        }
    }
    
    // MARK: Gesture
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        self.animateOrReverseRunningTransition(state: self.changeSlideViewState(), duration: animatorDuration)
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: slideView)
        switch recognizer.state {
        case .began:
            self.startInteractiveTransition(state: self.changeSlideViewState(), duration: animatorDuration)
        case .changed:
            self.updateInteractiveTransition(fractionComplete: self.fractionComplete(state: self.changeSlideViewState(), translation: translation))
        case .ended:
            self.continueInteractiveTransition(fractionComplete: self.fractionComplete(state: self.changeSlideViewState(), translation: translation))
        default:
            break
        }
    }
    
    private func fractionComplete(state: SlideViewState, translation: CGPoint) -> CGFloat {
        // 広げようと(changeSlideViewState()で.expand)しているとき、値を負数にする
        let translationY = state == .expanded ? -translation.y : translation.y
        return translationY
            // 左項：画面高さ - 他パーツ高さの合計値
            // 右項：
            / (self.view.frame.height) + progressWhenInterrupted
    }
    
    // Starts transition if necessary or reverse it on tap
    func animateOrReverseRunningTransition(state: SlideViewState, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
            runningAnimators.forEach({ $0.startAnimation() })
        } else {
            runningAnimators.forEach({ $0.isReversed = !$0.isReversed })
        }
    }
    
    // Starts transition if necessary and pauses on pan .began
    func startInteractiveTransition(state: SlideViewState, duration: TimeInterval) {
        self.animateTransitionIfNeeded(state: state, duration: duration)
        runningAnimators.forEach({ $0.pauseAnimation() })
        progressWhenInterrupted = runningAnimators.first?.fractionComplete ?? 0
    }
    
    // Scrubs transition on pan .changed
    func updateInteractiveTransition(fractionComplete: CGFloat) {
        runningAnimators.forEach({ $0.fractionComplete = fractionComplete })
    }
    
    // Continues or reverse transition on pan .ended
    func continueInteractiveTransition(fractionComplete: CGFloat) {
        let cancel: Bool = fractionComplete < 0.2
        if cancel {
            runningAnimators.forEach({
                $0.isReversed = !$0.isReversed
                $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            })
            return
        }
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
        runningAnimators.forEach({ $0.continueAnimation(withTimingParameters: timing, durationFactor: 0) })
    }

    @IBAction func tapButton(_ sender: UIButton) {
        self.state_SelectedView = changeSlideViewState()
        
        for subview in slideView.subviews {
            subview.removeFromSuperview()
        }
        
        switch self.state_SelectedView {
        case .collapased:
            slideView.frame = colleapsedFrame()
            slideView.addSubview(selectedHeaderView)
        case .expanded:
            slideView.frame = expandedFrame()
            slideView.addSubview(selectedHeaderView)
            slideView.addSubview(contentsScrollView)
            contentsScrollView.addSubview(selectedContentsView)
        }
    }
    
}

