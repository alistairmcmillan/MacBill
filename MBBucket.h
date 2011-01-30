/* MBBucket */

#import <Cocoa/Cocoa.h>

@interface MBBucket : NSObject
{
    IBOutlet id network;
    IBOutlet id ui;
}

- (void)Bucket_load_pix;
- (void)Bucket_draw;
- (int)Bucket_clicked:(int)x :(int)y;
- (void)Bucket_grab:(int)x :(int)y;
- (void)Bucket_release:(int)x :(int)y;

@end
