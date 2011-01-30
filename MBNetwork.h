/* MBNetwork */

#import <Cocoa/Cocoa.h>

/* Counters */
#define NETWORK_COUNTER_OFF 0
#define NETWORK_COUNTER_BASE 1
#define NETWORK_COUNTER_WIN 2
#define NETWORK_COUNTER_MAX 2

@interface MBNetwork : NSObject
{
    IBOutlet id game;
}

- (void)Network_setup;
- (void)Network_draw;
- (void)Network_update;
- (void)Network_toasters;
- Network_get_computer:(int)index;
- (int)Network_num_computers;
- Network_get_cable:(int)index;
- (int)Network_num_cables;
- (void)Network_clear_stray:bill;
- (void)Network_inc_counter:(int)counter :(int)val;
- (int)Network_get_counter:(int)counter;

@end
