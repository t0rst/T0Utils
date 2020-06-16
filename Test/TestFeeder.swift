/*
	TestFeeder.swift
	T0Utils

	Created by Torsten Louland on 27/11/2017.

	MIT License

	Copyright (c) 2017 Torsten Louland

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



class TestFeeder: XCTestCase {
	
	// override func setUp() {
	//	super.setUp()
	//	// Put setup code here. This method is called before the invocation of each test method in the class.
	// }
	//
	// override func tearDown() {
	//	// Put teardown code here. This method is called after the invocation of each test method in the class.
	//	super.tearDown()
	// }
	
	func test_00_empty() {
		// Given
		let expectation = self.expectation(description: "should complete")
		let valuesStart = [Int]()
		let valuesIn = valuesStart
		var valuesRemaining = valuesIn[..<valuesIn.endIndex]
		var valuesOut = [Int]()
		typealias IntFeeder = Feeder<Int>
		let getSize = 3
		let doGet: IntFeeder.DoGet = {
			let n = min(getSize, valuesRemaining.count)
			let values = Array(valuesRemaining.prefix(n))
			valuesRemaining = valuesRemaining.dropFirst(n)
			$0(values)
		}
		let doAct: IntFeeder.DoAct = {
			valuesOut.append($0)
			$1($0, nil)
		}
		let feeder = IntFeeder(
			doGet:			doGet,
			doAct:			doAct,
			didComplete:	{ expectation.fulfill() }
		)

		// When
		feeder.start()
		waitForExpectations(timeout: 0.1, handler: nil)

		// Then
		XCTAssert(valuesRemaining.isEmpty)
		XCTAssert(valuesOut == valuesIn)
	}

	func test_01_synchronous() {
		// Given
		let expectation = self.expectation(description: "should complete")
		let valuesStart = [Int](0..<10)
		let valuesIn = valuesStart
		var valuesRemaining = valuesIn[..<valuesIn.endIndex]
		var valuesOut = [Int]()
		typealias IntFeeder = Feeder<Int>
		let getSize = 3
		let doGet: IntFeeder.DoGet = {
			let n = min(getSize, valuesRemaining.count)
			let values = Array(valuesRemaining.prefix(n))
			valuesRemaining = valuesRemaining.dropFirst(n)
			$0(values)
		}
		let doAct: IntFeeder.DoAct = {
			valuesOut.append($0)
			$1($0, nil)
		}
		let feeder = IntFeeder(
			doGet:			doGet,
			doAct:			doAct,
			didComplete:	{ expectation.fulfill() }
		)

		// When
		feeder.start()
		waitForExpectations(timeout: 0.1, handler: nil)

		// Then
		XCTAssert(valuesRemaining.isEmpty)
		XCTAssert(valuesOut == valuesIn)
	}

	func test_02_asynchronous() {
		// Given
		let expectation = self.expectation(description: "should complete")
		let valuesStart = [Int](0..<10)
		let valuesIn = valuesStart
		var valuesRemaining = valuesIn[..<valuesIn.endIndex]
		var valuesOut = [Int]()
		typealias IntFeeder = Feeder<Int>
		let getSize = 3
		let doGet: IntFeeder.DoGet = { didGet in
			let n = min(getSize, valuesRemaining.count)
			let values = Array(valuesRemaining.prefix(n))
			valuesRemaining = valuesRemaining.dropFirst(n)
			DispatchQueue.main.async { didGet(values) }
		}
		let doAct: IntFeeder.DoAct = { (value, didAct) in
			valuesOut.append(value)
			DispatchQueue.main.async { didAct(value, nil) }
		}
		let feeder = IntFeeder(
			doGet:			doGet,
			doAct:			doAct,
			didComplete:	{ expectation.fulfill() }
		)

		// When
		feeder.start()
		waitForExpectations(timeout: 0.1, handler: nil)

		// Then
		XCTAssert(valuesRemaining.isEmpty)
		XCTAssert(valuesOut == valuesIn)
	}

	func test_03_asynchronous_concurrent() {
		// Given
		let expectation = self.expectation(description: "should complete")
		let valuesStart = [Int](0..<50)
		let valuesIn = valuesStart
		var valuesRemaining = valuesIn[..<valuesIn.endIndex]
		var valuesOut = [Int]()
		typealias IntFeeder = Feeder<Int>
		let getSize = 3
		let doGet: IntFeeder.DoGet = { didGet in
			let n = min(getSize, valuesRemaining.count)
			let values = Array(valuesRemaining.prefix(n))
			valuesRemaining = valuesRemaining.dropFirst(n)
			DispatchQueue.main.async { didGet(values) }
		}
		let doAct: IntFeeder.DoAct = { (value, didAct) in
			valuesOut.append(value)
			DispatchQueue.main.async { didAct(value, nil) }
		}
		let feeder = IntFeeder(
			doGet:			doGet,
			doAct:			doAct,
			concurrent:		{ 5 },
			didComplete:	{ expectation.fulfill() }
		)

		// When
		feeder.start()
		waitForExpectations(timeout: 0.1, handler: nil)

		// Then
		XCTAssert(valuesRemaining.isEmpty)
		XCTAssert(valuesOut == valuesIn)
	}

	// func testPerformanceExample() {
	//	// This is an example of a performance test case.
	//	self.measure {
	//		// Put the code you want to measure the time of here.
	//	}
	// }
	
}
