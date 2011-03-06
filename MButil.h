/*
 *  util.h
 *  MacBill
 *
 *  Created by Ishioka Hiroshi on Sun Dec 16 2001.
 *  Copyright (c) 2001-2002 Ishioka Hiroshi. All rights reserved.
 *
 */

#ifdef RAND
#undef RAND
#endif
#define RAND(lb, ub) (random() % ((ub) - (lb) + 1) + (lb))

#ifdef MAX
#undef MAX
#endif
#define MAX(x, y) ((x) > (y) ? (x) : (y))

#ifdef MIN
#undef MIN
#endif
#define MIN(x, y) ((x) < (y) ? (x) : (y))

#ifdef UNUSED
#undef UNUSED
#endif
#define UNUSED(x) (void)(x)
