#import "MBtypes.h"
#import "MBAqua.h"

#import "MBGame.h"
#import "MBUI.h"

#import "MBImageView.h"

#define DIALOG_OK		(YES)
#define DIALOG_CANCEL	(NO)

static NSTimer *timer = nil;
static NSImage *frame;
static BOOL menu_pause_enable_flag = NO;
static int screensize;

@implementation MBAqua

// private
- (void)leave_window
{
	[ui UI_pause_game];
}

// private
- (void)enter_window
{
	[ui UI_resume_game];
}

// private
- (void)redraw_window
{
	[ui UI_refresh];
}

// private
- (void)timer_tick
{
	[game Game_update];
}

// private
- (NSAlert *)runAlertPanel:(NSString *)name :(BOOL)needsAltBtn;
{
    NSString *strMsg, *strTitle, *strBtn1, *strBtn2;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSAlertStyleInformational];
    
    strTitle = NSLocalizedString([name stringByAppendingString:@"_dialog_str_title"], nil);
    strMsg   = NSLocalizedString([name stringByAppendingString:@"_dialog_str_msg"], nil);
    strBtn1  = NSLocalizedString([name stringByAppendingString:@"_dialog_str_btn1"], nil);

    if ([name isEqualToString:@"score"]) {
        strMsg = [NSString stringWithFormat:strMsg, [game Game_level], [game Game_score]];
    }
    [alert setMessageText:strTitle];
    [alert setInformativeText:strMsg];
    [alert addButtonWithTitle:strBtn1];

    if (needsAltBtn == YES) {
        strBtn2  = NSLocalizedString([name stringByAppendingString:@"_dialog_str_btn2"], nil);
        [alert addButtonWithTitle:strBtn2];
    }
    return alert;
}

/*
 * Cursor handling
 */

- (void)aqua_set_cursor:(MBMCursor *)cursor
{
	[cursor->cursor set];
	if ([[[cursor->cursor image] name] compare:@"hand"
			options:NSCaseInsensitiveSearch
			range:NSMakeRange(0, 4)] == NSOrderedSame) {
		[NSCursor unhide];
		[view drawCursor:NO];
	} else {
		[NSCursor hide];
		[view drawCursor:YES];
	};
}

- (void)aqua_load_cursor:(const char *)name :(int)masked :(MBMCursor **)cursorp
{
	MBMCursor *cursor = malloc(sizeof(MBMCursor));
	MBPicture *pict;
	[self aqua_load_picture:name :0 :&pict];
	cursor->cursor = [[NSCursor alloc] initWithImage:pict->img
						hotSpot:NSMakePoint([self aqua_picture_width:pict] / 2,
											[self aqua_picture_height:pict] / 2)];
	*cursorp = cursor;
}

/*
 * Pixmap handling
 */

- (void)aqua_load_picture:(const char *)name :(int)trans :(MBPicture **)pictp
{
	MBPicture *pict = malloc(sizeof(MBPicture));
	NSString *s = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	pict->img = [NSImage imageNamed:s];
	*pictp = pict;
}

- (int)aqua_picture_width:(MBPicture *)pict
{
	return [pict->img size].width;
}

- (int)aqua_picture_height:(MBPicture *)pict
{
	return [pict->img size].height;
}

- (void)aqua_clear_window
{
	[frame lockFocus];
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect( 0,  0, screensize, screensize));
	[frame unlockFocus];
}

- (void)aqua_refresh_window
{
	[view setSubimage:frame];
	[view setNeedsDisplay:YES];
}

- (void)aqua_draw_image:(MBPicture *)pict :(int)x :(int)y
{
	y += [self aqua_picture_height:pict];
	[frame lockFocus];
	[pict->img dissolveToPoint:NSMakePoint(x, y) fraction:1.0];
	[frame unlockFocus];
}

- (void)aqua_draw_line:(int)x1 :(int)y1 :(int)x2 :(int)y2
{
	NSBezierPath *bz = [NSBezierPath bezierPath]; 
	[frame lockFocus];
	[[NSColor blackColor] set];
	[bz moveToPoint:NSMakePoint(x1, y1)];
	[bz lineToPoint:NSMakePoint(x2, y2)];
	[bz stroke];
	[frame unlockFocus];
}

- (void)aqua_draw_string:(const char *)str :(int)x :(int)y
{
	NSString *status = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
	NSDictionary *attrs = nil;
	NSSize size = [status sizeWithAttributes:attrs];
	[frame lockFocus];
	[status drawAtPoint:NSMakePoint(x, y - size.height) withAttributes:attrs];
	[frame unlockFocus];
}

/*
 * Timer operations
 */

- (void)aqua_start_timer:(int)ms
{
	timer = [NSTimer scheduledTimerWithTimeInterval:ms/1000.0 target:self
					 selector:@selector(timer_tick) userInfo:nil repeats:YES];
}

- (void)aqua_stop_timer
{
	if (!timer)
		return;
	[timer invalidate];
	timer = nil;
}

- (int)aqua_timer_active
{
	return (!!timer);
}


