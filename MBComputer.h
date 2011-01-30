/* MBComputer */

#import <Cocoa/Cocoa.h>

@interface MBComputer : NSObject
{
@public
	int type;		/* CPU type */
	int os;			/* current OS */
	int x, y;		/* location */
	int busy;		/* is the computer being used? */
	MBBill *stray;
}

+ (void)Computer_class_init:g :n :o :u;

+ (MBComputer *)Computer_setup:(int)i;
- (void)Computer_draw;
- (int)Computer_on:(int)locx :(int)locy;
- (int)Computer_compatible:(int)system;
+ (void)Computer_load_pix;
- (int)Computer_width;
- (int)Computer_height;

#define COMPUTER_TOASTER 0	/* computer 0 is a toaster */

@end
