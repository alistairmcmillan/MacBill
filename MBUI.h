/* MBUI */

#import <Cocoa/Cocoa.h>

#define CURSOR_SEP_MASK 0
#define CURSOR_OWN_MASK 1

#define DIALOG_NEWGAME 0
#define DIALOG_PAUSEGAME 1
#define DIALOG_WARPLEVEL 2
#define DIALOG_HIGHSCORE 3
#define DIALOG_QUITGAME 4
#define DIALOG_STORY 5
#define DIALOG_RULES 6
#define DIALOG_ABOUT 7
#define DIALOG_SCORE 8
#define DIALOG_ENDGAME 9
#define DIALOG_ENTERNAME 10
#define DIALOG_MAX 10

@interface MBUI : NSObject
{
    IBOutlet id aqua;
}

- (void)UI_restart_timer;
- (void)UI_kill_timer;

- (void)UI_pause_game;
- (void)UI_resume_game;

- (void)UI_make_main_window:(int)size;

- (void)UI_popup_dialog:(int)index;
- (void)UI_set_cursor:(MBMCursor *)cursor;
- (void)UI_clear;
- (void)UI_refresh;
- (void)UI_draw:(MBPicture *)picture :(int)x :(int)y;
- (void)UI_draw_line:(int)x1 :(int)y1 :(int)x2 :(int)y2;
- (void)UI_draw_str:(const char *)str :(int)x :(int)y;

- (void)UI_set_pausebutton:(int)action;

- (void)UI_load_picture:(const char *)name :(int)trans :(MBPicture **)pictp;
- (void)UI_load_picture_indexed:(const char *)name :(int)index :(int)trans
			     :(MBPicture **)pictp;
- (int)UI_picture_width:(MBPicture *)pict;
- (int)UI_picture_height:(MBPicture *)pict;

- (void)UI_load_cursor:(const char *)name :(int)masked :(MBMCursor **)cursorp;

- (int)UI_intersect:(int)x1 :(int)y1 :(int)w1 :(int)h1 :(int)x2 :(int)y2 :(int)w2 :(int)h2;

- (const char *)UI_dialog_string:(int)index;
- (const char *)UI_menu_string:(int)index;

- (void)UI_set_interval:(int)ti;

@end
