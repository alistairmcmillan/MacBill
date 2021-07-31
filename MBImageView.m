#import "MBImageView.h"

#import "MBtypes.h"
#import "MBAqua.h"

static float transparency = 0.7f;

@implementation MBImageView

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	p = [self convertPoint:p fromView:nil];
    [aqua aqua_button_press:p.x :(NSHeight(self.bounds) - p.y)];

	cursor = p;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	p = [self convertPoint:p fromView:nil];
    [aqua aqua_button_release:p.x :(NSHeight(self.bounds) - p.y)];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	cursor = [self convertPoint:p fromView:nil];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	[subimage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
	if (drawCursor == YES) {
		NSImage* img = [[NSCursor currentCursor] image];
		NSSize size = [img size];
		[img drawAtPoint:NSMakePoint(cursor.x - size.width / 2, cursor.y - size.height / 2) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:transparency];
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
