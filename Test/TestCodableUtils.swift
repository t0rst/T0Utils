//
//  TestCodableUtils.swift
//  T0Utils
//
//  Created by Torsten Louland on 15/06/2020.
//  Copyright © 2020 Torsten Louland. All rights reserved.
//

import XCTest
import T0Utils



class TestCodableUtils: XCTestCase {

	override func setUp()			{ super.setUp() /**/ }
	override func tearDown()		{ /**/ super.tearDown() }

	struct Sample : Codable {
		let name:		String
		let number:		Int
		let optionA:	Bool?
		let optionB:	Bool?

		enum Key : String, CodingKey { case name, number, optionA, optionB }

		let missing:	[Key]
		let excess:		[String:AnyJSONObject]?

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: Key.self)
			let counter = container.absentKeyCounter()
			name	= try container.decode(String.self, forKey: .name)
			number	= try container.decode(Int.self, forKey: .number)
			optionA	= try container.decodeIfPresent(Bool.self, forKey: .optionA, or: counter.fallbackTo(false))
			optionB	= try container.decodeIfPresent(Bool.self, forKey: .optionB, or: counter.fallbackTo(false))
			missing = counter.keys

			excess	= try decoder.keyedValuesOutside(container)
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: Key.self)
			try container.encode(name, forKey: .name)
			try container.encode(number, forKey: .number)
			try container.encodeIfPresent(optionA, forKey: .optionA)
			try container.encodeIfPresent(optionB, forKey: .optionB)
		}
	}

	func testAbsentAndExcessKeys() {
		guard
			let d1 = #"{"name":"A","number":1,"optionA":true,"optionC":true}"#.data(using: .utf8),
			let d2 = #"{"name":"A","number":1}"#.data(using: .utf8)
		else { XCTFail("Bad test data") ; return }

		let sample1 = try? JSONDecoder().decode(Sample.self, from: d1)
		XCTAssertNotNil(sample1)
		XCTAssertEqual(sample1?.missing, [Sample.Key.optionB])

		XCTAssertNotNil(sample1?.excess)
		XCTAssertNotNil(sample1?.excess?["optionC"])
		if case .bool(true) = sample1?.excess?["optionC"] {} else { XCTFail("missed param") }

		let sample2 = try? JSONDecoder().decode(Sample.self, from: d2)
		XCTAssertNotNil(sample2)
		XCTAssertEqual(sample2?.missing, [Sample.Key.optionA, Sample.Key.optionB])
		XCTAssertNil(sample2?.excess)
	}
}


