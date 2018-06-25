/*
	UnifiedTypes.swift
	T0Utils

	Created by Torsten Louland on 17/01/2018.

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

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif



/// For internal use in this module; do the same in your app. See comment for class `T0Unified`
class Unified : T0Unified {}



/// An in-progress collection of type aliases and extensions aimed at easing development of 
/// unified macOS and iOS code.
/// (Hopefully obsoleted by iOS 12 + macOS 10.13)
///
/// You can avoid the need to import T0Utils in every source file by defining and using a trival 
/// subclass in your code...
///
/// ```Swift
/// class Unified : T0Unified {}
/// ```
/// ...recommended.
open class T0Unified
{
#if os(iOS)
	public typealias Storyboard = UIStoryboard
	public typealias StoryboardSegue = UIStoryboardSegue
	public typealias StoryboardSegueID = String

	public typealias ViewController = UIViewController

	public typealias View = UIView
	public typealias LayoutRelation = NSLayoutConstraint.Relation
	public typealias LayoutAttribute = NSLayoutConstraint.Attribute
	public typealias LayoutPriority = UILayoutPriority

	public typealias Button = UIButton
	public typealias ImageView = UIImageView

	public typealias TextField = UITextField
	public typealias TextFieldDelegate = UITextFieldDelegate

	public typealias Image = UIImage
	public typealias ImageRenderingMode = UIImage.RenderingMode
	public typealias Color = UIColor
	public typealias Font = UIFont
	public typealias FontDescriptor = UIFontDescriptor

	public typealias EdgeInsets = UIEdgeInsets
#elseif os(macOS)
	public typealias Storyboard = NSStoryboard
	public typealias StoryboardSegue = NSStoryboardSegue
	public typealias StoryboardSegueID = NSStoryboardSegue.Identifier

	public typealias ViewController = NSViewController

	public typealias View = NSView
	public typealias LayoutRelation = NSLayoutConstraint.Relation
	public typealias LayoutAttribute = NSLayoutConstraint.Attribute
	public typealias LayoutPriority = NSLayoutConstraint.Priority

	public typealias Button = NSButton
	public typealias ImageView = NSImageView

	public typealias TextField = NSTextField
	public typealias TextFieldDelegate = NSTextFieldDelegate

	public typealias Image = NSImage
	public typealias ImageRenderingMode = Int
	public typealias Color = NSColor
	public typealias Font = NSFont
	public typealias FontDescriptor = NSFontDescriptor

	public typealias EdgeInsets = NSEdgeInsets

#endif
	public typealias FontDescriptorAttributes = Dictionary<FontDescriptor.AttributeName, Any>
	public typealias TextAttributes = Dictionary<NSAttributedString.Key, Any>
}



#if os(iOS)
#elseif os(macOS)
extension T0Unified.StoryboardSegueID : ExpressibleByStringLiteral {
	public init(stringLiteral value: String) { self.init(rawValue: value) }
	public init(extendedGraphemeClusterLiteral value: String) { self.init(rawValue: value) }
	public init(unicodeScalarLiteral value: String) { self.init(rawValue: value) }
}
#endif



extension T0Unified.StoryboardSegue {
#if os(iOS)
	open var sourceController: T0Unified.ViewController { return source }
	open var destinationController: T0Unified.ViewController { return destination }
#elseif os(macOS)
	open var source: Any { return sourceController }
	open var destination: Any { return destinationController }
#endif
}



extension T0Unified.TextField {
#if os(iOS)
#elseif os(macOS)
	open var text: String? { get { return stringValue } set { stringValue = newValue ?? "" } }
#endif
}



#if os(iOS)
#elseif os(macOS)
extension NSProgressIndicator {
	open func startAnimating() { startAnimation(nil) }
	open func stopAnimating() { stopAnimation(nil) }
}
#endif



#if os(iOS)
#elseif os(macOS)
extension NSImage {
	open func withAlignmentRectInsets(_ insets: NSEdgeInsets) -> NSImage {
		let image = self.copy() as! NSImage
		let bounds = CGRect(origin: .zero, size: image.size)
		image.alignmentRect = NSEdgeInsetsInsetRect(bounds, insets)
		return image
	}
	open var alignmentRectInsets: NSEdgeInsets {
		let alignTo = self.alignmentRect
		let size = self.size
		var insets = NSEdgeInsets.zero
		insets.left = alignTo.origin.x
		insets.top = alignTo.origin.y
		insets.right = size.width - alignTo.size.width - alignTo.origin.x
		insets.bottom = size.height - alignTo.size.height - alignTo.origin.y
		return insets
	}
}
#endif



#if os(iOS)
#elseif os(macOS)
extension NSEdgeInsets {
	public static let zero = NSEdgeInsetsZero
}
extension NSEdgeInsets : Equatable {
	public static func ==(lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
		return NSEdgeInsetsEqual(lhs, rhs)
	}
}
public func NSEdgeInsetsInsetRect(_ rect: CGRect, _ insets: NSEdgeInsets) -> CGRect {
	var r = rect
	// having to write this is insane!!!
	// should move to decent wrapper lib that provides all ops.
	r.origin.x += insets.left
	r.origin.y += insets.top
	r.size.width -= insets.left + insets.right
	r.size.height -= insets.top + insets.bottom
	return r
}
#endif

extension T0Unified.EdgeInsets {
	public var inverse: T0Unified.EdgeInsets {
		return T0Unified.EdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
	}
}



#if os(iOS)
#elseif os(macOS)
#endif


