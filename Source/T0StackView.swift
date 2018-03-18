/*
	T0StackView.swift
	T0Utils-iOS

	Created by Torsten Louland on 18/03/2018.

	MIT License

	Copyright (c) 2018 Torsten Louland

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

import UIKit



public enum T0StackViewClustering : String {
	/// No flushing
	case none

	/// Flush all arranged views to the head end of the arrangement axis (top/left)
	case head

	/// Flush all arranged views to the tail end of the arrangement axis (bottom/right)
	case tail

	/// Cluster all arranged views together in the middle of the arrangement axis
	case mid

	/// `init?(lenient:)` tolerates a range of acceptable synonyms, in contrast to `init?(rawValue:)`
	/// which recognises only exact matches
	public init?(lenient string: String) { switch string.lowercased() {
		case "", "-", "n", "none":
			self = .none
		case "h", "head", "left", "top":
			self = .head
		case "t", "tail", "right", "bottom":
			self = .tail
		case "m", "mid", "middle", "centre", "center":
			self = .mid
		default:
			return nil
	} }
	public init?(_ string: String) { self.init(lenient: string) }
}



/// T0StackView lets you cluster your arranged views at the head, tail or middle of the arrangement
/// axis, instead of having them stretched by the distribution fill modes or dispersed by the
/// distribution spacing modes. Just set the custering property to `.head`, `.tail` or `.mid`, or
/// set to `.none` to disable.
///
/// Using T0StackView in Interface Builder:
///
/// In the Identies inspector, set the class of your stack view instance to T0StackView, from module
/// T0Utils, then in the Atributes inspector, set the `clusterAt` property to any of the strings
/// accepted in the `T0StackViewClustering(_:)` initialiser above.
///
/// You will frequently find IB asks you to resolve fitting ambiguity of your arranged views by
/// adjusting the hugging and/or compression resistance priorities of one of them to be different
/// from the rest; this is ok, as T0StackView will ensure that the space take-up views it inserts
/// have lower hugging and compression resistance priorities than the arranged views, so that they
/// take up space before any of your views are forced to deviate from their intrinsic size.
///
open class T0StackView : UIStackView
{
	public typealias Clustering = T0StackViewClustering

	@IBInspectable open var clusterAt: String {
		get { return clustering.rawValue }
		set { clustering = Clustering(newValue) ?? clustering }
	}

	open var clustering: Clustering = .none {
		didSet {
			guard clustering != oldValue else { return }
			invalidateClustering()
		}
	}

	var takeUpHeadSpaceView:	UIView? = nil // used when clustring == tail | mid
	var takeUpTailSpaceView:	UIView? = nil // used when clustring == head | mid
	var clusteringInvalid:		Bool = false
	var suppressionGuard:		Int = 0
}



/*	Internals
	-	T0StackView inserts a leading and/or trailing view to take up space along the stackview axis
	-	this has the effect of allowing the other views to retain their intrinsic size in the axis direction instead of being stretched when distribution is fill(|Equally|Proportionally), or dispersed when distribution is equal(Spac|Center)ing
	-	the existing views stick together at the start|middle|end of the axis when trailing|both|leading takeup view(s) are inserted
*/
// MARK: - Internals
extension T0StackView
{
	func invalidateClustering() {
		setNeedsLayout()
		if clustering == .none {
			if nil != takeUpHeadSpaceView || nil != takeUpHeadSpaceView {
				removeClustering()
			}
			return
		}
		clusteringInvalid = true
	}
	func validateClustering() {
		if clusteringInvalid {
			applyClustering()
		}
	}
	func removeClustering() {
		guard clustering == .none
		else { return }
		takeUpHeadSpaceView?.removeFromSuperview()
		takeUpHeadSpaceView = nil
		takeUpTailSpaceView?.removeFromSuperview()
		takeUpTailSpaceView = nil
		clusteringInvalid = false
	}
	func applyClustering() {
		guard suppressionGuard == 0
		else { return }
		let needBoth = clustering == .mid
		let needHead = needBoth || clustering == .tail
		let needTail = needBoth || clustering == .head
		if needHead {
			let view = takeUpHeadSpaceView ?? makeTakeUpSpaceView()
			takeUpHeadSpaceView = view
			if view != arrangedSubviews.first {
				super.insertArrangedSubview(view, at: 0)
			}
		} else {
			takeUpHeadSpaceView?.removeFromSuperview()
			takeUpHeadSpaceView = nil
		}

		if needTail {
			let view = takeUpTailSpaceView ?? makeTakeUpSpaceView()
			takeUpTailSpaceView = view
			if view != arrangedSubviews.last {
				super.insertArrangedSubview(view, at: arrangedSubviews.count)
			}
		} else {
			takeUpTailSpaceView?.removeFromSuperview()
			takeUpTailSpaceView = nil
		}

		adjustPrioritiesAndSeparation()
		clusteringInvalid = false
	}
	func makeTakeUpSpaceView() -> UIView {
		let view = UIView()
		view.backgroundColor = nil
		return view
	}
	func adjustPrioritiesAndSeparation() {
		guard nil != takeUpHeadSpaceView || nil != takeUpTailSpaceView else { return }
		var compResPriority = UILayoutPriority.required
		var huggingPriority = UILayoutPriority.required
		let axis = super.axis
		for view in arrangedSubviews {
			if view == takeUpHeadSpaceView { continue }
			if view == takeUpTailSpaceView { continue }
			compResPriority =
				min(compResPriority, view.contentCompressionResistancePriority(for: axis))
			huggingPriority =
				min(huggingPriority, view.contentHuggingPriority(for: axis))
		}
		compResPriority = compResPriority == .required
						? .defaultHigh : compResPriority.predecessor ?? compResPriority
		huggingPriority = huggingPriority == .required
						? .defaultLow : huggingPriority.predecessor ?? huggingPriority
		takeUpHeadSpaceView?.setContentCompressionResistancePriority(compResPriority, for: axis)
		takeUpTailSpaceView?.setContentCompressionResistancePriority(compResPriority, for: axis)
		takeUpHeadSpaceView?.setContentHuggingPriority(huggingPriority, for: axis)
		takeUpTailSpaceView?.setContentHuggingPriority(huggingPriority, for: axis)
		// TODO: Separation
		// Still to do, iOS 11 only: custom spacing after head of zero - ok, custom spacing of zero
		// before tail - tricky. Spacing before tail is spacing after last arranged view, so have to
		// track any custom spacing set by owner and ensure that it is preserved. ...todo.
	}
	func suppressClustering() {
		suppressionGuard += 1
		if suppressionGuard == 1 {
			takeUpHeadSpaceView?.removeFromSuperview()
			takeUpTailSpaceView?.removeFromSuperview()
		}
	}
	func restoreClustering() {
		suppressionGuard -= 1
		if suppressionGuard == 0 {
			if let view = takeUpHeadSpaceView {
				super.insertArrangedSubview(view, at: 0)
			}
			if let view = takeUpTailSpaceView {
				super.insertArrangedSubview(view, at: arrangedSubviews.count)
			}
			adjustPrioritiesAndSeparation()
			clusteringInvalid = false
		}
	}
}



