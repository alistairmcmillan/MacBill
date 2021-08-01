//
//  MBSpark.swift
//  MacBill
//
//  Created by Alistair McMillan on 01/08/2021.
//

import Foundation

@objc(MBSpark)
class MBSpark: NSObject {

	@objc
	@IBOutlet var ui: MBUI!
	
	@objc
	let SPARK_SPEED: Int32 = 4

	@objc
	static let pictures: [NSImage] = {
		var images = [NSImage]()
		for i in 0 ... 1 {
			images.append(NSImage.init(named: "spark_\(i)")!)
		}
		return images
	}()

	@objc
	func SPARK_DELAY (level: Int32) -> Int32 {
		return max(20 - (level), 0)
	}

	@objc
	func Spark_width () -> Int32 {
		return Int32(MBSpark.pictures.first!.size.width)
	}

	@objc
	func Spark_height () -> Int32 {
		return Int32(MBSpark.pictures.first!.size.height)
	}
	
	@objc
	func Spark_draw (x:Int32, y:Int32, index:Int32) -> Void {
		ui.ui_draw(MBSpark.pictures[Int(index)], x, y)
	}
	
}
