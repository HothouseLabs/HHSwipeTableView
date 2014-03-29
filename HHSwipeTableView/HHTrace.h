//
//  Header.h
//  HHSwipeTableView
//
//  Created by Yuk Lai Suen on 3/28/14.
//  Copyright (c) 2014 Yuk Lai Suen. All rights reserved.
//

#ifndef HHSwipeTableView_Header_h
#define HHSwipeTableView_Header_h

#ifdef SWIPE_TRACE_ENABLE
#define HHTrace(__FORMAT__, ...) NSLog((@"%s line %d $ " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define HHTrace(__FORMAT__, ...) nil
#endif

#endif
