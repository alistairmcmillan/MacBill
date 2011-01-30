/* MBHorde */

#import <Cocoa/Cocoa.h>

/* Counters */
#define HORDE_COUNTER_OFF 0
#define HORDE_COUNTER_ON 1
#define HORDE_COUNTER_MAX 1

@interface MBHorde : NSObject
{
    IBOutlet id game;
    IBOutlet id network;
}

- (void)Horde_setup;
- (void)Horde_update:(int)iteration;
- (void)Horde_draw;
- (void)Horde_move_bill:bill;
- (void)Horde_remove_bill:bill;
- (void)Horde_add_bill:bill;
- Horde_clicked_stray:(int)x :(int)y;
- (int)Horde_process_click:(int)x :(int)y;
- (void)Horde_inc_counter:(int)counter :(int)val;
- (int)Horde_get_counter:(int)counter;

@end
