/* MBScorelist */

#import <Cocoa/Cocoa.h>

@interface MBScorelist : NSObject
{
    IBOutlet id ui;
}

- (void)Scorelist_read;
- (void)Scorelist_write;
- (void)Scorelist_recalc:(const char *)str :(int)level :(int)score;
- (int)Scorelist_ishighscore:(int)val;

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

@end
