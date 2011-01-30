/* MBSpark */

#import <Cocoa/Cocoa.h>

#define SPARK_SPEED 4
#define SPARK_DELAY(level) (MAX(20 - (level), 0))

@interface MBSpark : NSObject
{
    IBOutlet id ui;
}

- (void)Spark_load_pix;
- (int)Spark_width;
- (int)Spark_height;
- (void)Spark_draw:(int)x :(int)y :(int)index;

@end
