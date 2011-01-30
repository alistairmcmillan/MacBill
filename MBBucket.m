#import "MBtypes.h"
#import "MBBucket.h"

#import "MButil.h"

#import "MBBucket.h"
#import "MBCable.h"
#import "MBGame.h"
#import "MBNetwork.h"
#import "MBUI.h"

static MBPicture *picture;
static MBMCursor *cursor;
static int grabbed;

@implementation MBBucket

- (void)Bucket_load_pix
{
	[ui UI_load_picture:"bucket" :1 :&picture];
	[ui UI_load_cursor:"bucket" :CURSOR_OWN_MASK :&cursor];
}

- (int)Bucket_clicked:(int)x :(int)y
{
	return (x > 0 && x < [ui UI_picture_width:picture] &&
		y > 0 && y < [ui UI_picture_height:picture]);
}

- (void)Bucket_draw
{
	if (!grabbed)
		[ui UI_draw:picture :0 :0];
}

- (void)Bucket_grab:(int)x :(int)y
{
	UNUSED(x);
	UNUSED(y);

	[ui UI_set_cursor:cursor];
	grabbed = 1;
}

- (void)Bucket_release:(int)x :(int)y
{
	int i;
	for (i = 0; i < [network Network_num_cables]; i++) {
		MBCable *cable = [network Network_get_cable:i];
		if ([cable Cable_onspark:x :y])
			[cable Cable_reset];
	}
	grabbed = 0;
}

@end
