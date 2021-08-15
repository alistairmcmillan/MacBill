//
//  MBUI.swift
//  MacBill
//
//  Created by Ishioka Hiroshi on Sun Dec 16 2001.
//  Swift port by Alistair McMillan on 15/08/2021.
//

import Foundation

@objc(MBUI)
class MBUI: NSObject {

	@IBOutlet var aqua: MBAqua!
	static var interval: Int32 = 200
	static var playing: Bool = false
	static var  DIALOG_MAX: Int32 = 10

	@objc static var CURSOR_SEP_MASK: Int32 = 0
	@objc static var CURSOR_OWN_MASK: Int32 = 1

	@objc
	func UI_restart_timer () {
		aqua.aqua_start_timer(MBUI.interval)
	}

	@objc
	func UI_kill_timer () {
		aqua.aqua_stop_timer()
	}

	@objc
	func UI_pause_game () {
		if (aqua.aqua_timer_active() != 0) {
			MBUI.playing = true
		}
		self.UI_kill_timer()
	}

	@objc
	func UI_resume_game () {
		if (MBUI.playing && (aqua.aqua_timer_active() == 0)) {
			self.UI_restart_timer()
		}
		MBUI.playing = false
	}

	@objc
	func UI_make_main_window (size: Int32) {
		aqua.aqua_make_main_window(size)
	}

	@objc
	func UI_popup_dialog (dialog: Int32) {
		aqua.aqua_popup_dialog(dialog)
	}

	@objc
	func UI_set_cursor (cursor: NSCursor) {
		aqua.aqua_set_cursor(cursor)
	}

	@objc
	func UI_clear () {
		aqua.aqua_clear_window()
	}

	@objc
	func UI_refresh () {
		aqua.aqua_refresh_window()
	}

	@objc
	func UI_draw (pict: NSImage, x: Int32, y: Int32) {
		aqua.aqua_draw_image(pict, x, y)
	}
	
	@objc
	func UI_draw_line (x1: Int32, y1: Int32, x2: Int32, y2: Int32) {
		aqua.aqua_draw_line(x1, y1, x2, y2)
	}

	@objc
	func UI_draw_str (str: NSString, x: Int32, y: Int32) {
		aqua.aqua_draw_string(str as String, x, y)
	}
	
	@objc
	func UI_set_pausebutton (action: Int32) {
		aqua.aqua_set_pausebutton(action)
	}
	
	@objc
	func UI_load_picture (name: NSString, trans: Int32, picture: AutoreleasingUnsafeMutablePointer<NSImage?>?) {
		aqua.aqua_load_picture(name as String, trans, picture)
	}

	@objc
	func UI_load_picture_indexed (name: NSString, index: Int32, trans: Int32, picture: AutoreleasingUnsafeMutablePointer<NSImage?>?) {
		let newname: NSString = name as String + "_" + String(index) as NSString
		self.UI_load_picture(name: newname, trans: trans, picture: picture)
	}

	@objc
	func UI_picture_width (pict: NSImage) -> Int32 {
		return aqua.aqua_picture_width(pict)
	}

	@objc
	func UI_picture_height (pict: NSImage) -> Int32 {
		return aqua.aqua_picture_height(pict)
	}
	
	@objc
	func UI_load_cursor (name: NSString, masked: Int32, cursorp: AutoreleasingUnsafeMutablePointer<NSCursor?>?) {
		aqua.aqua_load_cursor(name as String, masked, cursorp)
	}
	
	@objc
	func UI_intersect (x1: Int32, y1: Int32, w1: Int32, h1: Int32, x2: Int32, y2: Int32, w2: Int32, h2: Int32) -> Bool {
		return ( (abs(x2 - x1 + (w2 - w1) / 2) < (w1 + w2) / 2) &&
					(abs(y2 - y1 + (h2 - h1) / 2) < (h1 + h2) / 2 ) )
	}

	@objc
	func UI_audio_play (name: NSString) {
		aqua.aqua_audio_play(name as String)
	}

	@objc
	func UI_set_interval (ti: Int32) {
		MBUI.interval = ti
	}

}
