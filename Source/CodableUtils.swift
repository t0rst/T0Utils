//
//  CodableUtils.swift
//  T0Utils
//
//  Created by Torsten Louland on 15/06/2020.
//  Copyright © 2020 Torsten Louland. All rights reserved.
//

import Foundation



extension Decoder {

	/// Retrieve the keyed values that are not accessible to `container`, i.e. for which there is no
	/// key definition in the container's keys. Use to grab dynamic data or to detect unexpected
	/// missed data.
	public func keyedValuesOutside<K : CodingKey>(_ container: KeyedDecodingContainer<K>) throws
	-> [String:AnyJSONObject]? {
		let claimed = Set<String>(container.allKeys.compactMap({ $0.stringValue }))
		let general = try self.container(keyedBy: GeneralStringCodingKey.self)
		let unclaimed = general.allKeys.filter { !claimed.contains($0.stringValue) }
		if unclaimed.isEmpty { return nil }
		let outsiders = try unclaimed.reduce(into: [String:AnyJSONObject]()) {
			$0[$1.stringValue] = try general.decode(AnyJSONObject.self, forKey: $1)
		}
		return outsiders
	}
}



public struct GeneralStringCodingKey : CodingKey {
	public let		stringValue: String
	public init?   (stringValue: String)	{ self.stringValue = stringValue }
	public var		intValue: Int?			{ nil }
	public init?   (intValue: Int)			{ nil }
}



extension KeyedDecodingContainer {

	public func absentKeyCounter() -> AbsentKeys { .init() }

	/// Obtain an `AbsentKeys` instance from a `KeyedDecodingContainer.absentKeyCounter()` and use
	/// it to record use of fallback values where optional keys are not present in the data to
	/// decode.
	///
	/// Example use:
	/// ```Swift
	/// let container = try decoder.container(keyedBy: Key.self)
	/// var counter: AbsentKeys = container.absentKeyCounter()
	/// value1 = try container
	///     .decodeIfPresent(String.self,
	///         forKey: .value1, or: counter.fallbackTo("default"))
	/// value2 = try container
	///     .decodeIfPresent(Int.self,
	///         forKey: .value2, or: counter.fallbackTo(42))
	/// if counter.contains(.value1) && counter.contains(.value2) {
	///     throw DecodingError.dataCorrupted( ... ,
	///         "Must have either value1 or value2.")
	/// }
	/// ```
	/// The instance can be used to verify conditional requirements and to trigger action on
	/// abscence.
	@dynamicCallable
	public class AbsentKeys {
		public typealias 			Key = KeyedDecodingContainer<K>.Key

		public var count:			Int		{ names.count }
		public var keys:			[Key]	{ [String](names).sorted().compactMap({Key(stringValue:$0)}) }
		public func contains(_ key: Key) -> Bool { return names.contains(key.stringValue) }

		public func fallbackTo<T>(_ value: T) -> FallbackValue<T> { .init(value, self) }
		public func dynamicallyCall<T>(withArguments args: [T]) -> FallbackValue<T> {
			guard let value = args.first, args.count == 1
			else { preconditionFailure("exactly one argument expected") }
			return .init(value, self)
		}

		private var names:			Set<String> = .init()
		func absent(key: Key) { names.insert(key.stringValue) }

		public struct FallbackValue<T> {
			init(_ v: T, _ c: AbsentKeys) { value = v ; counter = c }
			private let value:		T
			private var counter:	AbsentKeys
			func yieldValue(forKey key: AbsentKeys.Key) -> T {
				counter.absent(key: key)
				return value
			}
		}
	}

	/// Decode a value of present, otherwise access a fallback value provided by an `AbsentKeys`
	/// instance.
	public func decodeIfPresent<T:Decodable>(
			_ type: T.Type,
			forKey key: KeyedDecodingContainer<K>.Key,
			or fallbackTo: @autoclosure ()->AbsentKeys.FallbackValue<T>) throws -> T {
		if let value = try decodeIfPresent(type, forKey: key) {
			return value
		}
		let fb = fallbackTo()
		return fb.yieldValue(forKey: key)
	}
}



