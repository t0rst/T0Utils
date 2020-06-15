/*
	TestGeometry.swift
	T0Utils

	Created by Torsten Louland on 28/06/2018.

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

import XCTest
import T0Utils



class TestGeometry: XCTestCase {

	// override func setUp() {
	//	super.setUp()
	//	// Put setup code here. This method is called before the invocation of each test method in the class.
	// }
	//
	// override func tearDown() {
	//	// Put teardown code here. This method is called after the invocation of each test method in the class.
	//	super.tearDown()
	// }

	func test_01_rotate() {
		// SignedInteger
		XCTAssertEqual(rotate(1, by: 0, within: 5), 1)
		XCTAssertEqual(rotate(6, by: 0, within: 5), 1)
		XCTAssertEqual(rotate(-1, by: 0, within: 5), 4)
		XCTAssertEqual(rotate(-6, by: 0, within: 5), 4)
		XCTAssertEqual(rotate(1, by: 1, within: 5), 2)
		XCTAssertEqual(rotate(1, by: 6, within: 5), 2)
		XCTAssertEqual(rotate(1, by: -4, within: 5), 2)
		XCTAssertEqual(rotate(1, by: -9, within: 5), 2)

		// FloatingPoint
		let a = 1e-10

		XCTAssertEqual(rotate(1.0, by: 0.0, within: 5.0), 1.0, accuracy: a)
		XCTAssertEqual(rotate(6.0, by: 0.0, within: 5.0), 1.0, accuracy: a)
		XCTAssertEqual(rotate(-1.0, by: 0.0, within: 5.0), 4.0, accuracy: a)
		XCTAssertEqual(rotate(-6.0, by: 0.0, within: 5.0), 4.0, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: 1.0, within: 5.0), 2.0, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: 6.0, within: 5.0), 2.0, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: -4.0, within: 5.0), 2.0, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: -9.0, within: 5.0), 2.0, accuracy: a)

		XCTAssertEqual(rotate(0.2, by: 0.0, within: 5.0), 0.2, accuracy: a)
		XCTAssertEqual(rotate(1.2, by: 0.0, within: 5.0), 1.2, accuracy: a)
		XCTAssertEqual(rotate(4.8, by: 0.0, within: 5.0), 4.8, accuracy: a)
		XCTAssertEqual(rotate(5.0, by: 0.0, within: 5.0), 0.0, accuracy: a)
		XCTAssertEqual(rotate(5.2, by: 0.0, within: 5.0), 0.2, accuracy: a)
		XCTAssertEqual(rotate(6.2, by: 0.0, within: 5.0), 1.2, accuracy: a)
		XCTAssertEqual(rotate(-0.2, by: 0.0, within: 5.0), 4.8, accuracy: a)
		XCTAssertEqual(rotate(-1.2, by: 0.0, within: 5.0), 3.8, accuracy: a)
		XCTAssertEqual(rotate(-4.8, by: 0.0, within: 5.0), 0.2, accuracy: a)
		XCTAssertEqual(rotate(-5.2, by: 0.0, within: 5.0), 4.8, accuracy: a)
		XCTAssertEqual(rotate(-6.2, by: 0.0, within: 5.0), 3.8, accuracy: a)
		XCTAssertEqual(rotate(1.2, by: 1.0, within: 5.0), 2.2, accuracy: a)
		XCTAssertEqual(rotate(1.2, by: 6.0, within: 5.0), 2.2, accuracy: a)
		XCTAssertEqual(rotate(1.2, by: -4.0, within: 5.0), 2.2, accuracy: a)
		XCTAssertEqual(rotate(1.2, by: -9.0, within: 5.0), 2.2, accuracy: a)

		XCTAssertEqual(rotate(1.0, by: 0.0, within: 2.4), 1.0, accuracy: a)
		XCTAssertEqual(rotate(6.0, by: 0.0, within: 2.4), 1.2, accuracy: a)
		XCTAssertEqual(rotate(-1.0, by: 0.0, within: 2.4), 1.4, accuracy: a)
		XCTAssertEqual(rotate(-6.0, by: 0.0, within: 2.4), 1.2, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: 1.0, within: 2.4), 2.0, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: 6.0, within: 2.4), 2.2, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: -4.0, within: 2.4), 1.8, accuracy: a)
		XCTAssertEqual(rotate(1.0, by: -9.0, within: 2.4), 1.6, accuracy: a)
	}

	func test_02_pointAt() {
		let a = CGFloat(1e-10)
		let bad = CGPoint(x: 999, y: 999)
		let b1 = [CGPoint(x: 0, y: 4), CGPoint(x: 1, y: 5), CGPoint(x: 2, y: 6), CGPoint(x: 3, y: 7)]
		let b1s = b1.dropFirst(0)

		XCTAssertEqual((pointAt(t: CGFloat(0/6.0), onBezier: b1s) ?? bad).x, CGFloat(0), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(0/6.0), onBezier: b1s) ?? bad).y, CGFloat(4), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(1/6.0), onBezier: b1s) ?? bad).x, CGFloat(0.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(1/6.0), onBezier: b1s) ?? bad).y, CGFloat(4.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(2/6.0), onBezier: b1s) ?? bad).x, CGFloat(1), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(2/6.0), onBezier: b1s) ?? bad).y, CGFloat(5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(3/6.0), onBezier: b1s) ?? bad).x, CGFloat(1.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(3/6.0), onBezier: b1s) ?? bad).y, CGFloat(5.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(4/6.0), onBezier: b1s) ?? bad).x, CGFloat(2), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(4/6.0), onBezier: b1s) ?? bad).y, CGFloat(6), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(5/6.0), onBezier: b1s) ?? bad).x, CGFloat(2.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(5/6.0), onBezier: b1s) ?? bad).y, CGFloat(6.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(6/6.0), onBezier: b1s) ?? bad).x, CGFloat(3), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(6/6.0), onBezier: b1s) ?? bad).y, CGFloat(7), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(7/6.0), onBezier: b1s) ?? bad).x, CGFloat(999), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(7/6.0), onBezier: b1s) ?? bad).y, CGFloat(999), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(-1/6.0), onBezier: b1s) ?? bad).x, CGFloat(999), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(-1/6.0), onBezier: b1s) ?? bad).y, CGFloat(999), accuracy: a)

		let p1 = [CGPoint(x: 0, y: 4), CGPoint(x: 1, y: 5), CGPoint(x: 2, y: 6), CGPoint(x: 3, y: 7),
									   CGPoint(x: 2, y: 8), CGPoint(x: 1, y: 9), CGPoint(x: 0, y: 10)]
		let p1s = p1.dropFirst(0)

		XCTAssertEqual((pointAt(t: CGFloat(5/6.0), onBezierPath: p1s) ?? bad).x, CGFloat(2.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(5/6.0), onBezierPath: p1s) ?? bad).y, CGFloat(6.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(6/6.0), onBezierPath: p1s) ?? bad).x, CGFloat(3), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(6/6.0), onBezierPath: p1s) ?? bad).y, CGFloat(7), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(7/6.0), onBezierPath: p1s) ?? bad).x, CGFloat(2.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(7/6.0), onBezierPath: p1s) ?? bad).y, CGFloat(7.5), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(12/6.0), onBezierPath: p1s) ?? bad).x, CGFloat(0), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(12/6.0), onBezierPath: p1s) ?? bad).y, CGFloat(10), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(13/6.0), onBezierPath: p1s) ?? bad).x, CGFloat(999), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(13/6.0), onBezierPath: p1s) ?? bad).y, CGFloat(999), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(-1/6.0), onBezierPath: p1s) ?? bad).x, CGFloat(999), accuracy: a)
		XCTAssertEqual((pointAt(t: CGFloat(-1/6.0), onBezierPath: p1s) ?? bad).y, CGFloat(999), accuracy: a)
	}

	func test_03_disect_bezier() {
		// Simplest case for convex hull bisection
		let b1 = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 0)]
		let b1s = b1.dropFirst(0)
		let expect = [
			CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0.5), CGPoint(x: 0.25, y: 0.75), CGPoint(x: 0.5, y: 0.75),
			CGPoint(x: 0.75, y: 0.75), CGPoint(x: 1, y: 0.5), CGPoint(x: 1, y: 0)]
		var result: [CGPoint] = []
		disect(bezier: b1s, at: 0.5, into: &result)
		XCTAssertEqual(result, expect, "disect(bezier: b1s, at: 0.5, into: &result)")
	}

	func test_04_divide_bezier() {
		func points(withOrdinals a: [Double]) -> [CGPoint] {
			return (0 ..< a.count).map { return CGPoint(x: a[$0], y: a[$0]) }
		}
		func sequence(from: Double = 0, to: Double = 1, steps: Int) -> [Double] {
			let increment = (to - from) / Double(steps)
			let seq = (0 ... steps).map { return Double($0) * increment }
			return seq
		}
		func divide_bezier(into count: Int) {
			let a = 1e-10
			let bz = points(withOrdinals: sequence(steps: 3))
			let expect = sequence(steps: 3 * count)
			var result: [CGPoint] = []
			divide(bezier: bz.dropFirst(0), by: count, into: &result)
			XCTAssertEqual(result.count, expect.count)
			var s = "divide Bézier[0..1] into \(count) gives: "
			var ok = true
			for rx in zip(result, expect) {
				s += String(format: " %.4f", rx.0.x)
				if fabs(Double(rx.0.x) - rx.1) > a || fabs(Double(rx.0.y) - rx.1) > a {
					s += String(format: " ≠%.4f!", rx.1)
					ok = false
				}
			}
			if !ok {
				XCTFail(s)
			}
		}
		divide_bezier(into: 1)
		divide_bezier(into: 2)
		divide_bezier(into: 3)
		divide_bezier(into: 4)
		divide_bezier(into: 5)
		divide_bezier(into: 6)
		divide_bezier(into: 7)
	}
}


