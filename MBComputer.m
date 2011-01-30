#import "MBtypes.h"
#import "MBBill.h"
#import "MBComputer.h"

#import "MButil.h"

#import "MBComputer.h"
#import "MBHorde.h"
#import "MBNetwork.h"
#import "MBGame.h"
#import "MBOS.h"
#import "MBUI.h"

static MBGame *game;
static MBNetwork *network;
static MBOS *Os;
static MBUI *ui;

#define OS_OFFSET 4			/* offset of screen from 0,0 */
#define BORDER(size) (size / 10)	/* at least this far from a side */

#define MIN_PC 6		/* type >= MIN_PC means the computer is a PC */

static const char *cpuname[] = {"toaster", "maccpu", "nextcpu", "sgicpu",
				"suncpu", "palmcpu", "os2cpu", "bsdcpu"};

#define NUM_SYS (sizeof(cpuname) / sizeof(cpuname[0]))

static MBPicture *pictures[NUM_SYS];		/* array of cpu pictures */
static int width, height;

static int
determineOS(MBComputer *computer) {
	if (computer->type < MIN_PC)
		return computer->type;
	else
		return [Os OS_randpc];
}

@implementation MBComputer

+ (void)Computer_class_init:g :n :o :u
{
	game = g;
	network = n;
	Os = o;
	ui = u;
}

+ (MBComputer *)Computer_setup:(int)index
{
	MBComputer *computer = [[self alloc] init];

	int j, counter = 0, flag;
	int randx, randy;
	int screensize = [game Game_screensize];
	int border = BORDER(screensize);
	do {
		if (++counter > 4000)
			return nil;
		randx = RAND(border, screensize - border - width);
		randy = RAND(border, screensize - border - height);
		flag = 1;
		/* check for conflicting computer placement */
		for (j = 0; j < index && flag; j++) {
			MBComputer *c = [network Network_get_computer:j];
			int twidth = width - BILL_OFFSET_X + [MBBill Bill_width];
			if ([ui UI_intersect:randx :randy :twidth :height
					 :c->x :c->y :twidth :height])
				flag = 0;
		}
	} while (!flag);
	computer->x = randx;
	computer->y = randy;
	computer->type = RAND(1, NUM_SYS - 1);
	computer->os = determineOS(computer);
	computer->busy = 0;
	computer->stray = NULL;
	return computer;
}

- (int)Computer_on:(int)locx :(int)locy
{
	return (locx + [Os OS_width] / 2 >= x &&
		locx - [Os OS_width] / 2 < x + width &&
		locy + [Os OS_height] / 2 >= y &&
		locy - [Os OS_height] / 2 < y + height);
}

- (int)Computer_compatible:(int)system
{
	return (type == system ||
		(type >= MIN_PC && [Os OS_ispc:system]));
}

- (void)Computer_draw
{
	[ui UI_draw:pictures[type] :x :y];
	if (os != OS_OFF)
		[Os OS_draw:os
			:x + OS_OFFSET :y + OS_OFFSET];
}

+ (void)Computer_load_pix
{
	unsigned int i;
	for (i = 0; i < NUM_SYS; i++)
		[ui UI_load_picture:cpuname[i] :1 :&pictures[i]];
	width = [ui UI_picture_width:pictures[0]];
	height = [ui UI_picture_height:pictures[0]];
}

- (int)Computer_width
{
	return width;
}

- (int)Computer_height
{
	return height;
}

@end
