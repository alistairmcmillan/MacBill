#import "MBtypes.h"
#import "MBHorde.h"

#import "MButil.h"

#import "MBBill.h"
#import "MBComputer.h"
#import "MBGame.h"
#import "MBNetwork.h"
#import "MBUI.h"

static MBBill *alive, *strays;
static int counters[HORDE_COUNTER_MAX + 1];

#define MAX_BILLS 100		/* max Bills per level */

#define UNLINK(bill, list)						\
	do {							\
		if ((bill)->next != NULL)			\
			(bill)->next->prev = (bill)->prev;	\
		if ((bill)->prev != NULL)			\
			(bill)->prev->next = (bill)->next;	\
		else if ((bill) == list)			\
			(list) = (bill)->next;			\
		(bill)->prev = NULL;				\
		(bill)->next = NULL;				\
	} while (0)

#define PREPEND(bill, list)					\
	do {							\
		(bill)->next = (list);				\
		if ((list) != NULL)				\
			(list)->prev = (bill);			\
		(list) = (bill);				\
	} while (0)

static int
max_at_once(unsigned int lev) {
	return MIN(2 + lev / 4, 12);
}

static int
between(unsigned int lev) {
	return MAX(14 - lev / 3, 10);
}

/*  Launches Bills whenever called  */
static void
launch(int max) {
	MBBill *bill;
	int n;
	int off_screen = counters[HORDE_COUNTER_OFF];

	if (max == 0 || off_screen == 0)
		return;
	n = RAND(1, MIN(max, off_screen));
	for (; n > 0; n--) {
		bill = [MBBill Bill_enter];
		PREPEND(bill, alive);
	}
}

@implementation MBHorde

// private
- (int)on:(unsigned int)lev
{
	int perlevel = (int)((8 + 3 * lev) * [game Game_scale:2]);
	return MIN(perlevel, MAX_BILLS);
}

- (void)Horde_setup
{
	MBBill *bill;
	while (alive != NULL) {
		bill = alive;
		UNLINK(bill, alive);
		[bill release];
	}
	while (strays != NULL) {
		bill = strays;
		UNLINK(bill, strays);
		[bill release];
	}
	counters[HORDE_COUNTER_OFF] = [self on:[game Game_level]];
	counters[HORDE_COUNTER_ON] = 0;
}

- (void)Horde_update:(int)iteration
{
	MBBill *bill, *next;
	int level = [game Game_level];
	if (iteration % between(level) == 0)
		launch(max_at_once(level));
	for (bill = alive; bill != NULL; bill = next) {
		next = bill->next;
		[bill Bill_update];
	}
}

- (void)Horde_draw
{
	MBBill *bill;

	for (bill = strays; bill != NULL; bill = bill->next)
		[bill Bill_draw];
	for (bill = alive; bill != NULL; bill = bill->next)
		[bill Bill_draw];
}

- (void)Horde_move_bill:(MBBill *)bill
{
	UNLINK(bill, alive);
	PREPEND(bill, strays);
}

- (void)Horde_remove_bill:(MBBill *)bill
{
	if (bill->state == BILL_STATE_STRAY)
		UNLINK(bill, strays);
	else
		UNLINK(bill, alive);
	[network Network_clear_stray:bill];
	[bill release];
}

- (void)Horde_add_bill:(MBBill *)bill
{
	if (bill->state == BILL_STATE_STRAY)
		PREPEND(bill, strays);
	else
		PREPEND(bill, alive);
}

- (MBBill *)Horde_clicked_stray:(int)x :(int)y
{
	MBBill *bill;

	for (bill = strays; bill != NULL; bill = bill->next) {
		if (![bill Bill_clickedstray:x :y])
			continue;
		UNLINK(bill, strays);
		return bill;
	}
	return NULL;
}

- (int)Horde_process_click:(int)x :(int)y
{
	MBBill *bill;
	int counter = 0;

	for (bill = alive; bill != NULL; bill = bill->next) {
		if (bill->state == BILL_STATE_DYING ||
		    ![bill Bill_clicked:x :y])
			continue;
		if (bill->state == BILL_STATE_AT) {
			MBComputer *comp;
			comp = [network Network_get_computer:bill->target_c];
			comp->busy = 0;
			comp->stray = bill;
		}
		[bill Bill_set_dying];
       	counter++;
	}
	return counter;
}

- (void)Horde_inc_counter:(int)counter :(int)val
{
	counters[counter] += val;
}

- (int)Horde_get_counter:(int)counter
{
	return counters[counter];
}

@end
