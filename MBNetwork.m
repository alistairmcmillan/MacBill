#import "MBtypes.h"
#import "MBNetwork.h"

#import "MButil.h"

#import "MBBill.h"
#import "MBCable.h"
#import "MBComputer.h"
#import "MBGame.h"
#import "MBOS.h"

#define STD_MAX_COMPUTERS 20

static NSMutableArray *computers = nil;
static int ncomputers;
static NSMutableArray *cables = nil;
static int ncables;
static int counters[NETWORK_COUNTER_MAX + 1]; 	/* number in each state */

@implementation MBNetwork

- (int)on:(int)level
{
	int normal = MIN(8 + level, STD_MAX_COMPUTERS);
	return (int)(normal * [game Game_scale:2]);
}

/* sets up network for each level */
- (void)Network_setup
{
	int i;	
	ncomputers = [self on:[game Game_level]];
	if (computers != nil)
		while ([computers count] != 0) {
			[computers removeObjectAtIndex:0];
		}
		[computers release];
	if (cables != nil) {
		while ([cables count] != 0) {
			[cables removeObjectAtIndex:0];
		}
		[cables release];
	}
	computers = [[NSMutableArray alloc] init];
	for (i = 0; i < ncomputers; i++) {
		id comp = [MBComputer Computer_setup:i];
		if (comp != nil) {
			[computers addObject:comp];
		} else {
			ncomputers = i - 1;
			break;
		}
	}
	counters[NETWORK_COUNTER_OFF] = 0;
	counters[NETWORK_COUNTER_BASE] = ncomputers;
	counters[NETWORK_COUNTER_WIN] = 0;
	ncables = MIN([game Game_level], ncomputers/2);
	cables = [[NSMutableArray alloc] init];
	for (i = 0; i < ncables; i++)
		[cables addObject:[MBCable Cable_setup]];
}

/* redraws the computers at their location with the proper image */
- (void)Network_draw
{
	int i;
	for (i = 0; i < ncables; i++)
		[[cables objectAtIndex:i] Cable_draw];
	for (i = 0; i < ncomputers; i++)
		[[computers objectAtIndex:i] Computer_draw];
}

- (void)Network_update
{
	int i;
	for (i = 0; i < ncables; i++)
		[[cables objectAtIndex:i] Cable_update];
}

- (void)Network_toasters
{
	int i;
	for (i = 0; i < ncomputers; i++) {
		((MBComputer *)[computers objectAtIndex:i])->type = COMPUTER_TOASTER;
		((MBComputer *)[computers objectAtIndex:i])->os = OS_OFF;
	}
	ncables = 0;
}

- (MBComputer *)Network_get_computer:(int)index
{
	return [computers objectAtIndex:index];
}

- (int)Network_num_computers
{
	return ncomputers;
}

- (MBCable *)Network_get_cable:(int)index
{
	return [cables objectAtIndex:index];
}

- (int)Network_num_cables
{
	return ncables;
}

- (void)Network_clear_stray:(MBBill *)bill
{
	int i;
	for (i = 0; i < ncomputers; i++) {
		if (((MBComputer *)[computers objectAtIndex:i])->stray == bill)
			((MBComputer *)[computers objectAtIndex:i])->stray = NULL;
	}
}

- (void)Network_inc_counter:(int)counter :(int)val
{
	counters[counter] += val;
}

- (int)Network_get_counter:(int)counter
{
	return counters[counter];
}

@end
