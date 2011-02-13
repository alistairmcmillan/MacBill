#import "MBtypes.h"
#import "MBScorelist.h"

#import "MBUI.h"

#define NAMELEN 20
#define SCORES 10

static NSMutableArray *scores;

@implementation MBScorelist

- (void)Scorelist_read
{
	id tmpArray;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	scores = [[NSMutableArray alloc] init];
	if ((tmpArray = [defaults arrayForKey:@"scores"]) != nil) {
		[scores setArray:tmpArray];
	} else {
		int i;
		NSValue *zero = [NSNumber numberWithInt:0];
		for (i = 0; i < SCORES; i++) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setObject:@"Anonymous" forKey:@"name"];
			[dict setObject:zero forKey:@"level"];
			[dict setObject:zero forKey:@"score"];
			[scores addObject:dict];
		}
	}
}

- (void)Scorelist_write
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:scores forKey:@"scores"];
	[defaults synchronize];
}

/*  Add new high score to list   */
- (void)Scorelist_recalc:(const char *)str :(int)level :(int)score
{
	int i;
	NSMutableDictionary *dict;
        NSString *strName;

	if ([[[scores objectAtIndex:SCORES - 1] objectForKey:@"score"] intValue] >= score)
		return;
	for (i = SCORES - 1; i > 0; i--) {
		if ([[[scores objectAtIndex:i - 1] objectForKey:@"score"] intValue] >= score) {
			break;
		}
	}

	if (str == NULL || str[0] == 0) {
		strName = @"Anonymous";
	} else {
		strName = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        }

	dict = [NSMutableDictionary dictionary];
	[dict setObject:strName forKey:@"name"];
	[dict setObject:[NSNumber numberWithInt:level] forKey:@"level"];
	[dict setObject:[NSNumber numberWithInt:score] forKey:@"score"];

	[scores insertObject:dict atIndex:i];
	[scores removeLastObject];
}

- (int)Scorelist_ishighscore:(int)val
{
	return (val > [[[scores objectAtIndex:SCORES - 1] objectForKey:@"score"] intValue]);
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (SCORES);
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	id theRecord, theValue;
	NSParameterAssert(rowIndex >= 0 && rowIndex < SCORES);
	theRecord = [scores objectAtIndex:rowIndex];
	theValue = [theRecord objectForKey:[aTableColumn identifier]];
	return theValue;
}

@end
