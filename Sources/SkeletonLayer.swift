//
//  SkeletonLayer.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 02/11/2017.
//  Copyright © 2017 SkeletonView. All rights reserved.
//

import UIKit

public typealias SkeletonLayerAnimation = (CALayer) -> CAAnimation

public enum SkeletonType {
    case solid
    case gradient
    
    var layer: CALayer {
        switch self {
        case .solid:
            return CALayer()
        case .gradient:
            return CAGradientLayer()
        }
    }
    
    var layerAnimation: SkeletonLayerAnimation {
        switch self {
        case .solid:
            return { $0.pulse }
        case .gradient:
            return { $0.sliding }
        }
    }
}

struct SkeletonLayer {
    private var maskLayer: CALayer
    private weak var holder: UIView?
    private var colors: [UIColor]
    
    var type: SkeletonType {
        return maskLayer is CAGradientLayer ? .gradient : .solid
    }
    
    var contentLayer: CALayer {
        return maskLayer
    }
    
    init(type: SkeletonType, colors: [UIColor], skeletonHolder holder: UIView) {
        self.holder = holder
        self.colors = colors
        self.maskLayer = type.layer
        self.maskLayer.anchorPoint = .zero
        self.maskLayer.bounds = holder.maxBoundsEstimated
        self.maskLayer.cornerRadius = CGFloat(holder.skeletonCornerRadius)
        addTextLinesIfNeeded()
        self.maskLayer.tint(withColors: colors)
    }
    
    func update(usingColors colors: [UIColor]) {
        layoutIfNeeded()
        maskLayer.tint(withColors: colors)
    }

    func layoutIfNeeded() {
        if let holder = holder {
            var bounds = holder.maxBoundsEstimated
            if holder.parentWidthFillPercent != 0 {
                if let superview = holder.superview {
                    var width: CGFloat
                    let centerConstraints = superview.constraints.filter({ $0.firstAttribute == .centerX && $0.secondAttribute == .centerX })
                    if centerConstraints.contains(where: { ($0.firstItem?.isEqual(holder) ?? false) || ($0.secondItem?.isEqual(holder) ?? false) }) {
                        width = superview.frame.width * CGFloat(holder.parentWidthFillPercent) / 100
                        let frameOrigin = CGPoint(x: (holder.frame.width - width) / 2, y: 0)
                        maskLayer.frame.origin = frameOrigin
                    } else {
                        width = (superview.frame.width - holder.frame.origin.x * 2) * CGFloat(holder.parentWidthFillPercent) / 100
                    }
                    bounds = CGRect(x: bounds.minX, y: bounds.minY, width: width, height: bounds.height)
                }
            }
            maskLayer.bounds = bounds
        }
        updateLinesIfNeeded()
    }
    
    func removeLayer(transition: SkeletonTransitionStyle, completion: (() -> Void)? = nil) {
        switch transition {
        case .none:
            maskLayer.removeFromSuperlayer()
            completion?()
        case .crossDissolve(let duration):
            maskLayer.setOpacity(from: 1, to: 0, duration: duration) {
                self.maskLayer.removeFromSuperlayer()
                completion?()
            }
        }
    }

    /// If there is more than one line, or custom preferences have been set for a single line, draw custom layers
    func addTextLinesIfNeeded() {
        guard let textView = holderAsTextView else { return }
        
        let config = SkeletonMultilinesLayerConfig(lines: textView.numLines,
                                                   lineHeight: textView.multilineTextFont?.lineHeight,
                                                   type: type,
                                                   lastLineFillPercent: textView.lastLineFillingPercent,
                                                   multilineCornerRadius: textView.multilineCornerRadius,
                                                   multilineSpacing: textView.multilineSpacing,
                                                   paddingInsets: textView.paddingInsets,
                                                   alignment: textView.alignment,
                                                   additionalLineSpacing: textView.additionalMultilineSpacing)

        maskLayer.addMultilinesLayers(for: config)
    }
    
    func updateLinesIfNeeded() {
        guard let textView = holderAsTextView else { return }
        let config = SkeletonMultilinesLayerConfig(lines: textView.numLines,
                                                   lineHeight: textView.multilineTextFont?.lineHeight,
                                                   type: type,
                                                   lastLineFillPercent: textView.lastLineFillingPercent,
                                                   multilineCornerRadius: textView.multilineCornerRadius,
                                                   multilineSpacing: textView.multilineSpacing,
                                                   paddingInsets: textView.paddingInsets,
                                                   alignment: textView.alignment,
                                                   additionalLineSpacing: textView.additionalMultilineSpacing)
        
        maskLayer.reloadMultilinesLayers(for: config)
        maskLayer.updateMultilinesLayers(for: config)
    }
    
    var holderAsTextView: ContainsMultilineText? {
        guard let textView = holder as? ContainsMultilineText,
            (textView.numLines == 0 || textView.numLines > 1 || textView.numLines == 1 && !SkeletonAppearance.default.renderSingleLineAsView) else {
                return nil
        }
        return textView
    }
}

extension SkeletonLayer {
    func start(_ anim: SkeletonLayerAnimation? = nil, completion: (() -> Void)? = nil) {
        let animation = anim ?? type.layerAnimation
        contentLayer.playAnimation(animation, key: "skeletonAnimation", completion: completion)
    }

    func stopAnimation() {
        contentLayer.stopAnimation(forKey: "skeletonAnimation")
    }
}
