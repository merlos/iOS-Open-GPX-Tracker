//
//  ViewControllerTests.swift
//  OpenGpxTrackerTests
//
//  Created by Tieda Wei on 2025-09-19.
//

import XCTest
@testable import OpenGpxTracker

final class ViewControllerTests: XCTestCase {
	func test_containsScaleBarView() throws {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "RootViewController") as? ViewController
		let sut = try XCTUnwrap(vc)
		XCTAssertTrue(sut.view.subviews.contains(where: { v in
			v === sut.scaleBar
		}))
		XCTAssertEqual(sut.scaleBar.mapView, sut.map)
	}
}