// MARK: - Overrides
extension T0StackView
{
	open override func layoutSubviews() {
		validateClustering()
		super.layoutSubviews()
	}

    open override func addArrangedSubview(_ view: UIView) {
		suppressClustering() ; defer { restoreClustering() }
		super.addArrangedSubview(view)
	}

    open override func removeArrangedSubview(_ view: UIView) {
		suppressClustering() ; defer { restoreClustering() }
		super.removeArrangedSubview(view)
	}

    open override func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
		suppressClustering() ; defer { restoreClustering() }
		super.insertArrangedSubview(view, at: stackIndex)
	}

    open override var axis: UILayoutConstraintAxis {
    	didSet { if axis != oldValue { invalidateClustering() } }
	}

    open override var distribution: UIStackViewDistribution {
    	didSet { if distribution != oldValue { invalidateClustering() } }
	}

    open override var alignment: UIStackViewAlignment {
    	didSet { if alignment != oldValue { invalidateClustering() } }
	}

    open override var spacing: CGFloat {
    	didSet { if spacing != oldValue { invalidateClustering() } }
	}

	@available(iOS 11.0, *)
    open override func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
		super.setCustomSpacing(spacing, after: arrangedSubview)
		invalidateClustering()
	}

    open override var isLayoutMarginsRelativeArrangement: Bool {
    	didSet { if isLayoutMarginsRelativeArrangement != oldValue { invalidateClustering() } }
	}
}



extension UILayoutPriority : Comparable {
	public static func <(lhs: UILayoutPriority, rhs: UILayoutPriority) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	var predecessor: UILayoutPriority? { return UILayoutPriority(rawValue: self.rawValue - 1) }
	var successor: UILayoutPriority? { return UILayoutPriority(rawValue: self.rawValue + 1) }
}



extension UILayoutConstraintAxis {
	public init?(lenient string: String) { switch string.lowercased() {
		case "h", "horz", "horizontal":
			self = .horizontal
		case "v", "vert", "vertical":
			self = .vertical
		default:
			return nil
	} }
	public init?(_ string: String) { self.init(lenient: string) }
}


extension UIStackViewAlignment {
	public init?(_ string: String) { switch string {
	    case "fill":
			self = .fill
	    case "leading", "top":
			self = .leading
	    case "center":
			self = .center
	    case "trailing", "bottom":
			self = .trailing
	    case "firstBaseline":
			self = .firstBaseline // Valid for horizontal axis only
	    case "lastBaseline":
			self = .lastBaseline // Valid for horizontal axis only
		default:
			return nil
	} }
}


extension UIStackViewDistribution {
	public init?(_ string: String) { switch string {
	    case "fill":
			self = .fill
	    case "fillEqually":
			self = .fillEqually
	    case "fillProportionally":
			self = .fillProportionally
	    case "equalSpacing":
			self = .equalSpacing
	    case "equalCentering":
			self = .equalCentering
		default:
			return nil
	} }
}


