//
//  TestViewController.swift
//  LevelDBIntro
//
//  Created by AP Yury Krainik on 4/20/19.
//  Copyright © 2019 AP Yury Krainik. All rights reserved.
//

import UIKit
import CoreLocation

class TestViewController: UIViewController {

	// MARK: - Properties

	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var resultView: UITextView!

	private let db: LevelDB
	private let locationManager = CLLocationManager()
	private let formatter = DateFormatter()
	private var isRunning: Bool = false

	// MARK: - Lifecycle

	// MARK: - Lifecycle

	required init?(coder aDecoder: NSCoder) {
		db = LevelDB(name: "Test")
		super.init(coder: aDecoder)

		locationManager.delegate = self
		formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
	}

	deinit {
		locationManager.stopUpdatingLocation()
		db.close()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
		locationManager.requestWhenInUseAuthorization()
	}

	// MARK: - Private

	private func update() {
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

	// MARK: - Actions

	@IBAction func startTapped(_ sender: Any) {

		isRunning = !isRunning

		if isRunning {
			startButton.setTitle("Stop", for: .normal)
			locationManager.startUpdatingLocation()
		} else {
			startButton.setTitle("Start", for: .normal)
			locationManager.stopUpdatingLocation()
		}
	}
}

extension TestViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
			return
		}

		let date = Date()

		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self = self else {
				return
			}

			let key = self.formatter.string(from: date)
			self.db[key] = "\(location.coordinate.latitude):\(location.coordinate.longitude)"
			DispatchQueue.main.async {
				self.update()
			}
		}
	}
}
