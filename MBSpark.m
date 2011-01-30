#import "MBtypes.h"
#import "MBSpark.h"

#import "MButil.h"

#import "MBUI.h"

static MBPicture *pictures[2];

@implementation MBSpark

- (void)Spark_load_pix
{
	int i;
	for (i = 0; i < 2; i++)
		[ui UI_load_picture_indexed:"spark" :i :1 :&pictures[i]];
}

- (int)Spark_width
{
	return [ui UI_picture_width:pictures[0]];
}

- (int)Spark_height
{
	return [ui UI_picture_height:pictures[0]];
}

- (void)Spark_draw:(int)x :(int)y :(int)index
{
	[ui UI_draw:pictures[index] :x :y];
}

@end
