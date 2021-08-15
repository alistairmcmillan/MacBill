#import "MBGame.h"

#import "MButil.h"

#import "MBAqua.h"
#import "MBBill.h"
#import "MBComputer.h"
#import "MBCable.h"
#import "MBHorde.h"
#import "MBNetwork.h"
#import "MBScorelist.h"
#import "MacBill-Swift.h"

#define SCREENSIZE 400

/* Game states */
#define STATE_PLAYING 1
#define STATE_BETWEEN 2
#define STATE_END 3
#define STATE_WAITING 4

/* Score related constants */
#define SCORE_ENDLEVEL -1
#define SCORE_BILLPOINTS 5

static unsigned int state;
static int efficiency;
static int score, level, iteration;
static NSImage *logo, *icon, *about;
static NSCursor *defaultcursor, *downcursor;
static MBBill *grabbed;
static int screensize = SCREENSIZE;

@implementation MBGame

// private
- (void)setup_level:(int)newlevel
{
	level = newlevel;
	[horde Horde_setup];
	grabbed = NULL;
	[ui UI_set_cursorWithCursor:defaultcursor];
	[network Network_setup];
	iteration = 0;
	efficiency = 0;
}

// private
- (void)update_info
{
	char str[80];
	int on_screen = [horde Horde_get_counter:HORDE_COUNTER_ON];
	int off_screen = [horde Horde_get_counter:HORDE_COUNTER_OFF];
	int base = [network Network_get_counter:NETWORK_COUNTER_BASE];
	int off = [network Network_get_counter:NETWORK_COUNTER_OFF];
	int win = [network Network_get_counter:NETWORK_COUNTER_WIN];
	int units = [network Network_num_computers];
	sprintf(str, "Bill:%d/%d  System:%d/%d/%d  Level:%d  Score:%d",
		on_screen, off_screen, base, off, win, level, score);
	[ui UI_draw_strWithStr:[NSString stringWithCString:str encoding:NSUTF8StringEncoding] x:5 y:screensize-5];
	efficiency += ((100 * base - 10 * win) / units);
}

// private
- (void)draw_logo
{
    char str[15];
	[ui UI_clear];
	[ui UI_drawWithPict:logo
		x:(screensize - [ui UI_picture_widthWithPict:logo]) / 2
		y:(screensize - [ui UI_picture_heightWithPict:logo]) / 2];
    sprintf(str, "Click to start");
	[ui UI_draw_strWithStr:[NSString stringWithCString:str encoding:NSUTF8StringEncoding] x:167 y:screensize/7*5];
}

- (void)Game_start:(int)newlevel
{
	state = STATE_PLAYING;
	score = 0;
	[ui UI_restart_timer];
	[ui UI_set_pausebuttonWithAction:1];
	[self setup_level:newlevel];
}

- (void)Game_quit
{
	[scorelist Scorelist_write];
}

- (void)Game_warp_to_level:(int)lev
{
	if (state == STATE_PLAYING) {
		if (lev <= level)
			return;
		[self setup_level:lev];
	}
	else {
		if (lev <= 0)
			return;
		[self Game_start:lev];
	}
}

- (void)Game_add_high_score:(const char *)str
{
	[scorelist Scorelist_recalc:str :level :score];
}

- (void)Game_button_press:(int)x :(int)y
{
	int counter;

	if (state != STATE_PLAYING)
		return;
	[ui UI_set_cursorWithCursor:downcursor];

	if ([bucket Bucket_clickedWithX:x y:y]) {
		[bucket Bucket_grabWithX:x y:y];
		return;
	}

	grabbed = [horde Horde_clicked_stray:x :y];
	if (grabbed != NULL) {
		[os OS_set_cursorWithIndex:grabbed->cargo];
		return;
	}

	counter = [horde Horde_process_click:x :y];
	score += (counter * counter * SCORE_BILLPOINTS);
}