- (void)aqua_popup_dialog:(int)dialog
{
    NSAlert *alert;
    switch (dialog) {
	case DIALOG_ENTERNAME:
		[NSApp runModalForWindow:[entry window]];
		[game Game_add_high_score:[[entry stringValue] UTF8String]];
		break;
	case DIALOG_PAUSEGAME:
        alert = [self runAlertPanel:@"pause" :NO];
        [alert beginSheetModalForWindow:[view window] completionHandler:nil];
		break;
	case DIALOG_ENDGAME:
		alert = [self runAlertPanel:@"endgame" :NO];
        [alert beginSheetModalForWindow:[view window] completionHandler:nil];
        break;
	case DIALOG_SCORE:
		alert = [self runAlertPanel:@"score" :NO];
        [alert beginSheetModalForWindow:[view window] completionHandler:nil];
        break;
	case DIALOG_HIGHSCORE:
		[self high_score:self];
		break;
	}
}

- (void)aqua_make_main_window:(int)size
{
	screensize = size;
	[[view window] setContentSize:NSMakeSize(size, size)];
	// create frame buffer
	frame = [[NSImage alloc] initWithSize:NSMakeSize(size, size)];
	[frame setFlipped:YES];
}

- (void)aqua_set_pausebutton:(int)action
{
	menu_pause_enable_flag = (action ? YES : NO);
}


- (IBAction)new_game:(id)sender
{
    if([game Game_state] != 4) { // check whether a game is active
        NSAlert *alert;
        alert = [self runAlertPanel:@"newgame" :YES];
        [alert beginSheetModalForWindow:[view window] completionHandler:^(NSInteger result) {
            if (result != NSAlertFirstButtonReturn){
                return;
            } else {
                [ui UI_kill_timer];
                [game Game_start:1];
            }
        }];
    } else {
        [ui UI_kill_timer];
        [game Game_start:1];
    }
}

- (IBAction)pause_game:(id)sender
{
	[ui UI_popup_dialog:DIALOG_PAUSEGAME];
}

- (IBAction)quit_game:(id)sender
{
	[game Game_quit];
}

- (IBAction)warp_level:(id)sender
{
	NSInteger ret;
	ret = [NSApp runModalForWindow:[warp window]];
    if (ret == NSModalResponseOK) {
		int level = [warp intValue];
		if (level == 0) {
			level = 1;
		}
		[ui UI_kill_timer];
		[game Game_start:level];
	}
}

- (IBAction)high_score:(id)sender
{
	[NSApp runModalForWindow:highscore];
}

- (IBAction)story:(id)sender
{
	[NSApp runModalForWindow:story];
}

- (IBAction)rules:(id)sender
{
	[NSApp runModalForWindow:rules];
}

- (IBAction)about:(id)sender
{
	[NSApp runModalForWindow:about];
}

- (IBAction)pref:(id)sender
{
	int i, tmp;
    NSInteger ret;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *keys[] = { @"fieldsize", @"interval", @"transparency" };
	id texts[] = { text_size, text_timer, text_trans };
	id sliders[] = { slider_size, slider_timer, slider_trans };

	for (i = 0; i < 3; i++) {
		tmp = [[defaults objectForKey:keys[i]] intValue];
		[texts[i] setIntValue:tmp];
		[sliders[i] setIntValue:tmp];
	}
	ret = [NSApp runModalForWindow:[text_size window]];
    if (ret == NSModalResponseOK) {
		for (i = 0; i < 3; i++) {
			[defaults setInteger:[texts[i] intValue] forKey:keys[i]];
		}
	}
}

- (IBAction)modalOk:(id)sender
{
	[NSApp stopModalWithCode:DIALOG_OK];
	[[sender window] orderOut:sender];
}

- (IBAction)modalCancel:(id)sender
{
	[NSApp stopModalWithCode:DIALOG_CANCEL];
	[[sender window] orderOut:sender];
}


- (void)aqua_button_press:(int)x :(int)y
{
	[game Game_button_press:x :y];
}

- (void)aqua_button_release:(int)x :(int)y
{
	[game Game_button_release:x :y];
}


// NSApplication's delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// get userdefaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *s = [[NSBundle mainBundle] pathForResource:@"MacBill" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:s];
	if (dict != nil) {
		[defaults registerDefaults:dict];
	}
	
	// if we don't have a value already
	// set default for animation interval
	if ([defaults integerForKey:@"interval"] == 0) {
		[defaults setInteger:200 forKey:@"interval"];
	}

	[[view window] center];
	// autosave frame info
	[[view window] setFrameAutosaveName:@"main"];
	[[view window] makeKeyAndOrderFront:self];
	// set username to name entry
	[entry setStringValue:NSUserName()];

	[game Game_set_size:[[defaults objectForKey:@"fieldsize"] intValue]];
	[ui UI_set_interval:[[defaults objectForKey:@"interval"] intValue]];
	[view setTransparency:[[defaults objectForKey:@"transparency"] intValue]];

	[game Game_main];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSAlert* alert;
    if([game Game_state] != 4) { // check whether a game is active
        NSLog(@"Game is active");
        alert = [self runAlertPanel:@"quit" :YES];
        NSModalResponse ret = [alert runModal];
        if (ret != NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
        [game Game_quit];
        return NSTerminateNow;
    } else {
        return NSTerminateNow;
    }
}


// NSWindow's delegate methods
- (void)windowDidResignKey:(NSNotification *)notification
{
	[self leave_window];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[self enter_window];
}


// enable/disable menu item
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (menuItem == menu_pause) {
		return menu_pause_enable_flag;
	} else {
		return YES;
	}
}

@end
