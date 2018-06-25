/*
	Logging.swift
	T0Utils

	Created by Torsten Louland on 05/10/2017.

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



/// For internal use; see comment above `T0Logging`; do likewise in your app.
class Log : T0Logging {}



/// Bottleneck for logging. 
///
/// You can make T0Logging visible to all your sources without requiring an import in
/// each one by defining and using a trival subclass in your code:
///
/// ```Swift
/// class Log : T0Logging {}
/// // then use elsewhere...
/// Log.info("Processing param \(n): \(param)...")
/// ```
open class T0Logging {

	@inlinable public static func	fatal										 (_ msg: @autoclosure () -> String) { self.log(msg, cat: .fatal) }
	@inlinable public static func	fatalIf		(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIf(test, msg, cat: .fatal) }
	@inlinable public static func	fatalIfNot	(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIfNot(test, msg, cat: .fatal) }
	@inlinable public static func	error										 (_ msg: @autoclosure () -> String) { self.log(msg, cat: .error) }
	@inlinable public static func	errorIf		(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIf(test, msg, cat: .error) }
	@inlinable public static func	errorIfNot	(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIfNot(test, msg, cat: .error) }
	@inlinable public static func	fault										 (_ msg: @autoclosure () -> String) { self.log(msg, cat: .fault) }
	@inlinable public static func	faultIf		(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIf(test, msg, cat: .fault) }
	@inlinable public static func	faultIfNot	(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIfNot(test, msg, cat: .fault) }
	// ...fault means should never occur and is under our control, which means a logic fubar somewhere.

	@inlinable public static func	warning										 (_ msg: @autoclosure () -> String) { self.log(msg, cat: .warning) }
	@inlinable public static func	warningIf	(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIf(test, msg, cat: .warning) }
	@inlinable public static func	warningIfNot(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIfNot(test, msg, cat: .warning) }
	@inlinable public static func	event										 (_ msg: @autoclosure () -> String) { self.log(msg, cat: .event) }
	@inlinable public static func	eventIf		(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIf(test, msg, cat: .event) }
	@inlinable public static func	eventIfNot	(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIfNot(test, msg, cat: .event) }
	@inlinable public static func	info										 (_ msg: @autoclosure () -> String) { self.log(msg, cat: .info) }
	@inlinable public static func	infoIf		(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIf(test, msg, cat: .info) }
	@inlinable public static func	infoIfNot	(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIfNot(test, msg, cat: .info) }
	@inlinable public static func	call										 (_ msg: @autoclosure () -> String) { self.log(msg, cat: .call) }
	@inlinable public static func	callIf		(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIf(test, msg, cat: .call) }
	@inlinable public static func	callIfNot	(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String) { self.logIfNot(test, msg, cat: .call) }

	@inlinable public static
	func logIf(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String, cat: Category) {
		if self.will_log(cat: cat) && test() {
			self.log( self.label(cat) + msg() )
			self.breakIf(cat: cat)
		}
		// TODO: optional handling of triggering test result for fatal, error, fault (break | assert | precondition)
	}

	@inlinable public static
	func logIfNot(_ test: @autoclosure () -> Bool, _ msg: @autoclosure () -> String, cat: Category) {
		if self.will_log(cat: cat) && !test() {
			self.log( self.label(cat) + msg() )
			self.breakIf(cat: cat)
		}
		// TODO: optional handling of triggering test result for fatal, error, fault (break | assert | precondition)
	}

	@inlinable public static
	func log(_ msg: @autoclosure () -> String, cat: Category) {
		if self.will_log(cat: cat) {
			self.log( self.label(cat) + msg() )
			self.breakIf(cat: cat)
		}
	}

	@inlinable public static
	func log(_ msg: @autoclosure () -> String) {
	#if T0_NO_LOGGING
	#else
		guard !self.loggers.isEmpty else { return }
		let s = msg()
		self.loggers.forEach { $0(s) }
	#endif
	}

	@inlinable public static
	func label(_ cat: Category) -> String {
		return cat.rawValue < self.labels.count ? self.labels[cat.rawValue] : ""
	}

	@inlinable public static
	func will_log(cat: Category) -> Bool {
	#if T0_NO_LOGGING
		return false
	#else
		return will_log.contains(Categories(cat: cat))
	#endif
	}

	@inlinable public static
	func breakIf(cat: Category) {
		if will_break.contains(Categories(cat: cat)) {
			// TODO: inline break
			// With assembly inlined in (Obj-)c, its possible to generate a SIGINT and drop straight
			// into the debugger without disturbing registers and stack frame, so allowing immediate 
			// inspection of problems when running in simulator...
			//   on X86(_64): __asm__("int $3\n" : : );
			//   on arm: int sig=2/*SIGINT*/; int call=37/*=sig_kill*/; __asm__("mov r0, %0\nmov r1, %1\nmov r12, %2\nswi 128\nnop\n" : : "r" (getpid()), "r" (sig), "r" (call) : "r12", "r0", "r1", "cc");}
			// but in swift, there is no inline assembly. I suppose, reluctantly, that a call through 
			// to an objc helper will have be enough. todo.
			break_closure(cat)
		}
	}


	public enum Category : Int {
		case fatal		= 0
		case error		= 1
		case fault		= 2 // = faulty behaviour of code under our control
		case warning	= 3
		case event		= 4
		case info		= 5
		case call		= 6
	}

	public static var will_log: Categories = .all
	public static var will_break: Categories = [.fatal,.fault,.error]
	public static var break_closure = { (_ : Category)->Void in } // customise at launch; no guards
	public static var labels = [
		"    fatal: ",
		"*   error: ",
		"•   fault: ",
		"! warning: ",
		">   event: ",
		":    info: ",
		"     call: ",
	]
	public typealias LoggerID = String
	public typealias Logger = (String)->Void
	public static let kLogger_NSLog = "NSLog"
	public static let kLogger_print = "print"
	private(set) static var loggersById: [LoggerID:Logger] = [
	//	kLogger_NSLog:{ NSLog($0) },
	//	...clipped by small buffer (~1000 chars) on iOS 11.x...
	//	seems this is a limitation of the new unified logging
	//	more here: https://stackoverflow.com/a/40283623/618653
		kLogger_print:{ print($0) }
	]
	public private(set) static var loggers: [Logger] = [Logger](loggersById.values)
	public static func get(loggerID: LoggerID) -> Logger? {
		return loggersById[loggerID]
	}
	public static func set(loggerID: LoggerID, logger: @escaping Logger) {
		loggersById[loggerID] = logger
		loggers = [Logger](loggersById.values)
	}
	public static func clear(loggerID: LoggerID) {
		loggersById.removeValue(forKey: loggerID)
		loggers = [Logger](loggersById.values)
	}

	public struct Categories : OptionSet {
		public let rawValue: Int
		public init(rawValue: Int)	{ self.rawValue = rawValue }
		public init(cat: Category)	{ self.init(rawValue: 1 << cat.rawValue) }

		public static let fatal		= Categories(cat: .fatal)
		public static let error		= Categories(cat: .error)
		public static let fault		= Categories(cat: .fault)
		// ...fault means should never occur and is under our control, which means a logic fubar
		// somewhere.
		public static let warning	= Categories(cat: .warning)
		public static let event		= Categories(cat: .event)
		public static let info		= Categories(cat: .info)
		public static let call		= Categories(cat: .call)

		public static let all		= Categories(rawValue: (1 << 7) - 1)
	}
}


