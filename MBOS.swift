//
//  MBOS.swift
//  MacBill
//
//  Created by Ishioka Hiroshi on Sun Dec 16 2001.
//  Swift port by Alistair McMillan on 01/08/2021.
//

import Foundation

@objc(MBOS)
class MBOS: NSObject {
	
	@IBOutlet var ui: MBUI!
	
	@objc static let OS_WINGDOWS: Int32 = 0
	@objc static let OS_OFF: Int32 = -1

	static let OS_PC: Int32 = 6
	static let MIN_PC: Int32 = 6		/* OS >= MIN_PC means the OS is a PC OS */
	static let osname = ["wingdows", "apple", "next", "sgi", "sun", "palm", "os2", "bsd", "linux", "redhat", "hurd", "beos"]
	static let NUM_OS: Int = osname.count

	static let os: [NSImage] = {
		var images = [NSImage]()
		for i in 0 ..< osname.count {
			images.append(NSImage.init(named: osname[i])!)
		}
		return images
	}()
	
	@objc static let cursor: [NSCursor] = {
		var cursors = [NSCursor]()
		for i in 0 ..< osname.count {
			var os = NSImage.init(named: osname[i])
			var cursor = NSCursor.init(image: os!,
									   hotSpot: NSMakePoint(os!.size.width/2, os!.size.height/2))
			cursors.append(cursor)
		}
		return cursors
	}()

	@objc func OS_draw(index: Int32, x:Int32, y:Int32) {
		ui.ui_draw(MBOS.os[Int(index)], x, y)
	}
	
	@objc func OS_width() -> Int32 {
		return ui.ui_picture_width(MBOS.os[0])
	}

	@objc func OS_height() -> Int32 {
		return ui.ui_picture_height(MBOS.os[0])
	}

	@objc func OS_set_cursor(index:Int32) {
		ui.ui_set_cursor(MBOS.cursor[Int(index)])
	}
	
	@objc func OS_randpc() -> Int32 {
		return Int32(Int.random(in: Int(MBOS.MIN_PC)...MBOS.NUM_OS-1))
	}

	@objc func OS_ispc(index:Int32) -> Bool {
		return (index >= MBOS.MIN_PC)
	}

}
