/*
	ICSUtilityViews.swift
	Views that help with intrinsic content size

	Created by Torsten Louland on 11/02/2018.

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



extension CGFloat {
	public static let noIntrinsicMetric = UIViewNoIntrinsicMetric
}

extension CGSize {
	public static let noIntrinsicMetric = CGSize(width: .noIntrinsicMetric, height: .noIntrinsicMetric)
}



/// ICSCollectionView = UICollectionView + IntrinsicContentSize utilities
open class ICSCollectionView : UICollectionView
{
	/// How ICSMask (intrinsicContentSizeMask) values affect what is returned from
	/// intrinsicContentSize (per individual dimension):
	/// - .noIntrinsicMetric: return .noIntrinsicMetric
	/// - 0: return self.collectionViewLayout.contentSize.width/height
	/// - >0: return the mask value as a fixed value
	/// (abbreviated name chosen so that you can see it fully in IB, otherwise confusing.)
	@IBInspectable open var ICSMask: CGSize = .noIntrinsicMetric {
		didSet {
			if ICSMask != oldValue {
				invalidateIntrinsicContentSize()
			}
		}
	}

	override open var intrinsicContentSize: CGSize {
		var ics = super.intrinsicContentSize
		switch ICSMask.width {
			case .noIntrinsicMetric:	ics.width = .noIntrinsicMetric
			case 0:						ics.width = collectionViewLayout.collectionViewContentSize.width
			case let val where val > 0: ics.width = val
			default: break
		}
		switch ICSMask.height {
			case .noIntrinsicMetric:	ics.height = .noIntrinsicMetric
			case 0:						ics.height = collectionViewLayout.collectionViewContentSize.height
			case let val where val > 0: ics.height = val
			default: break
		}
		return ics
	}

	override open func reloadData() {
		super.reloadData()
		if ICSMask.width == 0 || ICSMask.height == 0 {
			invalidateIntrinsicContentSize()
		}
	}
}



/// ICSTextView = UITextView + IntrinsicContentSize utilities
open class ICSTextView : UITextView {

	@IBInspectable open var realignEdgesBy: UIEdgeInsets = .zero {
		didSet {
			if realignEdgesBy != oldValue {
				setNeedsLayout()
			}
		}
	}

	override open var alignmentRectInsets: UIEdgeInsets {
		var ari = super.alignmentRectInsets
		ari.top += realignEdgesBy.top
		ari.left += realignEdgesBy.left
		ari.bottom += realignEdgesBy.bottom
		ari.right += realignEdgesBy.right
		return ari
	}

	@IBInspectable open var ICSMask: CGSize = .zero {
		didSet {
			if ICSMask != oldValue {
				invalidateIntrinsicContentSize()
			}
		}
	}

	override open var intrinsicContentSize: CGSize {
		var ics = super.intrinsicContentSize
		switch ICSMask.width {
			case .noIntrinsicMetric:	ics.width = .noIntrinsicMetric
			case let val where val > 0: ics.width = val
			default: break
		}
		switch ICSMask.height {
			case .noIntrinsicMetric:	ics.height = .noIntrinsicMetric
			case let val where val > 0: ics.height = val
			default: break
		}
		return ics
	}
}



open class ICSContentView : UIView {

	@IBInspectable open var ICSMask: CGSize = .zero {
		didSet {
			if ICSMask != oldValue {
				invalidateIntrinsicContentSize()
			}
		}
	}

	public enum MeasureMethod : String { case max, sum }
	@IBInspectable open var measureBy: NSString {
		get { return "\(measureWidthBy.rawValue), \(measureHeightBy.rawValue)" as NSString }
		set {
			let s = newValue as String
			let a = s.split(separator: ",").flatMap { $0.split(separator: " ") }
			if a.count > 0, let m = MeasureMethod(rawValue: String(a[0])) { measureWidthBy = m }
			if a.count > 1, let m = MeasureMethod(rawValue: String(a[1])) { measureHeightBy = m }
		}
	}
	open var measureWidthBy: MeasureMethod = .sum
	open var measureHeightBy: MeasureMethod = .max

	override open var intrinsicContentSize: CGSize {
		var ics = super.intrinsicContentSize
		switch ICSMask.width {
			case .noIntrinsicMetric:	ics.width = .noIntrinsicMetric
			case let val where val > 0: ics.width = val
			default:
				switch measureWidthBy {
					case .sum:
						ics.width = subviews.reduce(CGFloat(0.0))
							{ (width, view) -> CGFloat in
								let sz = view.intrinsicContentSize.width
								return sz != .noIntrinsicMetric ? width + sz : width
							}
					case .max:
						ics.width = subviews.reduce(CGFloat(0.0))
							{ max($0, $1.intrinsicContentSize.width) }
				}
		}
		switch ICSMask.height {
			case .noIntrinsicMetric:	ics.height = .noIntrinsicMetric
			case let val where val > 0: ics.height = val
			default:
				switch measureHeightBy {
					case .sum:
						ics.height = subviews.reduce(CGFloat(0.0))
							{ (height, view) -> CGFloat in
								let sz = view.intrinsicContentSize.height
								return sz != .noIntrinsicMetric ? height + sz : height
							}
					case .max:
						ics.height = subviews.reduce(CGFloat(0.0))
							{ max($0, $1.intrinsicContentSize.height) }
				}
		}
		return ics
	}
}
