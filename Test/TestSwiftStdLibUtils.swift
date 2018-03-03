/*
	TestSwiftStdLibUtils.swift
	T0Utils

	Created by Torsten Louland on 05/02/2018.

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



class TestSwiftStdLibUtils : XCTestCase {
	
	override func setUp() { super.setUp() /**/ }
	override func tearDown() { /**/ super.tearDown() }

	enum EE : EnumWithOrdinal {
		case A, B, C, D
		var ordinal: Int { switch self {
			case .A:	return 0
			case .B:	return 1
			case .C:	return 2
			case .D:	return 3
		} }
		static var ordinalMax	= 3
		static var count		= 4

		init?(ordinal: Int) { switch ordinal {
			case 0:		self = .A
			case 1:		self = .B
			case 2:		self = .C
			case 3:		self = .D
			default:	return nil
		} }
	}

	func testEnumWithOrdinal() {
		XCTAssert(EE.A.predecessor == nil)
		XCTAssert(EE.A.successor == EE.B)
		XCTAssert(EE.D.predecessor == EE.C)
		XCTAssert(EE.D.successor == nil)
		XCTAssertEqual([EE](EE.A.upTo(EE.D)), [EE.A, EE.B, EE.C])
		XCTAssertEqual([EE](EE.A.upThrough(EE.D)), [EE.A, EE.B, EE.C, EE.D])
		XCTAssertEqual([EE](EE.D.upTo(EE.A)), [])
		XCTAssertEqual([EE](EE.D.upThrough(EE.A)), [])
		XCTAssertEqual([EE](EE.A.downTo(EE.D)), [])
		XCTAssertEqual([EE](EE.A.downThrough(EE.D)), [])
		XCTAssertEqual([EE](EE.D.downTo(EE.A)), [EE.D, EE.C, EE.B])
		XCTAssertEqual([EE](EE.D.downThrough(EE.A)), [EE.D, EE.C, EE.B, EE.A])
	}

	struct OS : OptionSetForEnum {
		typealias Enum = EE
		let	 rawValue: Int
		init(rawValue: Int)				{ self.rawValue = rawValue }
		static let all =				OS.setOfAllEnum()
		static let none =				OS.setOfNone()
		static let A = OS(EE.A), B = OS(EE.B), C = OS(EE.C), D = OS(EE.D)
	}

	func testOptionSetForEnum() {
		XCTAssertEqual([EE](OS.all.enums()), [EE.A, EE.B, EE.C, EE.D])
		XCTAssertEqual([EE](OS.all.enumsReversed()), [EE.D, EE.C, EE.B, EE.A])
		XCTAssertEqual([EE](OS([.A,.C]).enums()), [EE.A, EE.C])
		XCTAssertEqual([EE](OS([.A,.C]).enumsReversed()), [EE.C, EE.A])
		XCTAssertEqual([EE](OS([.B,.D]).enums()), [EE.B, EE.D])
		XCTAssertEqual([EE](OS([.B,.D]).enumsReversed()), [EE.D, EE.B])
		XCTAssertEqual([EE](OS([EE.A,EE.C]).enums()), [EE.A, EE.C])
		XCTAssertEqual([EE](OS([EE.A,EE.C]).enumsReversed()), [EE.C, EE.A])
		XCTAssertEqual([EE](OS([EE.B,EE.D]).enums()), [EE.B, EE.D])
		XCTAssertEqual([EE](OS([EE.B,EE.D]).enumsReversed()), [EE.D, EE.B])
	}
}
