/* MBAqua */

#import <Cocoa/Cocoa.h>

struct MBMCursor {
	NSCursor *cursor;
};

struct MBPicture {
	NSImage *img;
};

@interface MBAqua : NSObject
{
    IBOutlet id game;
    IBOutlet id ui;

    IBOutlet id about;
    IBOutlet id story;
    IBOutlet id rules;
    IBOutlet id warp;
    IBOutlet id entry;
    IBOutlet id highscore;
    IBOutlet id view;

    IBOutlet id menu_pause;
    IBOutlet id text_size;
    IBOutlet id text_timer;
    IBOutlet id text_trans;
    IBOutlet id slider_size;
    IBOutlet id slider_timer;
    IBOutlet id slider_trans;
}

- (void)aqua_set_cursor:(MBMCursor *)cursor;
- (void)aqua_load_cursor:(const char *)name :(int)masked :(MBMCursor **)cursorp;
- (void)aqua_load_picture:(const char *)name :(int)trans :(MBPicture **)pictp;
- (int)aqua_picture_width:(MBPicture *)pict;
- (int)aqua_picture_height:(MBPicture *)pict;
- (void)aqua_clear_window;
- (void)aqua_refresh_window;
- (void)aqua_draw_image:(MBPicture *)pict :(int)x :(int)y;
- (void)aqua_draw_line:(int)x1 :(int)y1 :(int)x2 :(int)y2;
- (void)aqua_draw_string:(const char *)str :(int)x :(int)y;
- (void)aqua_start_timer:(int)ms;
- (void)aqua_stop_timer;
- (int)aqua_timer_active;

- (void)aqua_popup_dialog:(int)dialog;
- (void)aqua_make_main_window:(int)size;
- (void)aqua_set_pausebutton:(int)action;

- (void)aqua_audio_play:(const char *)str;

- (IBAction)new_game:(id)sender;
- (IBAction)pause_game:(id)sender;
- (IBAction)quit_game:(id)sender;
- (IBAction)warp_level:(id)sender;
- (IBAction)high_score:(id)sender;
- (IBAction)story:(id)sender;
- (IBAction)rules:(id)sender;
- (IBAction)about:(id)sender;
- (IBAction)pref:(id)sender;

- (IBAction)modalOk:(id)sender;
- (IBAction)modalCancel:(id)sender;

- (void)aqua_button_press:(int)x :(int)y;
- (void)aqua_button_release:(int)x :(int)y;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

@end
