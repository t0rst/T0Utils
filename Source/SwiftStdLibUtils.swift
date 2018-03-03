/*
	SwiftStdLibUtils.swift
	T0Utils

	Created by Torsten Louland on 18/11/2017.

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



// ========================================================================================
//   A few small swift library helpers
// ========================================================================================



/// Promise explicit ordering within enumerations
///
/// By default Swift hides internal ordering of enum values. Adopt this protocol to make ordering
/// visible. This allows several other useful features: predecessor and successor, iteration over
/// ranges, and making coordinated OptionSets, by adopting partner protocol OptionSetForEnum,
/// which makes easy conversion between the two possible.
/// This protocol is not currently suitable for enums with associated values, as its not possible
/// to know how to create the cases with associated values given just an ordinal.
public protocol EnumWithOrdinal
{
	var ordinal:				Int { get }

	init?(ordinal: Int)

	static var ordinalMax:	Int { get }
	static var count:		Int { get }
}



public extension EnumWithOrdinal
{
	public var predecessor:			Self? { return Self(ordinal: self.ordinal - 1) }
	public var successor:			Self? { return Self(ordinal: self.ordinal + 1) }

	public func upTo(_ other: Self)			-> AnySequence<Self> { return self.to(other, up: true, through: false) }
	public func upThrough(_ other: Self)	-> AnySequence<Self> { return self.to(other, up: true, through: true) }
	public func downTo(_ other: Self)		-> AnySequence<Self> { return self.to(other, up: false, through: false) }
	public func downThrough(_ other: Self)	-> AnySequence<Self> { return self.to(other, up: false, through: true) }

	public func to(_ other: Self, up: Bool, through: Bool) -> AnySequence<Self> {
		var cursor: Self? = self
		let delta = up ? 1 : -1, limit = through ? 0 : 1, targetOrdinal = other.ordinal
		return AnySequence {
			return AnyIterator {
				var this: Self? = nil
				if	let ordinal = cursor?.ordinal {
					let diff = (targetOrdinal - ordinal) * delta
					if limit <= diff {
						this = cursor
						cursor = Self(ordinal: ordinal + delta) ?? nil
					}
				}
				return this
			}
		}
	}
}



// MARK: -

/// Promise that an option derives its values from an enumeration where ordinals are known.
///
///
public protocol OptionSetForEnum : OptionSet
{
	associatedtype Enum : EnumWithOrdinal
}



public extension OptionSetForEnum where RawValue == Int
{
	public init(_ e: Enum)						{ self.init(rawValue: 1 << e.ordinal) }

	/// Construct from anything that can yield sequence of enums, e.g. arrays, ranges, iterators, etc
	public init<SeqOfEnum>(_ seq: SeqOfEnum) where SeqOfEnum : Sequence, SeqOfEnum.Element == Enum {
		self.init(rawValue: seq.reduce(0, { $0 | (1 << $1.ordinal) } ))
	}

	/// Yield the enums we represent as a sequence
	public func enums() -> AnySequence<Enum> {
		var bits = rawValue, index = -1
		return AnySequence {
			return AnyIterator {
				while bits != 0 {
					index += 1
					if 0 != bits & (1 << index) {
						bits &= ~(1 << index)
						if let e = Enum(ordinal: index) {
							return e
						}
					}
				}
				return nil
			}
		}
	}

	public func enumsReversed() -> AnySequence<Enum> {
		var index = Enum.count
		var bits = rawValue & ((1 << index) - 1)
		return AnySequence {
			return AnyIterator {
				while bits != 0 {
					index -= 1
					if 0 != bits & (1 << index) {
						bits &= ~(1 << index)
						if let e = Enum(ordinal: index) {
							return e
						}
					}
				}
				return nil
			}
		}
	}

	public static func setOfNone() -> Self		{ return Self(rawValue: 0) }
	public static func setOfAllEnum() -> Self	{ return Self(rawValue: (1 << Enum.count) - 1) }
}



// MARK: -

/// TypeThatCanSupplyInitialValue can be used as a requirement for types held within generic types
/// where the way of making an initial instance is not known, i.e. it is not known what parameters
/// must be supplied to make an instance. Requiring parameterless initialisation via `init()`
/// might seem attractive, but would have to be implemented for Optional, with risk of widespread
/// side effects. By requiring an explicit static member, the behaviour is more visible.
public protocol TypeThatCanSupplyInitialValue
{
	static func initialValue() -> Self
}

extension Optional : TypeThatCanSupplyInitialValue
{
	public static func initialValue() -> Optional<Wrapped> {
		return .none
	}
}


