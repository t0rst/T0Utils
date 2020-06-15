/*
	JSONObject.swift
	T0Utils

	Created by Torsten Louland on 18/10/2017.

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

import Foundation



/// AnyJSONObject can represent any JSON object for the purpose of decoding/encoding.
/// Where JSONSerialisation would decode a JSON object into an untyped NSDictionary, the newer
/// JSONDecoder refuses to decode [AnyHashable:Any], the swift equivalent of NSDictionary, because
/// neither key nor value are guaranteed to be Codable (even though we know the reality).
/// AnyJSONObject is an enumeration that stores a corresponding associated JSON value in each case.
/// Hopefully it will soon become obsolete with a newer version of Swift.
///
/// AnyJSONObject also allows you to cope with loose typing where the JSON has been generated by
/// JavaScript: the as<Type> accessors will convert where possible, typically any empty value can
/// converted to another empty value, any POD type can be converted to a string, and vice versa
/// where exactly representable.
@dynamicMemberLookup
public enum AnyJSONObject : Codable
{
	case string(String)
	case int(Int)
	case double(Double)
	case bool(Bool)
	case array([AnyJSONObject])
	case dictionary([String:AnyJSONObject])
	case null

	public init(from decoder: Decoder) throws {
		let values = try decoder.singleValueContainer()
		do {
			self = .string(try values.decode(String.self))
			return
		}
		catch DecodingError.typeMismatch {}
		// We try to decode Bool now, otherwise it will decode as Int 1/0
		do {
			self = .bool(try values.decode(Bool.self))
			return
		}
		catch DecodingError.typeMismatch {}
		// Try decoding Int before Double. If the value is a number but needs floating point
		// representation, then the container will throw DecodingError.dataCorrupted(≈"number
		// <0.123> does not fit in Int") rather than typeMismatch. If its a real data corruption -
		// a malformed number - than it will be picked up when we decode as Double, and we let the
		// exception fall through.
		// Alternatively, instead of .int and .double in our cases, we could just have .number and
		// decode once into Float80, which can represent all Int and all Double, then users of this
		// instance can access via asInt or asDouble, with the downside that the type checking is
		// defered until after reading the JSON.
		do {
			self = .int(try values.decode(Int.self))
			return
		}
		catch DecodingError.typeMismatch {}
		catch DecodingError.dataCorrupted(_) {}
		do {
			self = .double(try values.decode(Double.self))
			return
		}
		catch DecodingError.typeMismatch {}
		do {
			self = .array(try values.decode([AnyJSONObject].self))
			return
		}
		catch DecodingError.typeMismatch {}
		if values.decodeNil() {
			self = .null
			return
		}
		self = .dictionary(try values.decode([String:AnyJSONObject].self))
	}

	enum Errors : Error {
		case unrepresentable(object: Any, atPath: String)
	}

	/// Where you have been supplied an untyped object which ought to be encodable as JSON, but you
	/// don't know for sure, attempt to create an AnyJSONObject instance from it, then write it out.
	public init(any: Any, _ path: String? = nil) throws { switch any {
		case let s as String:
			self = .string(s)
		case let b as Bool:
			self = .bool(b)
		case let i as Int:
			self = .int(i)
		case let d as Double:
			self = .double(d)
		case let aa as [Any]:
			let p = path?.appending(".") ?? ""
			var a = [AnyJSONObject]()
			try aa.forEach { a.append(try AnyJSONObject(any: $0, p.appending("\(a.count)"))) }
			self = .array(a)
		case let dd as [String:Any]:
			let p = path?.appending(".") ?? ""
			var d = [String:AnyJSONObject]()
			try dd.forEach { d[$0.key] = try AnyJSONObject(any: $0.value, p.appending($0.key)) }
			self = .dictionary(d)
		case _ as NSNull:
			self = .null
		default:
			throw Errors.unrepresentable(object: any, atPath: path ?? "")
	} }

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
			case .string(let s):	try container.encode(s)
			case .int(let i):		try container.encode(i)
			case .double(let d):	try container.encode(d)
			case .bool(let b):		try container.encode(b)
			case .array(let a):		try container.encode(a)
			case .dictionary(let d):try container.encode(d)
			case .null:				try container.encodeNil()
		}
	}

	public var isNull:		Bool		{ if case .null = self { return true} else { return false } }
	/// Use `isNotNull` to test for an affirmative result at the end of a chain of optionals
	public var isNotNull:	Bool		{ if case .null = self { return false} else { return true } }

	/// Extract from enum wrapper
	public var asObject: Any {
		switch self {
			case .string(let obj):
				return obj
			case .int(let obj):
				return obj
			case .double(let obj):
				return obj
			case .bool(let obj):
				return obj
			case .array(let obj):
				let array = obj.map { $0.asObject }
				return array
			case .dictionary(let obj):
				let pairs = obj.map { ($0.key, $0.value.asObject) }
				let dictionary = Dictionary(uniqueKeysWithValues: pairs)
				return dictionary
			case .null:
				return NSNull()
		}
	}

	// as POD types
	public var asString:	String? { switch self {
		case .dictionary(let d) where d.isEmpty:return ""
		case .array(let a) where a.isEmpty:		return ""
		case .string(let s):	return s
		case .double(let d):	return d.description
		case .int(let i):		return i.description
		case .bool(let b):		return b ? "true" : "false"
		default:				return nil
	} }
	public var asInt:		Int?	{ switch self {
		case .dictionary(let d) where d.isEmpty:return 0
		case .array(let a) where a.isEmpty:		return 0
		case .string(let s):	return Int(s)
		case .double(let d):	return Int(exactly: d)
		case .int(let i):		return i
		case .bool(let b):		return b ? 1 : 0
		default:				return nil
	} }
	public var asDouble:	Double? { switch self {
		case .dictionary(let d) where d.isEmpty:return 0
		case .array(let a) where a.isEmpty:		return 0
		case .string(let s):	return Double(s)
		case .double(let d):	return d
		case .int(let i):		return Double(i)
		case .bool(let b):		return b ? 1.0 : 0.0
		default:				return nil
	} }
	public var asFloat:	Float? { switch self {
		case .dictionary(let d) where d.isEmpty:return 0
		case .array(let a) where a.isEmpty:		return 0
		case .string(let s):	return Float(s)
		case .double(let d):	return Float(d)//(exactly: d) fixme: want- if exponents same, ignore rounding
		case .int(let i):		return Float(i)
		case .bool(let b):		return b ? 1.0 : 0.0
		default:				return nil
	} }
	public var asBool:		Bool?	{ switch self {
		case .dictionary(let d) where d.isEmpty:	return false
		case .array(let a) where a.isEmpty:			return false
		case .string(let s):	switch s {
			case "true", "TRUE", "yes", "YES", "1":	return true
			case "false", "FALSE", "no", "NO", "0":	return false
			default:								return nil
		}
		case .double(let d):	return d != 0.0
		case .int(let i):		return i != 0
		case .bool(let b):		return b
		default:				return nil
	} }
	// compound types
	public var asDictionary: [String:AnyJSONObject]? { switch self {
		case .dictionary(let d):				return d
		case .array(let a) where a.isEmpty:		return [:]
		case .string(let s) where s.isEmpty:	return [:]
		case .double(let d) where d == 0:		return [:]
		case .int(let i) where i == 0:			return [:]
		case .bool(let b) where b == false:		return [:]
		default:								return nil
	} }
	public var asArray: [AnyJSONObject]? { switch self {
		case .dictionary(let d) where d.isEmpty:return []
		case .array(let a):						return a
		case .string(let s) where s.isEmpty:	return []
		case .double(let d) where d == 0:		return []
		case .int(let i) where i == 0:			return []
		case .bool(let b) where b == false:		return []
		default:								return nil
	} }

	public func value(at keyPath: String) -> AnyJSONObject? {
		if keyPath.isEmpty { return self }
		switch self {
			case .dictionary(let d):
				let parts = keyPath.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
				let key = String(parts[0])
				if let obj = d[key] {
					if 1 < parts.count {
						let path = parts[1]
						return obj.value(at: String(path))
					} else {
						return obj
					}
				}
			case .array(let a):
				let parts = keyPath.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
				let s = String(parts[0])
				if let i = Int(s), i < a.count {
					let obj = a[i]
					if  1 < parts.count {
						let path = parts[1]
						return obj.value(at: String(path))
					} else {
						return obj
					}
				}
			default:
				break
		}
		return nil
	}

	public subscript(dynamicMember member: String) -> AnyJSONObject? { switch self {
		case .dictionary(let d):		return d[member]
		default:						return nil
	} }

	public subscript(key: String) -> AnyJSONObject? { switch self {
		case .dictionary(let d):		return d[key]
		default:						return nil
	} }

	public subscript(index x: Int) -> AnyJSONObject? { switch self {
		case .array(let a):				return 0 <= x && x < a.count ? a[x] : nil
		default:						return nil
	} }

	public func hasValue(forKey k: String) -> Bool { switch self {
		case .dictionary(let d):		return d.index(forKey: k) != nil
		default:						return false
	} }

	public func hasValue(atIndex x: Int) -> Bool { switch self {
		case .array(let a):				return 0 <= x && x < a.count
		default:						return false
	} }
}



/// AnySimpleJSONObject can represent JSON plain old data type. It is intended for cases where this
/// is a legitemate expectation, rather than a workaround for occasional type uncertainty.
public enum AnySimpleJSONObject : Codable
{
	case string(String)
	case int(Int)
	case double(Double)
	case bool(Bool)
	case null

	public var asString:	String? { switch self {
		case .string(let s):	return s
		case .double(let d):	return d.description
		case .int(let i):		return i.description
		case .bool(let b):		return b ? "true" : "false"
		case .null:				return nil
	} }
	public var asInt:		Int?	{ switch self {
		case .string(let s):	return Int(s)
		case .double(let d):	return Int(d)
		case .int(let i):		return i
		case .bool(let b):		return b ? 1 : 0
		case .null:				return nil
	} }
	public var asDouble:	Double? { switch self {
		case .string(let s):	return Double(s)
		case .double(let d):	return d
		case .int(let i):		return Double(i)
		case .bool(let b):		return b ? 1.0 : 0.0
		case .null:				return nil
	} }
	public var asBool:		Bool?	{ switch self {
		case .string(let s):	return !s.isEmpty
		case .double(let d):	return d != 0.0
		case .int(let i):		return i != 0
		case .bool(let b):		return b
		case .null:				return nil
	} }

	public var toString:	String	{ return asString ?? "" }
	public var toInt:		Int		{ return asInt ?? 0 }
	public var toDouble:	Double	{ return asDouble ?? 0.0 }
	public var toBool:		Bool	{ return asBool ?? false }

	public init(from decoder: Decoder) throws {
		let values = try decoder.singleValueContainer()
		do {
			self = .string(try values.decode(String.self))
			return
		}
		catch DecodingError.typeMismatch {}
		do {
			self = .int(try values.decode(Int.self))
			return
		}
		catch DecodingError.typeMismatch {}
		catch DecodingError.dataCorrupted(_) {} // catch int decode error where type is float
		do {
			self = .double(try values.decode(Double.self))
			return
		}
		catch DecodingError.typeMismatch {}
		if values.decodeNil() {
			self = .null
			return
		}
		self = .bool(try values.decode(Bool.self))
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
			case .string(let s): try container.encode(s)
			case .int(let i):	 try container.encode(i)
			case .double(let d): try container.encode(d)
			case .bool(let b):	 try container.encode(b)
			case .null:			 try container.encodeNil()
		}
	}
}



/// JSONStringable will represent any non-container JSON object as a string, hence tolerates
/// numbers, booleans and nulls where strings were expected; this is useful when the JSON has been
/// generated by JavaScript and loose typing can lead to numeric strings being converted to numbers
/// where not wanted.
public struct JSONStringable : Codable {
	public var value: String
	public init(_ value: String = "") {
		self.value = ""
	}
	public init(from decoder: Decoder) throws {
		let values = try decoder.singleValueContainer()
		do {
			value = try values.decode(String.self)
			return
		}
		catch DecodingError.typeMismatch {}
		do {
			let int = try values.decode(Int.self)
			value = int.description
			return
		}
		catch DecodingError.typeMismatch {}
		catch DecodingError.dataCorrupted(_) {} // catch int decode error where type is float
		do {
			let double = try values.decode(Double.self)
			value = double.description
			return
		}
		catch DecodingError.typeMismatch {}
		if values.decodeNil() {
			value = ""
			return
		}
		let bool = try values.decode(Bool.self)
		value = bool.description
	}
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(value)
	}
}



public extension JSONEncoder
{
	enum EncodePairError : Error {
		case incompatibleTopLevelObjects
		case dataWithEncodingFailed
	}
	/// Encode a pair of objects and merge their JSON representations.
	///
	/// Use this to simulate injection of extra parameters before serializing and sending an object
	/// through an API call - this can happen where the API was designed with dynamic langauges in
	/// mind.
	///
	/// The caller must ensure that supplied objects both yield the same kind of compound object
	/// (dictionary or array) at top JSON level and that, in the case of combining dictionaries,
	/// the top level keys for each object are distinct. If the latter is not the case, then
	/// invalid JSON will be returned, as no checking is done.
	func encodePair<T : Encodable, U : Encodable>(_ value1: T, _ value2: U) throws -> Data
	{
		let data1 = try encode(value1)
		let data2 = try encode(value2)
		let string1 = String(data: data1, encoding: .utf8) ?? ""
		let string2 = String(data: data2, encoding: .utf8) ?? ""
		switch (string1.last, string2.first) {
			case (.some("}"), .some("{")), (.some("]"), .some("[")):
				let string = "\(string1.dropLast()),\(string2.dropFirst())"
				guard let data = string.data(using: .utf8) else {
					throw EncodePairError.dataWithEncodingFailed // when ??!!
				}
				return data
			default:
			//	print("Unsuitable to combine: \(string1) + \(string2)")
				throw EncodePairError.incompatibleTopLevelObjects
		}
	}
}


