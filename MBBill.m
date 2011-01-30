#import "MBtypes.h"
#import "MBBill.h"

#import "MButil.h"

#import "MBComputer.h"
#import "MBGame.h"
#import "MBHorde.h"
#import "MBNetwork.h"
#import "MBOS.h"
#import "MBUI.h"

/* speed at which OS drops */
#define GRAVITY 3

/* speed of moving Bill */
#define SLOW 0
#define FAST 1

#define WCELS 4                 /* # of bill walking animation frames */
#define DCELS 5                 /* # of bill dying animation frames */
#define ACELS 13                /* # of bill switching OS frames */

static MBPicture *lcels[WCELS], *rcels[WCELS], *acels[ACELS], *dcels[DCELS];
static int width, height;

static MBGame *game;
static MBHorde *horde;
static MBNetwork *network;
static MBOS *os;
static MBUI *ui;

static void
get_border(int *x, int *y) {
	int i = RAND(0, 3);
	int screensize = [game Game_screensize];

	if (i % 2 == 0)
		*x = RAND(0, screensize - width);
	else
		*y = RAND(0, screensize - height);

	switch (i) {
		case 0:
			*y = -height - 16;
			break;
		case 1:
			*x = screensize + 1;
			break;
		case 2:
			*y = screensize + 1;
			break;
		case 3:
			*x = - width - 2;
			break;
	}
}

static int
step_size(unsigned int level) {
	return MIN(11 + level, 15);
}

/*  Moves bill toward his target - returns whether or not he moved */
static int
move(MBBill *bill, int mode) {
	int xdist = bill->target_x - bill->x;
	int ydist = bill->target_y - bill->y;
	int step = step_size([game Game_level]);
	int dx, dy;
	int signx = xdist >= 0 ? 1 : -1;
	int signy = ydist >= 0 ? 1 : -1;
	xdist = abs(xdist);
	ydist = abs(ydist);
	if (!xdist && !ydist)
		return 0;
	else if (xdist < step && ydist < step) {
		bill->x = bill->target_x;
		bill->y = bill->target_y;
	}
	else {
		dx = (xdist*step*signx)/(xdist+ydist);
		dy = (ydist*step*signy)/(xdist+ydist);
		if (mode == FAST) {
			dx *= 1.25;
			dy *= 1.25;
		}
		bill->x += dx;
		bill->y += dy;
		if (dx < 0)
			bill->cels = lcels;
		else if (dx > 0)
			bill->cels = rcels;
	}
	return 1;
}

static void
draw_std(MBBill *bill) {
	if (bill->cargo >= 0)
		[os OS_draw:bill->cargo :bill->x + bill->x_offset
			:bill->y + bill->y_offset];
	[ui UI_draw:bill->cels[bill->index] :bill->x :bill->y];
}

static void
draw_at(MBBill *bill) {
	MBComputer *computer = [network Network_get_computer:bill->target_c];
	if (bill->index > 6 && bill->index < 12)
		[os OS_draw:0 :bill->x + bill->sx :bill->y + bill->sy];
	if (bill->cargo >= 0)
		[os OS_draw:bill->cargo :bill->x + bill->x_offset
			:bill->y + bill->y_offset];
	[ui UI_draw:bill->cels[bill->index] :computer->x :computer->y];
}

static void
draw_stray(MBBill *bill) {
	[os OS_draw:bill->cargo :bill->x :bill->y];
}

/*  Update Bill's position */	
static void
update_in(MBBill *bill) {
	int moved = move(bill, SLOW);
	MBComputer *computer = [network Network_get_computer:bill->target_c];
	if (!moved && computer->os != OS_WINGDOWS && !computer->busy) {
		computer->busy = 1;
		bill->cels = acels;
		bill->index = 0;
		bill->state = BILL_STATE_AT;
		return;
	}
	else if (!moved) {
		int i;
		do {
			i = RAND(0, [network Network_num_computers] - 1);
		} while (i == bill->target_c);
		computer = [network Network_get_computer:i];
		bill->target_c = i;
		bill->target_x = computer->x + [computer Computer_width] - BILL_OFFSET_X;
		bill->target_y = computer->y + BILL_OFFSET_Y;
	}
	bill->index++;
	bill->index %= WCELS;
	bill->y_offset += (8 * (bill->index % 2) - 4);
}

/*  Update Bill standing at a computer */
static void
update_at(MBBill *bill) {
	MBComputer *computer = [network Network_get_computer:bill->target_c];
	if (bill->index == 0 && computer->os == OS_OFF) {
		bill->index = 6;
		if (computer->stray == NULL)
			bill->cargo = -1;
		else {
			bill->cargo = computer->stray->cargo;
			[horde Horde_remove_bill:computer->stray];
			computer->stray = NULL;
		}
	} else
		bill->index++;
	if (bill->index == 13) {
		bill->y_offset = -15;
		bill->x_offset = -2;
		get_border(&bill->target_x, &bill->target_y);
		bill->index = 0;
		bill->cels = lcels;
		bill->state = BILL_STATE_OUT;
		computer->busy = 0;
		return;
	}
	bill->y_offset = height - [os OS_height];
	switch (bill->index) {
	case 1: 
	case 2:
		bill->x -= 8;
		bill->x_offset +=8;
		break;
	case 3:
		bill->x -= 10;
		bill->x_offset +=10;
		break;
	case 4:
		bill->x += 3;
		bill->x_offset -=3;
		break;
	case 5:
		bill->x += 2;
		bill->x_offset -=2;
		break;
	case 6:
		if (computer->os != OS_OFF) {
			[network Network_inc_counter:NETWORK_COUNTER_BASE: -1];
			[network Network_inc_counter:NETWORK_COUNTER_OFF: 1];
			bill->cargo = computer->os;
		}
		else {
			bill->x -= 21;
			bill->x_offset += 21;
		}
		computer->os = OS_OFF;
		bill->y_offset = -15;
		bill->x += 20;
		bill->x_offset -=20;
		break;
	case 7:
		bill->sy = bill->y_offset;
		bill->sx = -2;
		break;
	case 8:
		bill->sy = -15;
		bill->sx = -2;
		break;
	case 9:
		bill->sy = -7;
		bill->sx = -7;
		bill->x -= 8;
		bill->x_offset +=8;
		break;	
	case 10:
		bill->sy = 0;
		bill->sx = -7;
		bill->x -= 15;
		bill->x_offset +=15;
		break;
	case 11:
		bill->sy = 0;
		bill->sx = -7;
		computer->os = OS_WINGDOWS;
		[network Network_inc_counter:NETWORK_COUNTER_OFF: -1];
		[network Network_inc_counter:NETWORK_COUNTER_WIN: 1];
		break;
	case 12:
		bill->x += 11;
		bill->x_offset -=11;
	}
}

