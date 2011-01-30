/* MBImageView */

#import <Cocoa/Cocoa.h>

@interface MBImageView : NSImageView
{
    IBOutlet id aqua;
	NSImage *subimage;
	NSPoint cursor;
	BOOL drawCursor;
}

- (void)setSubimage:(NSImage *)image;
- (void)drawCursor:(BOOL)flag;
- (void)setTransparency:(int)trans;

@end
