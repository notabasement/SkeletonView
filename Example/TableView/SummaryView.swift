// Copyright © 2020 SkeletonView. All rights reserved.

import Foundation
import UIKit

public class SummaryView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setText(stringList: [String]) {
        titleLabel.attributedText = generateBulletList(from: stringList)
    }
}

// MARK: - Helpers
extension SummaryView {
    
    private func generateBulletList(from stringList: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 10, options: nonOptions)]
        paragraphStyle.defaultTabInterval = 5
        paragraphStyle.headIndent = 10
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.paragraphSpacing = 10
        
        let bulletList = NSMutableAttributedString()
        for (index, string) in stringList.enumerated() {
            let lineFeed = index != stringList.count - 1 ? "\n" : ""
            let string = String(format: "\u{2022}\t%1$@%2$@", string, lineFeed)
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            bulletList.append(attributedString)
        }
        return bulletList
    }
}
