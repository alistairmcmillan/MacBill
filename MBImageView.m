#import "MBImageView.h"

#import "MBtypes.h"
#import "MBAqua.h"

static float transparency = 0.7f;

@implementation MBImageView

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	p = [self convertPoint:p fromView:nil];
	[aqua aqua_button_press:p.x :(NSHeight(_bounds) - p.y)];

	cursor = p;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	p = [self convertPoint:p fromView:nil];
	[aqua aqua_button_release:p.x :(NSHeight(_bounds) - p.y)];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	cursor = [self convertPoint:p fromView:nil];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	[subimage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
	if (drawCursor == YES) {
		NSImage* img = [[NSCursor currentCursor] image];
		NSSize size = [img size];
		[img dissolveToPoint:NSMakePoint(cursor.x - size.width / 2, cursor.y - size.height / 2) fraction:transparency];
	}
}


- (void)setSubimage:(NSImage *)image;
{
	subimage = image;
}

- (void)drawCursor:(BOOL)flag;
{
	drawCursor = flag;
}

- (void)setTransparency:(int)trans;
{
	if ((trans >= 0) && (trans <= 100)) {
		transparency = (100.0f - trans) / 100.0f;
	}
}

@end
