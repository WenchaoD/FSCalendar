//
//  SSLunarDateType.h
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-2-7.
//  Copyright (c) 2013 Jiejing Zhang. All rights reserved.

//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
//

#ifndef SSLunarDate_SSLunarDateType_h
#define SSLunarDate_SSLunarDateType_h

typedef struct {
    int year, month, day, hour, weekday;
    int leap;	/* the lunar month is a leap month */
} SSLunarSimpleDate;

#define Cyear	1900	/* Note that LC1900.1.1 is SC1900.1.31 */
#define Nyear	150	/* number of years covered by the table */
#define Nmonth  13	/* maximum number of months in a lunar year */


typedef struct LibLunarContext {
    SSLunarSimpleDate _solar;
    SSLunarSimpleDate _lunar;
    SSLunarSimpleDate _gan;
    SSLunarSimpleDate _zhi;
    SSLunarSimpleDate _gan2;
    SSLunarSimpleDate _zhi2;
    SSLunarSimpleDate _lunar2;
    int _ymonth[Nyear];
    int _yday[Nyear];
    int _mday[Nmonth + 1];
    int _jieAlert;
} LibLunarContext;

#endif
