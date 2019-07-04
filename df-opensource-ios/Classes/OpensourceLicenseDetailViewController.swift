//
// OpensourceLicenseDetailViewController
//

import UIKit
import SafariServices

open class OpensourceLicenseDetailViewController: UIViewController {
    private var _opensource: Opensource
    
    public var opensource: Opensource {
        return self._opensource
    }
    
    private lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textView)
        let leadingConstraint = NSLayoutConstraint(item: self.view ?? UIView(), attribute: .leading, relatedBy: .equal, toItem: textView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.view ?? UIView(), attribute: .trailing, relatedBy: .equal, toItem: textView, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: self.view ?? UIView(), attribute: .top, relatedBy: .equal, toItem: textView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.view ?? UIView(), attribute: .bottom, relatedBy: .equal, toItem: textView, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        return textView
    }()
    
    init(_ opensource: Opensource) {
        self._opensource = opensource
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.delegate = self
        self.textView.isEditable = false
        
        let attributedString = NSMutableAttributedString(string: self.opensource.license ?? "", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
            ])
        do{
            let text = attributedString.string
            let mentionExpression = try NSRegularExpression(pattern: "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)", options: NSRegularExpression.Options.allowCommentsAndWhitespace)
            let matches = mentionExpression.matches(in: text, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, text.count))
            for match in matches{
                let range = match.range
                let rangeValue = text.index(text.startIndex, offsetBy: range.location)..<text.index(text.startIndex, offsetBy: range.location+range.length)
                let matchString =  String(text[rangeValue])
                
                attributedString.addAttributes([
                    NSAttributedString.Key.link: matchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "",
                    NSAttributedString.Key.underlineColor: UIColor(red: 6/255, green: 69/255, blue: 173/255, alpha: 1),
                    NSAttributedString.Key.foregroundColor: UIColor(red: 6/255, green: 69/255, blue: 173/255, alpha: 1),
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                    ], range: range)
            }
        } catch{ }
        
        self.textView.attributedText = attributedString
        self.textView.layoutIfNeeded()
        self.textView.setContentOffset(CGPoint(x: 0, y: -self.textView.contentInset.top), animated: false)
    }
}

// MARK: UITextViewDelegate
extension OpensourceLicenseDetailViewController: UITextViewDelegate{
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if #available(iOS 9.0, *) {
            let viewController = SFSafariViewController(url: URL)
            self.present(viewController, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL)
        }
        return false
    }
}
