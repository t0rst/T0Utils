/*
	Feeder.swift
	T0Utils

	Created by Torsten Louland on 26/11/2017.

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
import CwlUtils



/// A utility for asynchronously getting items and acting on them until all items are processed and
/// attempting to get more yields none.
///
/// The user of a Feeder instance must supply the closures that will get items and act on them;
/// these are assigned to the `doGet` and `doAct` properties, and called from the `get()` and `act()`
/// functions respectively. They can be changed at any time, for example, if processing is to be
/// aborted, the `doAct` property can be assigned a closure that will process the remaining items
/// by informing that they have been aborted, instead of doing the original processing. Furthermore,
/// the scheduling of the `get()` and `act()` can be customised by providing non-default closures
/// for the properties `cueGet` and `cueAct`, for example to schedule `get()` and `act()` to perform
/// on different queues.
///
/// The `concurrent` property holds a closure to yield the maximum number of items to process
/// concurrently; this could, for example, read a property elsewhere which changes whether the
/// action has been brought into the foreground by the user or must go into the background.
///
/// Finally, when all itmes have been acted on and no more are available, the closure in the
/// `didComplete` property is called.
public class Feeder<Item>
{
	var cueGet:				CueGet
	var doGet:				DoGet
	var cueAct:				CueAct
	var doAct:				DoAct
	public var didComplete:	DidComplete

	public init(cueGet: CueGet? = nil, doGet: @escaping DoGet,
		 cueAct: CueAct? = nil, doAct: @escaping DoAct,
		 concurrent: @escaping ()->Int = { 2 }, didComplete: @escaping DidComplete = {})
	{
		self.cueGet = cueGet ?? { $0.get() } ; self.doGet = doGet
		self.cueAct = cueAct ?? { $0.act() } ; self.doAct = doAct
		self.concurrent = concurrent
		self.didComplete = didComplete
	}

	public func start() {
		self.cueGet(self)
	}

	/// Call nudge aftering increasing concurrent limit from zero to restart feed
	public func nudge() {
		self.cueAct(self)
	}

	public var isDone : Bool {
		return _state.value.done
	}

	/// Closure used for passing items to be processed back to the feeder
	public typealias DidGet =		([Item])->Void

	/// Closure that gets any number of items to be processed and returns them through the supplied
	/// `DidGet` closure.
	public typealias DoGet =		(@escaping DidGet)->Void

	/// Closure that is expected to schedule the next call to `get()` of the argument - per usage
	/// needs, i.e. inline/dispatched, sync/async, current/specific queue; the simplest form is
	/// `{ $0.get() }`.
	public typealias CueGet =		(Feeder)->Void

	/// Closure used for passing back an item and the result of acting on it to the feeder
	public typealias DidAct =		(Item, Error?)->Void

	/// Closure expected to act on an item and return the result through the supplied `DidAct`
	/// closure.
	public typealias DoAct =		(Item, @escaping DidAct)->Void

	/// Closure that is expected to schedule the next call to `act()` of the argument - per usage
	/// needs, i.e. inline/dispatched, sync/async, current/specific queue; the simplest form is
	/// `{ $0.act() }`.
	public typealias CueAct =		(Feeder)->Void

	/// Closure called when all items processed
	public typealias DidComplete = ()->Void

	/// A closure yeilding the maximum number of items that can be processed concurrently
	var concurrent:			()->Int = { 1 }

	struct State {
		var buffer =		[Item]()
		var remaining =		ArraySlice<Item>()
		var getting =		false
		var processing =	0
		var completed =		0
		var failed =		0

		var done:			Bool { return !getting && 0 == remaining.count && 0 == processing }
	}
	private let _state = AtomicBox<State>(State())

	private func get() {
		var doNext_onStackRewind: (()->Void)? = nil
		self._state.mutate { [unowned self] state in
			if	state.remaining.isEmpty, !state.getting {
				state.getting = true
				var state_onStack: State? = state
				doGet() { [unowned self] (t: [Item]) in
					var nudge = false
					let advance = { (state: inout State) in
						state.getting = false
						state.buffer = t
						state.remaining = state.buffer[..<state.buffer.endIndex]
						if !t.isEmpty {
							nudge = state.processing < self.concurrent()
						}
					}
					let doNext = {
						if nudge {
							self.cueAct(self)
						} else if self.isDone {
							self.didComplete()
						}
					}
					if var state = state_onStack { // => called synchronously => update directly, instead of calling _state.mutate, which would block
						advance(&state)
						state_onStack = state
						doNext_onStackRewind = doNext
					} else {
						self._state.mutate(advance)
						doNext()
					}
				}
				if let stateUpdate = state_onStack {
					state = stateUpdate
					state_onStack = nil
				}
			}
		}
		doNext_onStackRewind?()
	}

	private func act() {
		var doNext_onStackRewind: (()->Void)? = nil
		self._state.mutate { [unowned self] state in
			while state.processing < self.concurrent(), let t = state.remaining.first
			{
				state.remaining = state.remaining.dropFirst()
				state.processing += 1
				var state_onStack: State? = state
				doAct(t) { [unowned self] (t: Item, e: Error?) in
					var empty = false
					let advance = { (state: inout State) in
						state.processing -= 1
						if nil == e { state.completed += 1 } else { state.failed += 1 }
						empty = state.remaining.isEmpty
					}
					let doNext = {
						(empty ? self.cueGet : self.cueAct)(self)
					}
					if var state = state_onStack { // => called synchronously => update directly, instead of calling _state.mutate, which would block
						advance(&state) ; state_onStack = state
						doNext_onStackRewind = doNext
					} else {
						self._state.mutate(advance)
						doNext()
					}
				}
				if let stateUpdate = state_onStack {
					state = stateUpdate
					state_onStack = nil
				}
			}
		}
		doNext_onStackRewind?()
	}
}
