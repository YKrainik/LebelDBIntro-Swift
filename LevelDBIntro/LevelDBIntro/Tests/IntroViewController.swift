//
//  IntroViewController.swift
//  LevelDBIntro
//
//  Created by AP Yury Krainik on 4/20/19.
//  Copyright © 2019 AP Yury Krainik. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

	// MARK: - Properties
	@IBOutlet weak var keyTextField: UITextField!
	@IBOutlet weak var valueTextField: UITextField!
	@IBOutlet weak var resultView: UITextView!

	private let db: LevelDB
	private var isShortDebugOutput: Bool = true

	// MARK: - Lifecycle

	required init?(coder aDecoder: NSCoder) {
		db = LevelDB(name: "Intro")
		super.init(coder: aDecoder)
	}

	deinit {
		db.close()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}

	// MARK: - Actions
	
	@IBAction func addStringTapped(_ sender: Any) {
		guard let key = keyTextField.text, let value = valueTextField.text else {
			return
		}

		db[key] = value

		keyTextField.text = nil
		valueTextField.text = nil

		update()
	}

	@IBAction func deleteStringTapped(_ sender: Any) {
		guard let key = keyTextField.text else {
			return
		}

		keyTextField.text = nil
		valueTextField.text = nil

		db.delete(key)

		update()
	}

	@IBAction func addIntTapped(_ sender: Any) {
		let value = Int.random(in: 0 ... 1000)
		let key = String(value)

		db.set(value, forKey: key)

		update()
	}

	@IBAction func addDateTapped(_ sender: Any) {
		let date = Date()

		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

		db.set(date, forKey: "current Date")
		db.set(date, forKey: formatter.string(from: date))

		update()
	}

	@IBAction func outputTypeChanged(_ sender: Any) {
		isShortDebugOutput = !isShortDebugOutput
		update()
	}

	// MARK: - Private

	private func update() {
		if isShortDebugOutput {
			showValues()
		} else {
			showKeyValues()
		}
	}

	private func showValues() {
		guard let iterator = db.creteIterator() else {
			return
		}

		resultView.text = nil

		iterator.seekToFirst()

		while iterator.isValid() {
			if let value = iterator.stringValue() {
				let record = "Value: \(value)\n"
				resultView.text = resultView.text.appending(record)
			}

			iterator.next()
		}

		iterator.freeIterator()
	}

	private func showKeyValues() {
		guard let iterator = db.creteIterator() else {
			return
		}

		resultView.text = nil

		iterator.seekToFirst()

		while iterator.isValid() {
			if let keyValue = iterator.stringKeyValue() {
				let record = "Key: \(keyValue.0) - Value: \(keyValue.1)\n"
				resultView.text = resultView.text.appending(record)
			}

			iterator.next()
		}

		iterator.freeIterator()
	}
}

extension IntroViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
}
