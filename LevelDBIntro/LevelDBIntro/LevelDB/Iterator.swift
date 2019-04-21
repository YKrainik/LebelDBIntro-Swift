//
//  Iterator.swift
//  LevelDBIntro
//
//  Created by AP Yury Krainik on 4/19/19.
//  Copyright © 2019 AP Yury Krainik. All rights reserved.
//

import Foundation

open class Iterator {
	public private(set) var iterator: UnsafeMutableRawPointer?

	init(_ db: UnsafeMutableRawPointer) {
		iterator = c_createIterator(db)
	}

	public func seekToFirst() {
		guard let iterator = self.iterator else {
			return
		}

		c_iteratorSeekToFirst(iterator)
	}

	public func isValid() -> Bool {
		guard let iterator = self.iterator else {
			return false
		}

		return c_iteratorIsValid(iterator)
	}

	public func next() {
		guard let iterator = self.iterator else {
			return
		}

		c_iteratorNext(iterator)
	}

	public func stringValue() -> String? {
		guard let iterator = self.iterator else {
			return nil
		}

		var valueString = c_iteratorGetValue(iterator)
		let string = String.init(cString: valueString.basePtr)
		c_FreeCString(&valueString);

		return string;
	}

	public func stringKeyValue() -> (String, String)? {
		guard let iterator = self.iterator else {
			return nil
		}

		var keyValueString = c_iteratorGetKeyValue(iterator)
		let key = String.init(cString: keyValueString.key.basePtr)
		let value = String.init(cString: keyValueString.value.basePtr)

		c_FreeCString(&keyValueString.key)
		c_FreeCString(&keyValueString.value)

		return (key, value)
	}

	public func freeIterator() {
		guard let iterator = self.iterator else {
			return
		}

		c_iteratorFree(iterator)
	}
}
