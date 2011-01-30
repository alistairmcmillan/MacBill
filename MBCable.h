/* MBCable */

#import <Cocoa/Cocoa.h>

@interface MBCable : NSObject
{
	int x, y;		/* current location of spark */
	float fx, fy;		/* needed for line drawing */
	int delay;		/* how much time until spark leaves */
	int active;		/* is spark moving and from which end */
	int index;
@public
	int c1, c2;		/* computers connected */
	int x1, y1, x2, y2;	/* endpoints of line representing cable */
}

+ (void)Cable_class_init:g :n :s :u;

+ (MBCable *)Cable_setup;
- (void)Cable_draw;
- (void)Cable_update;
- (int)Cable_onspark:(int)locx :(int)locy;
- (void)Cable_reset;

@end
