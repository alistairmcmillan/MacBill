/* MBGame */

#import <Cocoa/Cocoa.h>

@interface MBGame : NSObject
{
    IBOutlet id bucket;
    IBOutlet id horde;
    IBOutlet id network;
    IBOutlet id os;
    IBOutlet id scorelist;
    IBOutlet id spark;
    IBOutlet id ui;
}

- (void)Game_start:(int)newlevel;
- (void)Game_quit;
- (void)Game_warp_to_level:(int)lev;
- (void)Game_add_high_score:(const char *)str;
- (void)Game_button_press:(int)x :(int)y;
- (void)Game_button_release:(int)x :(int)y;
- (void)Game_update;

- (int)Game_state;
- (int)Game_score;
- (int)Game_level;
- (int)Game_screensize;
- (double)Game_scale:(int)dimensions;

- Game_main;

- (void)Game_set_size:(int)size;

@end
