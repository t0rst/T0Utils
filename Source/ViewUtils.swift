/*
	ViewUtils.swift
	T0Utils

	Created by Torsten Louland on 17/02/2018.

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



extension UIPopoverArrowDirection {
	public init(popoverTowards rectEdge: CGRectEdge) { switch rectEdge {
		case .minYEdge:		self = .down
		case .minXEdge:		self = .right
		case .maxYEdge:		self = .up
		case .maxXEdge:		self = .left
	} }
	public var anchorPoint: CGPoint { switch self {
		case .down:			return CGPoint(x: 0.5, y: 0.0)
		case .right:		return CGPoint(x: 0.0, y: 0.5)
		case .up:			return CGPoint(x: 0.5, y: 1.0)
		case .left:			return CGPoint(x: 1.0, y: 0.5)
		default:			return CGPoint(x: 0.5, y: 0.5)
	} }
	public var arrowUnitVector: CGPoint { switch self {
		case .down:			return CGPoint(x: 0.0, y: 1.0)
		case .right:		return CGPoint(x: 1.0, y: 0.0)
		case .up:			return CGPoint(x: 0.0, y: -1.0)
		case .left:			return CGPoint(x: -1.0, y: 0.0)
		default:			return CGPoint(x: 0.0, y: 0.0)
	} }
}




