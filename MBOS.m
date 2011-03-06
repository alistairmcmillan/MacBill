#import "MBtypes.h"
#import "MBOS.h"

#import "MButil.h"

#import "MBUI.h"

#define MIN_PC 6		/* OS >= MIN_PC means the OS is a PC OS */

static const char *osname[] = {"wingdows", "apple", "next", "sgi", "sun",
			       "palm", "os2", "bsd", "linux", "redhat", "hurd", "beos"};
#define NUM_OS (sizeof(osname) / sizeof(osname[0]))

static MBPicture *os[NUM_OS];		/* array of OS pictures*/
static MBMCursor *cursor[NUM_OS];		/* array of OS cursors (drag/drop) */

@implementation MBOS

- (void)OS_load_pix
{
	unsigned int i;
	for (i = 0; i < NUM_OS; i++) {
		[ui UI_load_picture:osname[i] :1 :&os[i]];
		if (i != 0)
			[ui UI_load_cursor:osname[i] :CURSOR_OWN_MASK :&cursor[i]];
	}
}

- (void)OS_draw:(int)index :(int)x :(int)y
{
	[ui UI_draw:os[index] :x :y];
}

- (int)OS_width
{
	return [ui UI_picture_width:os[0]];
}

- (int)OS_height
{
	return [ui UI_picture_height:os[0]];
}

- (void)OS_set_cursor:(int)index
{
	[ui UI_set_cursor:cursor[index]];
}

- (int)OS_randpc
{
	return (RAND(MIN_PC, NUM_OS - 1));
}

- (int)OS_ispc:(int)index
{
	return (index >= MIN_PC);
}

@end
