//
//  MBBucket.swift
//  MacBill
//
//  Created by Ishioka Hiroshi on Sun Dec 16 2001.
//  Swift port by Alistair McMillan on 01/08/2021.
//

import Foundation

@objc(MBBucket)
class MBBucket: NSObject {
	
	@IBOutlet var network: MBNetwork!

	@IBOutlet var ui: MBUI!

	static let picture: NSImage = NSImage.init(named: "bucket")!

	static let cursor: NSCursor = NSCursor()

	static var grabbed:Int32 = 0
	
	@objc
	func Bucket_draw () {
		if (MBBucket.grabbed == 0) {
			ui.UI_draw(pict: MBBucket.picture, x: 0, y: 0)
		}
	}
	
	@objc
	func Bucket_clicked (x:Int32, y:Int32) -> Bool {
		return (x > 0 && x < ui.UI_picture_width(pict: MBBucket.picture) &&
					y > 0 && y < ui.UI_picture_height(pict: MBBucket.picture))
	}

	@objc
	func Bucket_grab (x:Int32, y:Int32) {
//		UNUSED(x);
//		UNUSED(y);

		ui.UI_set_cursor(cursor: MBBucket.cursor)
		MBBucket.grabbed = 1;
	}

	@objc
	func Bucket_release (x:Int32, y:Int32) {
		for i in 0 ..< network.network_num_cables() {
			let cable: MBCable = network.network_get_cable(i) as! MBCable
			if ((cable.cable_onspark(x, y)) != 0) {
				cable.cable_reset()
			}
		}
		MBBucket.grabbed = 0;
	}

}
