/*
	Geometry.swift

	Created by Torsten Louland on 07/02/2018.

	MIT License

	Copyright (c) 2018 Satisfying Structures BVBA

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
import CoreGraphics
#if os(iOS)
import UIKit
#elseif os(macOS)
#endif


extension Array where Element == CGFloat
{
	public var asCGPoints: [CGPoint]? {
		guard self.count % 2 == 0
		else { return nil }
		let points = stride(from: 0, to: self.count, by: 2).map {
			CGPoint(x: self[$0], y: self[$0+1])
		}
		return points
	}
}

public func +(a: CGPoint, b: CGFloat) -> CGPoint { return CGPoint(x: a.x + b, y: a.y + b) }
public func -(a: CGPoint, b: CGFloat) -> CGPoint { return CGPoint(x: a.x - b, y: a.y - b) }
public func *(a: CGPoint, b: CGFloat) -> CGPoint { return CGPoint(x: a.x * b, y: a.y * b) }
public func +(a: CGSize, b: CGFloat) -> CGSize { return CGSize(width: a.width + b, height: a.height + b) }
public func -(a: CGSize, b: CGFloat) -> CGSize { return CGSize(width: a.width - b, height: a.height - b) }
public func *(a: CGSize, b: CGFloat) -> CGSize { return CGSize(width: a.width * b, height: a.height * b) }

public func +(a: CGFloat, b: CGPoint) -> CGPoint { return CGPoint(x: a + b.x, y: a + b.y) }
public func -(a: CGFloat, b: CGPoint) -> CGPoint { return CGPoint(x: a - b.x, y: a - b.y) }
public func *(a: CGFloat, b: CGPoint) -> CGPoint { return CGPoint(x: a * b.x, y: a * b.y) }
public func +(a: CGFloat, b: CGSize) -> CGSize { return CGSize(width: a + b.width, height: a + b.height) }
public func -(a: CGFloat, b: CGSize) -> CGSize { return CGSize(width: a - b.width, height: a - b.height) }
public func *(a: CGFloat, b: CGSize) -> CGSize { return CGSize(width: a * b.width, height: a * b.height) }

public prefix func -(p: CGPoint) -> CGPoint { return CGPoint(x: p.x, y: p.y) }

public func +(a: CGPoint, b: CGPoint) -> CGPoint { return CGPoint(x: a.x + b.x, y: a.y + b.y) }
public func -(a: CGPoint, b: CGPoint) -> CGPoint { return CGPoint(x: a.x - b.x, y: a.y - b.y) }
public func *(a: CGPoint, b: CGPoint) -> CGPoint { return CGPoint(x: a.x * b.x, y: a.y * b.y) }
public func +(a: CGSize, b: CGSize) -> CGSize { return CGSize(width: a.width + b.width, height: a.height + b.height) }
public func -(a: CGSize, b: CGSize) -> CGSize { return CGSize(width: a.width - b.width, height: a.height - b.height) }
public func *(a: CGSize, b: CGSize) -> CGSize { return CGSize(width: a.width * b.width, height: a.height * b.height) }

public func +(a: CGPoint, b: CGSize) -> CGPoint { return CGPoint(x: a.x + b.width, y: a.y + b.height) }
public func -(a: CGPoint, b: CGSize) -> CGPoint { return CGPoint(x: a.x - b.width, y: a.y - b.height) }
public func *(a: CGPoint, b: CGSize) -> CGPoint { return CGPoint(x: a.x * b.width, y: a.y * b.height) }
public func +(a: CGSize, b: CGPoint) -> CGSize { return CGSize(width: a.width + b.x, height: a.height + b.y) }
public func -(a: CGSize, b: CGPoint) -> CGSize { return CGSize(width: a.width - b.x, height: a.height - b.y) }
public func *(a: CGSize, b: CGPoint) -> CGSize { return CGSize(width: a.width * b.x, height: a.height * b.y) }



extension CGSize {
	public var area: CGFloat { return width * height }
}

extension CGSize {
	/// Aspect categorizes common aspects in pictures; these are approximate, but given and
	/// adjacent pair (via `Aspects` option set), decisions can be made about optimal UI arrangement
	public enum Aspect : Int {
		case vertical, skyscraper, standing, portrait, square, landscape, lying, panorama, horizon
		public func tallerThan(_ other: Aspect) -> Bool { return self.rawValue < other.rawValue }
		public func widerThan(_ other: Aspect) -> Bool { return self.rawValue > other.rawValue }
		public var tall: Bool { return self.tallerThan(.square) }
		public var wide: Bool { return self.widerThan(.square) }
		public var flipped: Aspect { return Aspect(rawValue: 2 * Aspect.square.rawValue - self.rawValue)! }
	}
	/// Represent the range of aspects in one or more sizes
	public struct Aspects : OptionSet {
		public let	 rawValue: Aspect.RawValue
		public init(rawValue: RawValue)				{ self.rawValue = rawValue }
		public init(_ aspect: Aspect)					{ self.rawValue = aspect.rawValue }
		public static let vertical = Aspects(.vertical), skyscraper = Aspects(.skyscraper), standing = Aspects(.standing), portrait = Aspects(.portrait), square = Aspects(.square), landscape = Aspects(.landscape), lying = Aspects(.lying), panorama = Aspects(.panorama), horizon = Aspects(.horizon), none = Aspects(rawValue: 0)
		/// `mixed` returns true for any combination other than a single or two consecutive aspect values
		public var mixed: Bool { var n = rawValue ; while n > 2 { n >>= 1 } ; return 0 != ( n & ~3 ) }
	}
	/// aspectFactor traverses 0->1 in range atan(H/W): 0->90°; relationship is non-linear, but
	/// ordering allows tests; returns nil for .zero
	public var aspectFactor: CGFloat? {
		guard width != 0, height != 0 else { return nil }
		let ah = fabs(height), aw = fabs(width), base = ah + aw
		return base > 1e-10 ? ah / base : 0
	}
	/// returns an `Aspects` set with the two `Aspect` values that bracket the aspect of this size
	public var aspectBracket: Aspects {
		guard let af = aspectFactor else { return [] }
		if af <= CGSize(width: 5,  height: 24).aspectFactor! { return [.vertical, .skyscraper] }
		if af <= CGSize(width: 6,  height: 20).aspectFactor! { return [.skyscraper, .standing] }
		if af <= CGSize(width: 7,  height: 10).aspectFactor! { return [.standing, .portrait] }
		if af <= CGSize(width: 1,  height:  1).aspectFactor! { return [.portrait, .square] }
		if af <= CGSize(width: 10, height:  7).aspectFactor! { return [.square, .landscape] }
		if af <= CGSize(width: 20, height:  6).aspectFactor! { return [.landscape, .lying] }
		if af <= CGSize(width: 24, height:  5).aspectFactor! { return [.lying, .panorama] }
		return [.panorama, .horizon]
	}
}



extension CGRect
{
	public init(_ size: CGSize) { self.init() ; self.size = size }

#if os(iOS)
	public func integralOnScreen(_ screen: UIScreen = .main) -> CGRect {
		let toDevice = max(1.0, screen.scale), toStandard = 1.0 / toDevice
		let a = CGRect(origin: origin * toDevice, size: size * toDevice)
		let b = a.integral
		let c = CGRect(origin: b.origin * toStandard, size: b.size * toStandard)
		return c
	}
#elseif os(macOS)
	public func integralOnScreen() -> CGRect {
		return self.integral
	}
#endif

	public func ordinal(at edge: CGRectEdge) -> CGFloat { switch edge {
		case .minYEdge:		return self.minY
		case .minXEdge:		return self.minX
		case .maxYEdge:		return self.maxY
		case .maxXEdge:		return self.maxX
	} }

	public enum Slice {
		case above(CGRect), left(CGRect), below(CGRect), right(CGRect)
		public var edge: CGRectEdge { switch self {
			case .above:	return .minYEdge
			case .left:		return .minXEdge
			case .below:	return .maxYEdge
			case .right:	return .maxXEdge
		} }
		public var rect: CGRect { switch self {
			case .above(let r):	return r
			case .left(let r):	return r
			case .below(let r):	return r
			case .right(let r):	return r
		} }
		public init(_ rect: CGRect, atEdge edge: CGRectEdge) { switch edge {
			case .minYEdge:	self = .above(rect)
			case .minXEdge:	self = .left(rect)	
			case .maxYEdge:	self = .below(rect)
			case .maxXEdge:	self = .right(rect)
		} }
	}

	public func slicesSurrounding(_ inner: CGRect) -> [Slice] {
		var slices = [Slice]()
		let intersect = self.intersection(inner)
		for edge in [CGRectEdge]([.minYEdge,.minXEdge,.maxYEdge,.maxXEdge]) {
			let cutAt = inner.ordinal(at: edge)
			if cutAt != intersect.ordinal(at: edge) { continue } // ==> inner extends outside self
			let relTo = self.ordinal(at: edge)
			let dist = (relTo - cutAt).magnitude
			var slice = CGRect.zero, other = CGRect.zero
			self.__divided(slice: &slice, remainder: &other, atDistance: dist, from: edge)
			if !slice.isNull {
				slices.append(Slice(slice, atEdge: edge))
			}
		}
		return slices
	}

	public func point(atAnchor anchor: CGPoint) -> CGPoint { return origin + size * anchor }

	public mutating func set(anchor: CGPoint, to newValue: CGPoint) {
		let oldValue = point(atAnchor: anchor)
		origin.x += newValue.x - oldValue.x
		origin.y += newValue.y - oldValue.y
	}

	public var center: CGPoint {
		get { return origin + size * 0.5 }
		mutating set {
			let oldValue = center
			origin.x += newValue.x - oldValue.x
			origin.y += newValue.y - oldValue.y
		}
	}

	public init(size: CGSize, anchor: CGPoint, at: CGPoint) {
		self.init()
		self.origin = at - size * anchor
		self.size = size
	}
}

public func rotate<T>(_ index: T, by: T, within n: T) -> T
where T : SignedInteger
{
	var i = (index + by) % n
	if i < 0 { i += n }
	return i
}

public func rotate<T>(_ index: T, by: T, within n: T) -> T
where T : FloatingPoint
{
	var i = (index + by).remainder(dividingBy: n)
	if i < T(0) { i += n }
	return i
}

public func pointAt(t: CGFloat, onBezier a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint) -> CGPoint? {
	guard t >= 0, t <= 1.0
	else { return nil }
	let t0 = 1 - t
	let t1 = t
	if fabs(t1) < 1e-10 { return a } // near enough to an anchor point
	if fabs(t0) < 1e-10 { return d } // near enough to an anchor point
	let a_ = t0 * a + b * t1
	let b_ = t0 * b + c * t1
	let c_ = t0 * c + d * t1
	let ab_ = t0 * a_ + b_ * t1
	let bc_ = t0 * b_ + c_ * t1
	let abc = t0 * ab_ + bc_ * t1
	return abc
}

public func pointAt(t: CGFloat, onBezier points: ArraySlice<CGPoint>) -> CGPoint? {
	guard points.count == 4
	else { return nil }
	let a = points[points.startIndex]
	let b = points[points.startIndex.advanced(by: 1)]
	let c = points[points.startIndex.advanced(by: 2)]
	let d = points[points.startIndex.advanced(by: 3)]
	return pointAt(t: t, onBezier: a, b, c, d)
}

public func pointAt(t posn: CGFloat, onBezierPath points: ArraySlice<CGPoint>) -> CGPoint? {
	let n = Int(trunc(posn))
	let t = posn - CGFloat(n)
	let idx0 = n * 3 // index of first point of bezier of interest
	let idx3 = idx0 + 3 // index of last point of bezier of interest
	if fabs(t) < 1e-10 { // cover special case: t≈0 and idx0 = last point of interest
		guard idx0 < points.count
		else { return nil }
		return points[points.startIndex.advanced(by: idx0)]
	}
	guard n >= 0, idx3 < points.count
	else { return nil }
	let i = points.startIndex.advanced(by: idx0)
	let a = points[i]
	let b = points[i.advanced(by: 1)]
	let c = points[i.advanced(by: 2)]
	let d = points[i.advanced(by: 3)]
	return pointAt(t: t, onBezier: a, b, c, d)
}

@discardableResult
public func disect(bezier a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint,
				   at t: CGFloat, into container: inout [CGPoint],
				   includingInitialPoint: Bool? = nil) -> Int?
{
	let includeInitial = includingInitialPoint ?? (container.isEmpty || a != container[0])
	let countWas = container.count

	let t0 = 1 - t
	let t1 = t

	guard fabs(t1) > 1e-10 && fabs(t0) > 1e-10 // near enough to first or last anchor point
	else {
		if includeInitial { container.append(a) }
		container.append(contentsOf: [b, c, d])
		return container.count - countWas
	}

	guard t >= 0, t <= 1.0
	else { return nil }

	let a_ = t0 * a + b * t1
	let b_ = t0 * b + c * t1
	let c_ = t0 * c + d * t1
	let ab_ = t0 * a_ + b_ * t1
	let bc_ = t0 * b_ + c_ * t1
	let abc = t0 * ab_ + bc_ * t1

	if includeInitial { container.append(a) }
	container.append(contentsOf: [a_, ab_, abc, bc_, c_, d])
	return container.count - countWas
}

@discardableResult
public func disect(bezier points: ArraySlice<CGPoint>,
				   at t: CGFloat, into container: inout [CGPoint],
				   includingInitialPoint incIP: Bool? = nil) -> Int?
{
	guard points.count == 4
	else { return nil }
	let i = points.startIndex
	let a = points[i]
	let b = points[i.advanced(by: 1)]
	let c = points[i.advanced(by: 2)]
	let d = points[i.advanced(by: 3)]
	return disect(bezier: a, b, c, d, at: t, into: &container, includingInitialPoint: incIP)
}

@discardableResult
public func divide(bezier a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint,
				   by count: Int, into container: inout [CGPoint],
				   includingInitialPoint: Bool? = nil) -> Int?
{
	guard count >= 0 else { return nil }
	let countWas = container.count
	if includingInitialPoint ?? (container.isEmpty || a != container[0]) {
		container.append(a)
	}
	var buffer = [a, b, c, d]
	var segment = count
	while segment > 0 {
		let i = buffer.endIndex
		let d_ = buffer[i.advanced(by: -1)]
		let c_ = buffer[i.advanced(by: -2)]
		let b_ = buffer[i.advanced(by: -3)]
		let a_ = buffer[i.advanced(by: -4)]
		buffer.removeAll()
		disect(bezier: a_, b_, c_, d_, at: 1.0 / CGFloat(segment),
			   into: &buffer, includingInitialPoint: true)
		container.append(contentsOf: buffer[1...3])
		segment -= 1
	}
	let i = buffer.endIndex.advanced(by: -3)
	container.append(contentsOf: buffer[i ..< buffer.endIndex] )
	return container.count - countWas
}

@discardableResult
public func divide(bezier points: ArraySlice<CGPoint>,
				   by count: Int, into container: inout [CGPoint],
				   includingInitialPoint incIP: Bool? = nil) -> Int?
{
	guard points.count == 4
	else { return nil }
	let i = points.startIndex
	let a = points[i]
	let b = points[i.advanced(by: 1)]
	let c = points[i.advanced(by: 2)]
	let d = points[i.advanced(by: 3)]
	return divide(bezier: a, b, c, d, by: count, into: &container, includingInitialPoint: incIP)
}

extension Unified.EdgeInsets {
	public init?(fromValues a: Array<CGFloat>) {
		self = .zero
		switch a.count {
			case 4: right = a[3] ; fallthrough
			case 3: bottom = a[2] ; fallthrough
			case 2: left = a[1] ; fallthrough
			case 1: top = a[0]
			default: return nil
		}
	}
	public init?(fromValues a: ArraySlice<CGFloat>) {
		self = .zero
		switch a.count {
			case 4: right = a[3] ; fallthrough
			case 3: bottom = a[2] ; fallthrough
			case 2: left = a[1] ; fallthrough
			case 1: top = a[0]
			default: return nil
		}
	}
	public init(all:CGFloat) {
		self.init(top:all,left:all,bottom:all,right:all)
	}
	public init(t:CGFloat=0,l:CGFloat=0,b:CGFloat=0,r:CGFloat=0) {
		self.init(top:t,left:l,bottom:b,right:r)
	}
}
