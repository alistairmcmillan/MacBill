#import "MBtypes.h"
#import "MBUI.h"

#import "MButil.h"

#import "MBGame.h"

#import "MBAqua.h"

static int playing;
static const char *dialog_strings[DIALOG_MAX + 1];
static const char *menu_strings[DIALOG_MAX + 1];
static int interval = 200;

@implementation MBUI

- (void)UI_restart_timer
{
	[aqua aqua_start_timer:interval];
}

- (void)UI_kill_timer
{
	[aqua aqua_stop_timer];
}

- (void)UI_pause_game
{
	if ([aqua aqua_timer_active])
		playing = 1;
	[self UI_kill_timer];
}

- (void)UI_resume_game
{
	if (playing && ![aqua aqua_timer_active])
		[self UI_restart_timer];
	playing = 0;
}

- (void)UI_make_main_window:(int)size
{
	[aqua aqua_make_main_window:size];
}

- (void)UI_popup_dialog:(int)dialog
{
	[aqua aqua_popup_dialog:dialog];
}

- (void)UI_set_cursor:(MBMCursor *)cursor
{
	[aqua aqua_set_cursor:cursor];
}

- (void)UI_clear
{
	[aqua aqua_clear_window];
}

- (void)UI_refresh
{
	[aqua aqua_refresh_window];
}

- (void)UI_draw:(MBPicture *)pict :(int)x :(int)y
{
	[aqua aqua_draw_image:pict :x :y];
}

- (void)UI_draw_line:(int)x1 :(int)y1 :(int)x2 :(int)y2
{
	[aqua aqua_draw_line:x1 :y1 :x2 :y2];
}

- (void)UI_draw_str:(const char *)str :(int)x :(int)y
{
	[aqua aqua_draw_string:str :x :y];
}

- (void)UI_set_pausebutton:(int)action
{
	[aqua aqua_set_pausebutton:action];
}

- (void)UI_load_picture_indexed:(const char *)name :(int)index :(int)trans :(MBPicture **)pictp
{
	char *newname;
	newname = malloc(strlen(name) + 4);
	sprintf(newname, "%s_%d", name, index);
	[self UI_load_picture:newname :trans :pictp];
	free(newname);
}

- (void)UI_load_picture:(const char *)name :(int)trans :(MBPicture **)pictp
{
	[aqua aqua_load_picture:name :trans :pictp];
}

- (int)UI_picture_width:(MBPicture *)pict
{
	return [aqua aqua_picture_width:pict];
}

- (int)UI_picture_height:(MBPicture *)pict
{
	return [aqua aqua_picture_height:pict];
}

- (void)UI_load_cursor:(const char *)name :(int)masked :(MBMCursor **)cursorp
{
	[aqua aqua_load_cursor:name :masked :cursorp];
}

- (int)UI_intersect:(int)x1 :(int)y1 :(int)w1 :(int)h1 :(int)x2 :(int)y2 :(int)w2 :(int)h2
{
	return ((abs(x2 - x1 + (w2 - w1) / 2) < (w1 + w2) / 2) &&
		(abs(y2 - y1 + (h2 - h1) / 2) < (h1 + h2) / 2));
}

- (const char *)UI_dialog_string:(int)index
{
	return dialog_strings[index];
}

- (const char *)UI_menu_string:(int)index
{
	return menu_strings[index];
}


- (void)UI_set_interval:(int)ti
{
	interval = ti;
}

@end
