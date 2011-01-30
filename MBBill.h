/* MBBill */

#import <Cocoa/Cocoa.h>

/* Bill's states */
#define BILL_STATE_IN 1
#define BILL_STATE_AT 2
#define BILL_STATE_OUT 3
#define BILL_STATE_DYING 4
#define BILL_STATE_STRAY 5

/* Offsets from upper right of computer */
#define BILL_OFFSET_X 20
#define BILL_OFFSET_Y 3

@interface MBBill : NSObject
{
@public
	int state;		/* what is it doing? */
	int index;		/* index of animation frame */
	MBPicture **cels;		/* array of animation frames */
	int x, y;		/* location */
	int target_x;		/* target x position */
	int target_y;		/* target y position */
	int target_c;		/* target computer */
	int cargo;		/* which OS carried */
	int x_offset;		/* accounts for width differences */
	int y_offset;		/* 'bounce' factor for OS carried */
	int sx, sy;		/* used for drawing extra OS during switch */
	MBBill *prev, *next;
}

+ (void)Bill_class_init:g :h :n :o :u;

+ Bill_enter;
- (void)Bill_draw;
- (void)Bill_update;
- (void)Bill_set_dying;
- (int)Bill_clicked:(int)locx :(int)locy;
- (int)Bill_clickedstray:(int)locx :(int)locy;
+ (void)Bill_load_pix;
+ (int)Bill_width;
- (int)Bill_height;
- (int)Bill_get_state;

@end
