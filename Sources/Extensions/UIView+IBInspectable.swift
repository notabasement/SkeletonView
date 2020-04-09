//  Copyright © 2017 SkeletonView. All rights reserved.

import UIKit

public extension UIView {
    @IBInspectable
    var isSkeletonable: Bool {
        get { return skeletonable }
        set { skeletonable = newValue }
    }

    @IBInspectable
    var skeletonCornerRadius: Float {
        get { return skeletonableCornerRadius }
        set { skeletonableCornerRadius = newValue }
    }
    
    @IBInspectable
    var parentWidthFillPercent: Int {
        get { return skeletonableParentWidthFillPercent }
        set { skeletonableParentWidthFillPercent = min(newValue, 100) }
    }
    
    var isSkeletonActive: Bool {
        return status == .on || (subviewsSkeletonables.first(where: { $0.isSkeletonActive }) != nil)
    }

    private var skeletonable: Bool! {
        get { return ao_get(pkey: &ViewAssociatedKeys.skeletonable) as? Bool ?? false }
        set { ao_set(newValue ?? false, pkey: &ViewAssociatedKeys.skeletonable) }
    }

    private var skeletonableCornerRadius: Float! {
        get { return ao_get(pkey: &ViewAssociatedKeys.skeletonCornerRadius) as? Float ?? 0.0 }
        set { ao_set(newValue ?? 0.0, pkey: &ViewAssociatedKeys.skeletonCornerRadius) }
    }
    
    private var skeletonableParentWidthFillPercent: Int! {
        get { return ao_get(pkey: &ViewAssociatedKeys.parentWidthFillPercent) as? Int ?? 0 }
        set { ao_set(newValue ?? 0, pkey: &ViewAssociatedKeys.parentWidthFillPercent) }
    }
}

