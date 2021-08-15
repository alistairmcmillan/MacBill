//
//  MBImageView.swift
//  MacBill
//
//  Created by Ishioka Hiroshi on Sun Dec 16 2001.
//  Swift port by Alistair McMillan on 14/08/2021.
//

import Foundation

@objc(MBImageView)
class MBImageView: NSImageView {
	
	@IBOutlet var aqua: MBAqua!
	var subimage = NSImage()
	var cursor = NSPoint()
	var drawCursor = Bool()
	var transparency: Float  = 0.7
	
	@objc
	override func mouseDown (with theEvent: NSEvent) {
		var p: NSPoint
		p = theEvent.locationInWindow
		p = self.convert(p, from: nil)
		aqua.aqua_button_press(Int32(p.x), Int32(NSHeight(self.bounds) - p.y))
		cursor = p;
		self.setNeedsDisplay()
	}

	@objc
	override func mouseUp (with theEvent: NSEvent) {
		var p: NSPoint
		p = theEvent.locationInWindow
		p = self.convert(p, from: nil)
		aqua.aqua_button_release(Int32(p.x), Int32(NSHeight(self.bounds) - p.y))
	}
	
	@objc
	func mouseDragged (theEvent: NSEvent) {
		var p: NSPoint
		p = theEvent.locationInWindow
		cursor = self.convert(p, from:nil)
		self.setNeedsDisplay()
	}

	@objc
	override func draw (_ rect: NSRect) {
		super.draw(rect)

		subimage.draw(at: NSZeroPoint, from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
		if (drawCursor) {
			let img: NSImage = NSCursor.current.image
			let size: NSSize = img.size
			img.draw(at: NSMakePoint(cursor.x - (size.width / 2), cursor.y - (size.height / 2)), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: CGFloat(transparency))
		}
	}
	
	@objc
	func setSubimage (image: NSImage) {
		subimage = image
	}

	@objc
	func drawCursor (flag: Bool) {
		drawCursor = flag
	}
	
	@objc
	func setTransparency (trans: Int32) {
		if ((trans >= 0) && (trans <= 100)) {
			transparency = (100.0 - Float(trans)) / 100.0;
		}
	}

}
