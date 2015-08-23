//
//  libLunar.h
//  SSLunarDate
//
//  Created by Jiejing Zhang on 13-2-6.
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

#ifndef SSLunarDate_libLunar_h
#define SSLunarDate_libLunar_h

#include "SSLunarDateType.h"


int libLunarCheckYearRange(int year);
void Lunar2Solar(struct LibLunarContext *ctx, SSLunarSimpleDate *lunar);
void Solar2Lunar(struct LibLunarContext *ctx, SSLunarSimpleDate *solar);
SSLunarSimpleDate *getLunarDate(LibLunarContext *ctx);
SSLunarSimpleDate *getSolarDate(LibLunarContext *ctx);

LibLunarContext * createLunarContext();
void  freeLunarContext(struct LibLunarContext *context);


#endif
