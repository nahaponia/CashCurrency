//
//  CurrencyViewController.swift
//  CashCurrency
//
//  Created by Maxim Poltoratsky on 09.09.2020.
//  Copyright © 2020 Brorgnanization. All rights reserved.
//

import UIKit
import Combine
import QuartzCore

private let duration: TimeInterval = 0.575
private let expandedControlHeight: CGFloat = 254
private let collapsedControlHeight: CGFloat = 64

private enum State {
    case expanded
    case collapsed
}

private prefix func !(_ state: State) -> State {
    return state == State.expanded ? .collapsed : .expanded
}

final class CurrencyViewController: UIViewController {
    
    private var state: State = .collapsed
    private var storage = Set<AnyCancellable>()
    private var viewModel = CurrencyViewModel()
    
    @IBOutlet private weak var btnBack: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var panRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tvCurrency: UITableView!
    @IBOutlet private weak var vHeader: UIView!
    @IBOutlet private weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        subscribeOnRunningAnimator()
    }
    
    @IBAction private func onPanGestureAction(_ recognizer: UIPanGestureRecognizer) {
        handlePanGesture(with: recognizer)
    }
    
    @IBAction private func onBackPressed(_ sender: UIButton) {
        exit(0)
    }
    
    private func subscribeOnRunningAnimator() {
        $runningAnimators.sink { [weak self] animators in
            self?.tvCurrency.isScrollEnabled = animators.isEmpty ? true : false
       
        }.store(in: &storage)
    }
    
    // MARK: - Animations
    
    @Published var runningAnimators = [UIViewPropertyAnimator]()
    private var progressWhenInterrupted = [UIViewPropertyAnimator : CGFloat]()
    
    // Perform all animations with animators if not already running
    private func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.state = state
            
            let frameAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut)
            addToRunnningAnimators(frameAnimator) {
                self.updateFrame(for: self.state)
            }
        }
    }
    
    // Starts transition if necessary and pauses on pan .begin
    private func startInteractiveTransition(state: State, duration: TimeInterval) {
        animateTransitionIfNeeded(state: state, duration: duration)
        
        progressWhenInterrupted = [:]
        for animator in runningAnimators {
            animator.pauseAnimation()
            progressWhenInterrupted[animator] = animator.fractionComplete
        }
    }
    
    // MARK: - Running Animation Helpers
    
    private func addToRunnningAnimators(_ animator: UIViewPropertyAnimator,
                                        animation: @escaping () -> Void) {
        animator.addAnimations {
            animation()
        }
        
        animator.addCompletion { [self] _ in
            self.runningAnimators = self.runningAnimators.filter { $0 != animator }
            animation()
        }
        animator.startAnimation()
        runningAnimators.append(animator)
    }
    
    // MARK: - Appearance Animations
    
    private func updateFrame(for state: State) {
        
        switch state {
        case .collapsed:
            headerHeightConstraint.constant = expandedControlHeight
            lblTitle.transform = .identity
        case .expanded:
            headerHeightConstraint.constant = collapsedControlHeight
            lblTitle.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                .concatenating(CGAffineTransform(translationX: -34, y: -5))
        }
        view.layoutIfNeeded()
    }
 
}

// MARK: - UIGestureRecognizerDelegate

extension CurrencyViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIView methods

private extension CurrencyViewController {
    
    func setupView() {
        activityIndicator.startAnimating()
        lblTitle.alpha = 0
        lblTitle.text = DateManager.currentDateTime()
        lblTitle.sizeToFit()
        tvCurrency.registerCell(CurrencyTableViewCell.self)
        viewModel.loadCurrency(completion: {
                                self.lblTitle.alpha = 1
                                self.activityIndicator.stopAnimating()
                                self.tvCurrency.reloadData()
        })
        
    }
    
    func handlePanGesture(with recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if (panRecognizer.direction == .down && headerHeightConstraint.constant == collapsedControlHeight) ||
                (panRecognizer.direction == .up  && headerHeightConstraint.constant == expandedControlHeight) {
                startInteractiveTransition(state: !state, duration: duration)
            }
        case .changed:
            let translation = recognizer.translation(in: vHeader)
            updateInteractiveTransition(distanceTraveled: translation.y)
        case .cancelled, .failed:
            continueInteractiveTransition(cancel: true)
        case .ended:
            let isCancelled = isGestureCancelled(recognizer)
            continueInteractiveTransition(cancel: isCancelled)
        default:
            break
        }
    }
    
    // Scrubs transition on pan .changed
    func updateInteractiveTransition(distanceTraveled: CGFloat) {
        let totalAnimationDistance = expandedControlHeight - collapsedControlHeight
        let fractionComplete = distanceTraveled / totalAnimationDistance
        for animator in runningAnimators {
            if let progressWhenInterrupted = progressWhenInterrupted[animator] {
                let relativeFractionComplete = fractionComplete + progressWhenInterrupted
                
                if (state == .expanded && relativeFractionComplete > 0) ||
                    (state == .collapsed && relativeFractionComplete < 0) {
                    animator.fractionComplete = 0
                }
                else if (state == .expanded && relativeFractionComplete < -1) ||
                    (state == .collapsed && relativeFractionComplete > 1) {
                    animator.fractionComplete = 1
                }
                else {
                    animator.fractionComplete = abs(fractionComplete) + progressWhenInterrupted
                }
            }
        }
    }
    
    // Continues or reverse transition on pan .ended
    func continueInteractiveTransition(cancel: Bool) {
        if cancel {
            reverseRunningAnimations()
        }
        
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
        for animator in runningAnimators {
            animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
        }
    }
    
    private func reverseRunningAnimations() {
        for animator in runningAnimators {
            animator.isReversed = !animator.isReversed
        }
        state = !state
    }
    
    private func isGestureCancelled(_ recognizer: UIPanGestureRecognizer) -> Bool {
           let isCancelled: Bool
           
           let velocityY = recognizer.velocity(in: view).y
           if velocityY != 0 {
               let isPanningDown = velocityY > 0
               isCancelled = (state == .expanded && isPanningDown) ||
                   (state == .collapsed && !isPanningDown)
           }
           else {
               isCancelled = false
           }
           return isCancelled
       }

}

// MARK: - UITableViewDataSource

extension CurrencyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tvCurrency.dequeueReusableCell(with: CurrencyTableViewCell.self, for: indexPath)
        cell.setupCell(model: viewModel.currency[indexPath.row])
        return cell
    }
    
}
