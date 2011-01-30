/* MBOS */

#import <Cocoa/Cocoa.h>

#define OS_WINGDOWS 0		/* OS 0 is wingdows */
#define OS_OFF -1		/* OS -1 means the computer is off */
#define OS_PC 6			/* OS >= PC means the OS is a PC OS */

@interface MBOS : NSObject
{
    IBOutlet id ui;
}

- (void)OS_load_pix;
- (void)OS_draw:(int)index :(int)x :(int)y;
- (int)OS_width;
- (int)OS_height;
- (void)OS_set_cursor:(int)index;
- (int)OS_randpc;
- (int)OS_ispc:(int)index;

@end
