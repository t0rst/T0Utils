/*
	TestJSONObject.swift
	T0Utils

	Created by Torsten Louland on 01/03/2018.

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



class TestJSONObject : XCTestCase {

	override func setUp()			{ super.setUp() /**/ }
	override func tearDown()		{ /**/ super.tearDown() }

	func decodeJSONObject(from string: String) -> AnyJSONObject? {
		var obj: AnyJSONObject? = nil
		// Always wrap string in an outer array, as decoder has no strategy to allow simple types
		// at root, i.e. no equivalent of JSONSerialization.ReadingOptions.allowFragments - even
		// though it uses JSONSerialization to fill the root decoding container!
		guard let data = "[\(string)]".data(using: .utf8)
		else { XCTFail("Bad test data: \(string)") ; return obj }
		do {
			let decoded = try JSONDecoder().decode(AnyJSONObject.self, from: data)
			if case .array(let a) = decoded {
				obj = a.first
			}
		}
		catch {
			XCTFail("decodeJSONObject from\n\(string)\nfailed with\n\(error)")
		}
		return obj
	}

	func testJSONObject() {
		// Simple
		XCTAssertEqual("a", decodeJSONObject(from: "\"a\"")?.asObject as? String)
		XCTAssertEqual(1, decodeJSONObject(from: "1")?.asObject as? Int)
		XCTAssertEqual(1.5, decodeJSONObject(from: "1.5")?.asObject as? Double)
		XCTAssertEqual(true, decodeJSONObject(from: "true")?.asObject as? Bool)
		XCTAssert(decodeJSONObject(from: "[]")?.asObject is [Any])
		XCTAssert(decodeJSONObject(from: "{}")?.asObject is [AnyHashable:Any])
		// Compound
		guard let data =
			"""
			{
				"d":{"key":"value"},
				"a":[0,1,2],
				"s":"string",
				"i":1,
				"f":1.0e-30,
				"b":true,
				"trivial_d":{},
				"trivial_a":[],
				"trivial_s":"",
				"trivial_i":0,
				"trivial_f":0.0,
				"trivial_b":false,
			}
			""".data(using: .utf8)
		else { XCTFail("Bad test data") ; return }
		var any: AnyJSONObject? = nil
		XCTAssertNoThrow(any = try JSONDecoder().decode(AnyJSONObject.self, from: data))
		guard let obj = any
		else { XCTFail("Expected decoded AnyJSONObject") ; return }
		guard case .dictionary(let d) = obj
		else { XCTFail("Expected disctionary at root") ; return }

		XCTAssertEqual(1, d["d"]?.asDictionary?.count)
		XCTAssertEqual(3, d["a"]?.asArray?.count)
		XCTAssertEqual(true, d["a"]?.asArray?[0].isNotNull)
		XCTAssertEqual("string", d["s"]?.asString)
		XCTAssertEqual(1, d["i"]?.asInt)
		XCTAssertEqual(1e-30, d["f"]?.asDouble)
		// ...failing on macOS because of small rounding errors because JSONSerialization on macOS
		// decodes as single precision, but we store at double.
		XCTAssertEqual(true, d["b"]?.asBool)

		// String conversions
		XCTAssertEqual(nil, d["d"]?.asString)
		XCTAssertEqual(nil, d["a"]?.asString)
		XCTAssertEqual("1", d["i"]?.asString)
		XCTAssertEqual(1e-30, Double(d["f"]?.asString ?? ""))
		XCTAssertEqual("true", d["b"]?.asString)

		XCTAssertNotNil(obj.asObject as? [String:Any])

		// Trivial equivalences
		XCTAssertEqual(true, d["trivial_a"]?.asDictionary?.isEmpty)
		XCTAssertEqual(true, d["trivial_s"]?.asDictionary?.isEmpty)
		XCTAssertEqual(true, d["trivial_i"]?.asDictionary?.isEmpty)
		XCTAssertEqual(true, d["trivial_f"]?.asDictionary?.isEmpty)
		XCTAssertEqual(true, d["trivial_b"]?.asDictionary?.isEmpty)
		XCTAssertEqual(true, d["trivial_d"]?.asArray?.isEmpty)
		XCTAssertEqual(true, d["trivial_s"]?.asArray?.isEmpty)
		XCTAssertEqual(true, d["trivial_i"]?.asArray?.isEmpty)
		XCTAssertEqual(true, d["trivial_f"]?.asArray?.isEmpty)
		XCTAssertEqual(true, d["trivial_b"]?.asArray?.isEmpty)
		XCTAssertEqual(true, d["trivial_d"]?.asString?.isEmpty)
		XCTAssertEqual(true, d["trivial_a"]?.asString?.isEmpty)
	}
}