- (void)Game_button_release:(int)x :(int)y
{
	int i;
	[ui UI_set_cursorWithCursor:defaultcursor];

    if (state == STATE_WAITING) {
        [self Game_start:1];
        return;
    }

	if (state != STATE_PLAYING)
		return;

	if (grabbed == NULL) {
		[bucket Bucket_releaseWithX:x y:y];
		return;
	}

	for (i = 0; i < [network Network_num_computers]; i++) {
		MBComputer *computer = [network Network_get_computer:i];

		if ([computer Computer_on:x :y] &&
		    [computer Computer_compatible:grabbed->cargo] &&
		    (computer->os == MBOS.OS_WINGDOWS || computer->os == MBOS.OS_OFF)) {
			int counter;

			[network Network_inc_counter:NETWORK_COUNTER_BASE :1];
			if (computer->os == MBOS.OS_WINGDOWS)
				counter = NETWORK_COUNTER_WIN;
			else
				counter = NETWORK_COUNTER_OFF;
			[network Network_inc_counter:counter :-1];
			computer->os = grabbed->cargo;
			[horde Horde_remove_bill:grabbed];
			grabbed = NULL;
			return;
		}
	}
	[horde Horde_add_bill:grabbed];
	grabbed = NULL;
}

- (void)Game_update
{
	char str[40];

	switch (state) {
	case STATE_PLAYING:
		[ui UI_clear]; 
		[bucket Bucket_draw];
		[network Network_update];
		[network Network_draw];
		[horde Horde_update:iteration];
		[horde Horde_draw];
		[self update_info];
		if ([horde Horde_get_counter:HORDE_COUNTER_ON] +
		    [horde Horde_get_counter:HORDE_COUNTER_OFF] == 0) {
			score += (level * efficiency / iteration);
			state = STATE_BETWEEN;
		}
		if (([network Network_get_counter:NETWORK_COUNTER_BASE] +
		     [network Network_get_counter:NETWORK_COUNTER_OFF]) <= 1)
			state = STATE_END;
		break;
	case STATE_END:
		[ui UI_set_cursorWithCursor:defaultcursor];
		[ui UI_clear];
		[network Network_toasters];
		[network Network_draw];
		[ui UI_refresh];
		[ui UI_popup_dialogWithDialog:DIALOG_ENDGAME];
		if ([scorelist Scorelist_ishighscore:score]) {
			[ui UI_popup_dialogWithDialog:DIALOG_ENTERNAME];
		}
		[ui UI_popup_dialogWithDialog:DIALOG_HIGHSCORE];
		[self draw_logo];
		[ui UI_kill_timer];
		[ui UI_set_pausebuttonWithAction:0];
		state = STATE_WAITING;
		break;
	case STATE_BETWEEN:
		[ui UI_set_cursorWithCursor:defaultcursor];
		sprintf(str, "After Level %d:\nScore: %d", level, score);
		[ui UI_popup_dialogWithDialog:DIALOG_SCORE];
		state = STATE_PLAYING;
		[self setup_level:++level];
		break;
	}
	[ui UI_refresh];
	iteration++;
}

- (int)Game_state
{
    return state;
}

- (int)Game_score
{
	return score;
}

- (int)Game_level
{
	return level;
}

- (int)Game_screensize
{
	return screensize;
}

- (double)Game_scale:(int)dimensions
{
	double scale = (double)screensize / SCREENSIZE;
	double d = 1;
	for ( ; dimensions > 0; dimensions--)
		d *= scale;
	return (d);
}

- Game_main
{
	[MBBill Bill_class_init:self :horde :network :os :ui];
	[MBCable Cable_class_init:self :network :spark :ui];
	[MBComputer Computer_class_init:self :network :os :ui];

	srandom((unsigned)time(NULL));
	[ui UI_make_main_windowWithSize:screensize];
	[ui UI_load_pictureWithName:@"logo" trans:0 picture:&logo];
	[ui UI_load_pictureWithName:@"icon" trans:0 picture:&icon];
	[ui UI_load_pictureWithName:@"about" trans:0 picture:&about];
	[self draw_logo];
	[ui UI_refresh];

	[scorelist Scorelist_read];

	[ui UI_load_cursorWithName:@"hand_up" masked:MBUI.CURSOR_SEP_MASK cursorp:&defaultcursor];
	[ui UI_load_cursorWithName:@"hand_down" masked:MBUI.CURSOR_SEP_MASK cursorp:&downcursor];
	[ui UI_set_cursorWithCursor:defaultcursor];

	[MBBill Bill_load_pix];
	[MBComputer Computer_load_pix];

	state = STATE_WAITING;
	[ui UI_set_pausebuttonWithAction:0];

	return self;
}


- (void)Game_set_size:(int)size
{
	if (size >= SCREENSIZE) {
		screensize = size;
	}
}

@end