/* Updates Bill fleeing with his ill gotten gain */
static void
update_out(MBBill *bill) {
	int screensize = [game Game_screensize];
	if ([ui UI_intersect:bill->x :bill->y :width :height :0 :0
			 :screensize :screensize])
	{
		move(bill, FAST);
		bill->index++;
		bill->index %= WCELS;
		bill->y_offset += (8*(bill->index%2)-4); 
	}
	else {
		[horde Horde_remove_bill:bill];
		[horde Horde_inc_counter:HORDE_COUNTER_ON :-1];
		[horde Horde_inc_counter:HORDE_COUNTER_OFF :1];
	}
}


/* Updates a Bill who is dying */
static void
update_dying(MBBill *bill) {
	if (bill->index < DCELS - 1){
		bill->y_offset += (bill->index * GRAVITY);
		bill->index++;	
	}
	else {
		bill->y += bill->y_offset;
		if (bill->cargo < 0 || bill->cargo == OS_WINGDOWS)
			[horde Horde_remove_bill:bill];
		else {
			[horde Horde_move_bill:bill];
			bill->state = BILL_STATE_STRAY;
		}
		[horde Horde_inc_counter:HORDE_COUNTER_ON :-1];
	}
}

@implementation MBBill

+ (void)Bill_class_init:g :h :n :o :u
{
	game = g;
	horde = h;
	network = n;
	os = o;
	ui = u;
}

/* Adds a bill to the in state */
+ Bill_enter
{
	MBBill *bill;
	MBComputer *computer;

	bill = [[self alloc] init];

	bill->state = BILL_STATE_IN;
	get_border(&bill->x, &bill->y);
	bill->index = 0;
	bill->cels = lcels;
	bill->cargo = OS_WINGDOWS;
	bill->x_offset = -2;
	bill->y_offset = -15;
	bill->target_c = RAND(0, [network Network_num_computers] - 1);
	computer = [network Network_get_computer:bill->target_c];
	bill->target_x = computer->x + [computer Computer_width] - BILL_OFFSET_X;
	bill->target_y = computer->y + BILL_OFFSET_Y;
	[horde Horde_inc_counter:HORDE_COUNTER_ON: 1];
	[horde Horde_inc_counter:HORDE_COUNTER_OFF: -1];
	bill->prev = NULL;
	bill->next = NULL;
	return bill;
}

- (void)Bill_draw
{
	switch (state) {
		case BILL_STATE_IN:
		case BILL_STATE_OUT:
		case BILL_STATE_DYING:
			draw_std(self);
			break;
		case BILL_STATE_AT:
			draw_at(self);
			break;
		case BILL_STATE_STRAY:
			draw_stray(self);
			break;
		default:
			break;
	}
}

- (void)Bill_update
{
	switch (state) {
		case BILL_STATE_IN:
			update_in(self);
			break;
		case BILL_STATE_AT:
			update_at(self);
			break;
		case BILL_STATE_OUT:
			update_out(self);
			break;
		case BILL_STATE_DYING:
			update_dying(self);
			break;
		default:
			break;
	}
}

- (void)Bill_set_dying
{
	index = -1;
	cels = dcels;
	x_offset = -2;
	y_offset = -15;
	state = BILL_STATE_DYING;
}

- (int)Bill_clicked:(int)locx :(int)locy
{
	return (locx > x && locx < x + width &&
		locy > y && locy < y + height);
}

- (int)Bill_clickedstray:(int)locx :(int)locy
{
	return (locx > x && locx < x + [os OS_width] &&
		locy > y && locy < y + [os OS_height]);
}

+ (void)Bill_load_pix
{
	int i;
	for (i = 0; i < WCELS - 1; i++) {
		[ui UI_load_picture_indexed:"billL" :i :1 :&lcels[i]];
		[ui UI_load_picture_indexed:"billR" :i :1 :&rcels[i]];
	}
	lcels[WCELS - 1] = lcels[1];
	rcels[WCELS - 1] = rcels[1];

	for (i = 0; i < DCELS; i++)
		[ui UI_load_picture_indexed:"billD" :i :1 :&dcels[i]];
	width = [ui UI_picture_width:dcels[0]];
	height = [ui UI_picture_height:dcels[0]];

	for (i = 0; i < ACELS; i++)
		[ui UI_load_picture_indexed:"billA" :i :1 :&acels[i]];
}

+ (int)Bill_width
{
	return width;
}

- (int)Bill_height
{
	return height;
}

- (int)Bill_get_state
{
	return state;
}

@end
