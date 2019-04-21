//
//  LevelDB.swift
//  LevelDBIntro
//
//  Created by AP Yury Krainik on 4/15/19.
//  Copyright © 2019 AP Yury Krainik. All rights reserved.
//

import Foundation

open class LevelDB {

	// MARK: - Properties

	public private(set) var db: UnsafeMutableRawPointer?


	// MARK: - Lifecycle

	public init(filePath: String) {
		var cChar: [CChar] = [CChar].init(repeating: 0, count: 2048)
		_ = filePath.getCString(&cChar, maxLength: 2048, encoding: .utf8)
		self.db = c_creatLeveldb(&cChar)
	}

	public convenience init(name: String) {
		let filePath = NSHomeDirectory() + "/Documents/" + name
		let fMgr: FileManager = FileManager()
		let lockFilePath = filePath + "/LOCK"
		if (!fMgr.fileExists(atPath: lockFilePath)) {
			try? fMgr.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
		}

		self.init(filePath: filePath)
	}

	public subscript(key: String) -> String? {
		get {
			guard let db = self.db else {
				return nil
			}
			guard var keyChar: [CChar] = key.cString(using: .utf8) else {
				return nil
			}
			var keyCstring = _CString_(basePtr: &keyChar, lenght: keyChar.count)
			var valueString = c_leveldbGetValue(db, &keyCstring)
			let string = String.init(cString: valueString.basePtr)
			c_FreeCString(&valueString)
			return string
		}
		set {
			guard let db = self.db else {
				return
			}

			guard var keyChar: [CChar] = key.cString(using: .utf8) else {
				return
			}

			let keyCstring = _CString_(basePtr: &keyChar, lenght: keyChar.count)

			guard var valueChar: [CChar] = newValue?.cString(using: .utf8) else {
				c_leveldbDeleteValue(db, keyCstring)
				return
			}

			let valueCstring = _CString_(basePtr: &valueChar, lenght: valueChar.count)
			c_leveldbSetValue(db, keyCstring, valueCstring)
		}
	}

	public func delete(_ key: String) {
		guard let db = self.db else {
			return
		}

		guard var keyChar: [CChar] = key.cString(using: .utf8) else {
			return
		}
		let keyCstring = _CString_(basePtr: &keyChar, lenght: keyChar.count)

		c_leveldbDeleteValue(db, keyCstring)
	}

	public func close() {
		if let db = db {
			c_closeLeveldb(db)
		}
	}

	public func creteIterator() -> Iterator? {
		guard let db = self.db else {
			return nil
		}

		return Iterator(db)
	}
}

extension LevelDB {

	//MARK: - Int
	public func set(_ value: Int?, forKey key: String) {
		if let value = value {
			self[key] = "\(value)"
		} else {
			self[key] = nil
		}
	}

	public func getInt(forKey key: String) -> Int? {
		if let value = self[key] {
			return Int(value)
		}
		return nil
	}

	//MARK: - Float
	public func set(_ value: Float?, forKey key: String) {
		if let value = value {
			self[key] = "\(value)"
		} else {
			self[key] = nil
		}
	}

	public func getFloat(forKey key: String) -> Float? {
		if let value = self[key] {
			return Float(value)
		}
		return nil
	}

	//MARK: - Date
	public func set(_ value: Date?, forKey key: String) {
		if let value = value {
			self[key] = "\(value.timeIntervalSince1970)"
		} else {
			self[key] = nil
		}
	}

	public func getDate(forKey key: String) -> Date? {
		if let value = self[key], let time = TimeInterval(value) {
			return Date.init(timeIntervalSince1970: time)
		}
		return nil
	}
}
