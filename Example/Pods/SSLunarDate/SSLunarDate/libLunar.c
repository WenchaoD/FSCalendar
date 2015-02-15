//
//  libLunar.c
//  SSLunarDate
//  Copyright (C) 2013 Zhang Jiejing
//
//  This lib is modify from Lunar conversion program by Fung F.Lee and Ricky Yeung
//  Because orignally work is not thread safe, I have modify the program to
//  make it thread safe.
//  Following is the copyright of orignial program.
//
/* 
 Lunar 2.2: A Calendar Conversion Program
 for
 Gregorian Solar Calendar and Chinese Lunar Calendar
 ---------------------------------------------------
 
 # Copyright (C) 1988,1989,1991,1992,2001 Fung F. Lee and Ricky Yeung
 #
 #
 # This program is free software; you can redistribute it and/or
 # modify it under the terms of the GNU General Public License
 # as published by the Free Software Foundation; either version 2
 # of the License, or any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 #
 #
 # Revision History:
 # The last version of this program was released on July 23, 1992 as
 # version 2.1a.  This program was first released under the terms of
 # GNU GPL on October 28, 2001 as version 2.2. Both versions are identical
 # except for the license text.
 #
 #
 # Please send your comments and suggestions to the authors:
 # Fung F. Lee	lee@umunhum.stanford.edu
 # Ricky Yeung	cryeung@hotmail.com
 #
 # The special "bitmap" file "lunar.bitmap" was contributed
 # by Weimin Liu (weimin@alpha.ece.jhu.edu).
 #
 # Special thanks to Hwei Chen Ti (chetihc@nuscc.nus.sg or
 # chetihc@nusvm.bitnet) who extended the tables from 2001 to 2049.
 #
 ----------------------------------------------------------------------------*/

/*
 This document contains Highest-bit-set GuoBiao (HGB) code, as adopted by
 CCDOS on IBM PC compatibles, ChineseTalk 6.0 (GB version) on Macintosh,
 and cxterm on UNIX and X window.  Hence, one may need to transfer this
 document as a **binary** file.
 
 References:
 1. "Zhong1guo2 yin1yang2 ri4yue4 dui4zhao4 wan4nian2li4" by Lin2 Qi3yuan2.
 《中国阴阳日月对照万年历》．林
 2. "Ming4li3 ge2xin1 zi3ping2 cui4yan2" by Xu2 Le4wu2.
 《命理革新子平粹言》．徐
 3. Da1zhong4 wan4nian2li4.
 《大众万年历》
 */



#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "libLunar.h"

#define VALID_MIN_YEAR 1900
#define VALID_MAX_YEAR 2049

static SSLunarSimpleDate SolarFirstDate = {
    /* Wednesday, 12 a.m., 31 January, 1900 */
    1900, 1, 31, 0, 3, 0
};

static SSLunarSimpleDate LunarFirstDate = {
    /* Wednesday, 12 a.m., First day, First month, 1900 */
    1900, 1, 1, 0, 3, 0
};

static SSLunarSimpleDate GanFirstDate = {
    /* geng1-nian2 wu4-yue4 jia3-ri4 jia3-shi2 */
    6,          4,       0,       0,           3, 0
};

static SSLunarSimpleDate ZhiFirstDate = {
    /* zi3-nian2 yin2-yue4 chen2-ri4 zi3-shi2 */
    0,        2,        4,        0,           3, 0
};

static long yearInfo[Nyear] = {
    /* encoding:
     b bbbbbbbbbbbb bbbb
     bit#    	1 111111000000 0000
     6 543210987654 3210
     . ............ ....
     month#	  000000000111
     M 123456789012   L
     
     b_j = 1 for long month, b_j = 0 for short month
     L is the leap month of the year if 1<=L<=12; NO leap month if L = 0.
     The leap month (if exists) is long one iff M = 1.
     */
    0x04bd8,	/* 1900 */
    0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950,	/* 1905 */
    0x16554, 0x056a0, 0x09ad0, 0x055d2, 0x04ae0,	/* 1910 */
    0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540,	/* 1915 */
    0x0d6a0, 0x0ada2, 0x095b0, 0x14977, 0x04970,	/* 1920 */
    0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54,	/* 1925 */
    0x02b60, 0x09570, 0x052f2, 0x04970, 0x06566,	/* 1930 */
    0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60,	/* 1935 */
    0x186e3, 0x092e0, 0x1c8d7, 0x0c950, 0x0d4a0,	/* 1940 */
    0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0,	/* 1945 */
    0x092d0, 0x0d2b2, 0x0a950, 0x0b557, 0x06ca0,	/* 1950 */
    0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573,	/* 1955 */
    0x052d0, 0x0a9a8, 0x0e950, 0x06aa0, 0x0aea6,	/* 1960 */
    0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260,	/* 1965 */
    0x0f263, 0x0d950, 0x05b57, 0x056a0, 0x096d0,	/* 1970 */
    0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250,	/* 1975 */
    0x0d558, 0x0b540, 0x0b5a0, 0x195a6, 0x095b0,	/* 1980 */
    0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50,	/* 1985 */
    0x06d40, 0x0af46, 0x0ab60, 0x09570, 0x04af5,	/* 1990 */
    0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58,	/* 1995 */
    0x05ac0, 0x0ab60, 0x096d5, 0x092e0, 0x0c960,	/* 2000 */
    0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0,	/* 2005 */
    0x0abb7, 0x025d0, 0x092d0, 0x0cab5, 0x0a950,	/* 2010 */
    0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0,	/* 2015 */
    0x0a5b0, 0x15176, 0x052b0, 0x0a930, 0x07954,	/* 2020 */
    0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6,	/* 2025 */
    0x0a4e0, 0x0d260, 0x0ea65, 0x0d530, 0x05aa0,	/* 2030 */
    0x076a3, 0x096d0, 0x04bd7, 0x04ad0, 0x0a4d0,	/* 2035 */
    0x1d0b6, 0x0d250, 0x0d520, 0x0dd45, 0x0b5a0,	/* 2040 */
    0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0,	/* 2045 */
    0x0aa50, 0x1b255, 0x06d20, 0x0ada0			/* 2049 */
};

/*
 In "4-column" calculation, a "mingli" (fortune-telling) calculation,
 the beginning of a month is not the first day of the month as in
 the Lunar Calendar; it is instead governed by "jie2" (festival).
 Interestingly, in the Solar calendar, a jie always comes around certain
 day. For example, the jie "li4chun1" (beginning of spring) always comes
 near Feburary 4 of the Solar Calendar.
 
 Meaning of array fest:
 Each element, fest[i][j] stores the jie day (in term of the following Solar
 month) of the lunar i-th year, j-th month.
 For example, in 1992, fest[92][0] is 4, that means the jie "li4chun1"
 (beginning of spring) is on Feb. 4, 1992; fest[92][11] is 5, that means
 the jie of the 12th lunar month is on Jan. 5, 1993.
 */

typedef char byte;

static byte fest[Nyear][12] = {
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1900 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1901 */
    {5, 6, 6, 6, 7, 8, 8, 8, 9, 8, 8, 6},	/* 1902 */
    {5, 7, 6, 7, 7, 8, 9, 9, 9, 8, 8, 7},	/* 1903 */
    {5, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1904 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1905 */
    {5, 6, 6, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1906 */
    {5, 7, 6, 7, 7, 8, 9, 9, 9, 8, 8, 7},	/* 1907 */
    {5, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1908 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1909 */
    {5, 6, 6, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1910 */
    {5, 7, 6, 7, 7, 8, 9, 9, 9, 8, 8, 7},	/* 1911 */
    {5, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1912 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1913 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1914 */
    {5, 6, 6, 6, 7, 8, 8, 9, 9, 8, 8, 6},	/* 1915 */
    {5, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1916 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 7, 6},	/* 1917 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1918 */
    {5, 6, 6, 6, 7, 8, 8, 9, 9, 8, 8, 6},	/* 1919 */
    {5, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1920 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 9, 7, 6},	/* 1921 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1922 */
    {5, 6, 6, 6, 7, 8, 8, 9, 9, 8, 8, 6},	/* 1923 */
    {5, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1924 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 7, 6},	/* 1925 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1926 */
    {5, 6, 6, 6, 7, 8, 8, 8, 9, 8, 8, 6},	/* 1927 */
    {5, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1928 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1929 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1930 */
    {5, 6, 6, 6, 7, 8, 8, 8, 9, 8, 8, 6},	/* 1931 */
    {5, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1932 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1933 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1934 */
    {5, 6, 6, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1935 */
    {5, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1936 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1937 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1938 */
    {5, 6, 6, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1939 */
    {5, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1940 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1941 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1942 */
    {5, 6, 6, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1943 */
    {5, 6, 5, 5, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1944 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1945 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1946 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1947 */
    {5, 5, 5, 5, 6, 7, 7, 8, 8, 7, 7, 5},	/* 1948 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1949 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1950 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1951 */
    {5, 5, 5, 5, 6, 7, 7, 8, 8, 7, 7, 5},	/* 1952 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1953 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 7, 6},	/* 1954 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1955 */
    {5, 5, 5, 5, 6, 7, 7, 8, 8, 7, 7, 5},	/* 1956 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1957 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1958 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1959 */
    {5, 5, 5, 5, 6, 7, 7, 7, 8, 7, 7, 5},	/* 1960 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1961 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1962 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1963 */
    {5, 5, 5, 5, 6, 7, 7, 7, 8, 7, 7, 5},	/* 1964 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1965 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1966 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1967 */
    {5, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1968 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1969 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1970 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1971 */
    {5, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1972 */
    {4, 6, 5, 5, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1973 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1974 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1975 */
    {5, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1976 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 1977 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1978 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1979 */
    {5, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1980 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 1981 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1982 */
    {4, 6, 5, 6, 6, 8, 8, 8, 9, 8, 8, 6},	/* 1983 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1984 */
    {5, 5, 5, 5, 5, 8, 7, 7, 8, 7, 7, 5},	/* 1985 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1986 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1987 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1988 */
    {5, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1989 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 1990 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1991 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1992 */
    {5, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1993 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1994 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1995 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1996 */
    {5, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 1997 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 1998 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 1999 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2000 */
    {4, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2001 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 2002 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 2003 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2004 */
    {4, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2005 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 2006 */
    {4, 6, 5, 6, 6, 7, 8, 8, 9, 8, 7, 6},	/* 2007 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2008 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2009 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 2010 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 2011 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2012 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2013 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 2014 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 2015 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2016 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2017 */
    {4, 5, 5, 5, 6, 7, 7, 8, 8, 7, 7, 5},	/* 2018 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 2019 */
    {4, 5, 4, 5, 5, 6, 7, 7, 8, 7, 7, 5},	/* 2020 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2021 */
    {4, 5, 5, 5, 6, 7, 7, 7, 8, 7, 7, 5},	/* 2022 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 8, 7, 6},	/* 2023 */
    {4, 5, 4, 5, 5, 6, 7, 7, 8, 7, 6, 5},	/* 2024 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2025 */
    {4, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2026 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 2027 */
    {4, 5, 4, 5, 5, 6, 7, 7, 8, 7, 6, 5},	/* 2028 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2029 */
    {4, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2030 */
    {4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7, 6},	/* 2031 */
    {4, 5, 4, 5, 5, 6, 7, 7, 8, 7, 6, 5},	/* 2032 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2033 */
    {4, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2034 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 2035 */
    {4, 5, 4, 5, 5, 6, 7, 7, 8, 7, 6, 5},	/* 2036 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2037 */
    {4, 5, 5, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2038 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 2039 */
    {4, 5, 4, 5, 5, 6, 7, 7, 8, 7, 6, 5},	/* 2040 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2041 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2042 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 2043 */
    {4, 5, 4, 5, 5, 6, 7, 7, 7, 7, 6, 5},	/* 2044 */
    {3, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2045 */
    {4, 5, 4, 5, 5, 7, 7, 7, 8, 7, 7, 5},	/* 2046 */
    {4, 6, 5, 5, 6, 7, 7, 8, 8, 7, 7, 6},	/* 2047 */
    {4, 5, 4, 5, 5, 6, 7, 7, 7, 7, 6, 5},	/* 2048 */
    {3, 5, 4, 5, 5, 6, 7, 7, 8, 7, 7, 5}	/* 2049 */
};

static const int daysInSolarMonth[13] = {
    0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

static int moon[2] = {29,30}; /* a short (long) lunar month has 29 (30) days */

#if 0
static	char	*Gan[] = {
	"Jia3",	"Yi3",	 "Bing3", "Ding1", "Wu4",
	"Ji3",	"Geng1", "Xin1",  "Ren2",  "Gui3"
};

static	char	*Zhi[] = {
	"Zi3",	"Chou3", "Yin2",  "Mao3",  "Chen2", "Si4",
	"Wu3",	"Wei4",	 "Shen1", "You3",  "Xu1",   "Hai4"
};

static	char   *ShengXiao[] = {
    "Mouse", "Ox", "Tiger", "Rabbit", "Dragon", "Snake",
    "Horse", "Goat", "Monkey", "Rooster", "Dog", "Pig"
};

static char *weekday[] = {
    "Sunday", "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday"
};

static	char	*GanGB[] = {
    "甲", "乙", "丙", "丁", "戊",
    "己", "庚", "辛", "壬", "癸"
};

static	char	*ZhiGB[] = {
    "子", "丑", "寅", "卯", "辰", "巳",
    "午", "未", "申", "酉", "戌", "亥"
};

static	char   *ShengXiaoGB[] = {
    "鼠", "牛", "虎", "兔", "龙", "蛇",
    "马", "羊", "猴", "鸡", "狗", "猪"
};

static char *weekdayGB[] = {
    "日", "一", "二", "三",
    "四", "五", "六"
};
#endif

//Date _solar, _lunar, gan, zhi, gan2, zhi2, _lunar2;

//int ymonth[Nyear];	/* number of lunar months in the years */
//int yday[Nyear];	/* number of lunar days in the years */
//int mday[Nmonth+1];	/* number of days in the months of the lunar year */
int jieAlert;		/* if there is uncertainty in JieQi calculation */

int	showHZ = 0;			/* output in hanzi */
char	*progname;


long Solar2Day(SSLunarSimpleDate *d);
long Solar2Day1(SSLunarSimpleDate *d);
long Lunar2Day(LibLunarContext *ctx, SSLunarSimpleDate *d);

void Day2Lunar(LibLunarContext *ctx, long offset);
void Day2Solar(LibLunarContext *ctx, long offset);

int make_yday(LibLunarContext *ctx);
int make_mday(LibLunarContext *ctx, int year);
int GZcycle();

void	CalGZ();
int	JieDate(), JieDate();
void	Report(SSLunarSimpleDate *, SSLunarSimpleDate *, SSLunarSimpleDate *), ReportE();
void ReportGB(SSLunarSimpleDate *solar, SSLunarSimpleDate *lunar, SSLunarSimpleDate *lunar2);
void	usage(), Error();
int CmpDate(int month1, int day1, int month2, int day2);

struct LibLunarContext * createLunarContext()
{
    struct LibLunarContext *ctx;
    ctx = malloc(sizeof(struct LibLunarContext));
    if (ctx == NULL)
        return NULL;
    memset(ctx, 0, sizeof(*ctx));
    return ctx;
}

void freeLunarContext(struct LibLunarContext *context)
{
    free(context);
}

SSLunarSimpleDate *getSolarDate(LibLunarContext *ctx)
{
    if (ctx != NULL)
        return &ctx->_solar;
    return NULL;
}

SSLunarSimpleDate *getLunarDate(LibLunarContext *ctx)
{
    if (ctx != NULL)
        return &ctx->_lunar;
    return NULL;
}

int libLunarCheckYearRange(int year)
{
    if (year >= VALID_MIN_YEAR && year <= VALID_MAX_YEAR)
        return 1;
    else
        return 0;
}

void Solar2Lunar(struct LibLunarContext *ctx,
                 SSLunarSimpleDate *solar)
{
    
    long offset;
    
    if (ctx == NULL) {
        fprintf(stderr, "Soloar2Lunar: ctx pointer cannot be NULL");
        return;
    }

    if (!libLunarCheckYearRange(solar->year)) {
            fprintf(stderr, "Solar2Lunar: the year provide exceeds lib's ablility.");
            return;
    }
            
    
    offset = Solar2Day(solar);
    solar->weekday = (offset + SolarFirstDate.weekday) % 7;
    
    /* A lunar day begins at 11 p.m. */
    if (solar->hour == 23)
        offset++;
    
    Day2Lunar(ctx, offset);
    ctx->_lunar.hour = solar->hour;
    CalGZ(offset, &ctx->_lunar, &ctx->_gan, &ctx->_zhi);
    
    jieAlert = JieDate(solar, &ctx->_lunar2);
    ctx->_lunar2.day = ctx->_lunar.day;
    ctx->_lunar2.hour = ctx->_lunar.hour;
    CalGZ(offset, &ctx->_lunar2, &ctx->_gan2, &ctx->_zhi2);
}


void Lunar2Solar(struct LibLunarContext *ctx, SSLunarSimpleDate *lunar)
{
    long offset;
    int adj;

    if (ctx == NULL) {
        fprintf(stderr, "Lunar2Solar: ctx pointer cannot be NULL");
        return;
    }
    
    /* A solar day begins at 12 a.m. */
    adj = (ctx->_lunar.hour == 23)? -1 : 0;
    offset = Lunar2Day(ctx, &ctx->_lunar);
    ctx->_solar.weekday = (offset+ adj + SolarFirstDate.weekday) % 7;
    Day2Solar(ctx, offset + adj);
    ctx->_solar.hour = lunar->hour;
    CalGZ(offset, lunar, &ctx->_gan, &ctx->_zhi);
    
    jieAlert = JieDate(&ctx->_solar, &ctx->_lunar2);
    ctx->_lunar2.day = lunar->day;
    ctx->_lunar2.hour = lunar->hour;
    CalGZ(offset, &ctx->_lunar2, &ctx->_gan2, &ctx->_zhi2);
}


#define	LeapYear(y)	(((y)%4==0) && ((y)%100!=0) || ((y)%400==0))
#define BYEAR		1201
/* BYEAR % 4 == 1  and BYEAR % 400 == 1 for easy calculation of leap years */
/* assert(BYEAR <= SolarFirstDate.year) */

long Solar2Day(SSLunarSimpleDate *d)

{
    return (Solar2Day1(d) - Solar2Day1(&SolarFirstDate));
}


/* Compute the number of days from the Solar date BYEAR.1.1 */
long Solar2Day1(SSLunarSimpleDate *d)
{
    long offset, delta;
    int i;
    
    delta = d->year - BYEAR;
    if (delta<0) Error("Internal error: pick a larger constant for BYEAR.");
    offset = delta * 365 + delta / 4 - delta / 100 + delta / 400;
    for (i=1; i< d->month; i++)
    	offset += daysInSolarMonth[i];
    if ((d->month > 2) && LeapYear(d->year))
        offset++;
    offset += d->day - 1;
    
    if ((d->month == 2) && LeapYear(d->year))
    {
        if (d->day > 29) Error("Day out of range.");
    }
    else if (d->day > daysInSolarMonth[d->month]) Error("Day out of range.");
    return offset;
}


/* Compute offset days of a lunar date from the beginning of the table */
long Lunar2Day(LibLunarContext *ctx, SSLunarSimpleDate *d)
{
    long offset = 0;
    int year, i, m, leapMonth;
    
    year = d->year - LunarFirstDate.year;
    for (i=0; i<year; i++)
        offset += ctx->_yday[i];
    
    leapMonth = make_mday(ctx, year);
    if ((d->leap) && (leapMonth!=d->month))
    {
        printf("%d is not a leap month in year %d.\n", d->month, d->year);
        exit(1);
    }
    for (m=1; m<d->month; m++)
        offset += ctx->_mday[m];
    if (leapMonth &&
        ((d->month>leapMonth) || (d->leap && (d->month==leapMonth))))
        offset += ctx->_mday[m++];
    offset += d->day - 1;
    
    if (d->day > ctx->_mday[m]) Error("Day out of range.");
    
    return offset;
}


void Day2Lunar(LibLunarContext *ctx,
               long offset)
{
    int i, m, nYear, leapMonth;
    
    SSLunarSimpleDate *d = &ctx->_lunar;
    
    nYear = make_yday(ctx);
    for (i = 0; i < nYear && offset > 0; i++)
        offset -= ctx->_yday[i];
    // reduce each year day, try to get which year of current year is.
    
    /* if the year less zero, means that year not really come year,  */
    if (offset<0)
        offset += ctx->_yday[--i];
    
    if (i >= Nyear) Error("Year out of range.");
    
    /* so, the year is the current year + i */
    d->year = i + LunarFirstDate.year;
    
    leapMonth = make_mday(ctx, i);
    for (m=1; m<=Nmonth && offset>0; m++)
        offset -= ctx->_mday[m];
    
    if (offset<0)
        offset += ctx->_mday[--m];
    
    d->leap = 0;	/* don't know leap or not yet */
    
    if (leapMonth>0)	/* has leap month */
    {
        /* if preceeding month number is the leap month,
         this month is the actual extra leap month */
        d->leap = (leapMonth == (m - 1));
        
        /* month > leapMonth is off by 1, so adjust it */
        if (m > leapMonth) --m;
    }
    
    d->month = m;
    d->day = offset + 1;
}


void Day2Solar(LibLunarContext *ctx,
               long offset)
{
    int	i, m, days;
    SSLunarSimpleDate *d = &ctx->_solar;
    
    /* offset is the number of days from SolarFirstDate */
    offset -= Solar2Day(&LunarFirstDate);  /* the argument is negative */
    /* offset is now the number of days from SolarFirstDate.year.1.1 */
    
    for (i=SolarFirstDate.year;
         (i<SolarFirstDate.year+Nyear) && (offset > 0);	 i++)
        offset -= 365 + LeapYear(i);
    if (offset<0)
    {
        --i; 	/* LeapYear is a macro */
        offset += 365 + LeapYear(i);
    }
    if (i==(SolarFirstDate.year + Nyear)) Error("Year out of range.");
    d->year = i;
    
    /* assert(offset<(365+LeapYear(i))); */
    for (m=1; m<=12; m++)
    {
        days = daysInSolarMonth[m];
        if ((m==2) && LeapYear(i))	/* leap February */
            days++;
        if (offset<days)
        {
            d->month = m;
            d->day = offset + 1;
            return;
        }
        offset -= days;
    }
}


int GZcycle(int g, int z)
{
    int gz;
    
    for (gz = z; gz % 10 != g && gz < 60; gz += 12) ;
    if (gz >= 60) printf("internal error\n");
    return gz+1;
}


void CalGZ(long offset, SSLunarSimpleDate *d, SSLunarSimpleDate *g, SSLunarSimpleDate *z)
{
    int	year, month;
    
    year = d->year - LunarFirstDate.year;
    month = year * 12 + d->month - 1;   /* leap months do not count */
    
    g->year = (GanFirstDate.year + year) % 10;
    z->year = (ZhiFirstDate.year + year) % 12;
    g->month = (GanFirstDate.month + month) % 10;
    z->month = (ZhiFirstDate.month + month) % 12;
    g->day = (GanFirstDate.day + offset) % 10;
    z->day = (ZhiFirstDate.day + offset) % 12;
    z->hour = ((d->hour + 1) / 2) % 12;
    g->hour = (g->day * 12 + z->hour) % 10;
}


void Error(s)
char	*s;
{
    printf("libLunar:%s\n",s);
    assert(-1);
    //    exit(1);
}


/* Compare two dates and return <,=,> 0 if the 1st is <,=,> the 2nd */
int CmpDate(int month1, int day1,int  month2,int day2)
{
    if (month1!=month2) return(month1-month2);
    if (day1!=day2) return(day1-day2);
    return(0);
}


/*
 Given a solar date, find the "lunar" date for the purpose of
 calculating the "4-columns" by taking jie into consideration.
 */
int JieDate(SSLunarSimpleDate *ds, SSLunarSimpleDate *dl)
{
    int m, flag;
    
    if (ds->month==1)
    {
        flag = CmpDate(ds->month, ds->day,
                       1, fest[ds->year - SolarFirstDate.year - 1][11]);
        if (flag<0) dl->month = 11;
        else if (flag>0) dl->month = 12;
        dl->year = ds->year - 1;
        return(flag==0);
    }
    for (m=2; m<=12; m++)
    {
        flag = CmpDate(ds->month, ds->day,
                       m, fest[ds->year - SolarFirstDate.year][m-2]);
        if (flag==0) m++;
        if (flag<=0) break;
    }
    dl->month = (m-2) % 12;
    dl->year = ds->year;
    if ((dl->month)==0)
    {
        dl->year = ds->year - 1;
        dl->month = 12;
    }
    return(flag==0);
}


/* Compute the number of days in each lunar year in the table */
int make_yday(LibLunarContext *ctx)
{
    int year, i, leap;
    long code;
    
    for (year = 0; year < Nyear; year++)
    {
        code = yearInfo[year];
        leap = code & 0xf;
        ctx->_yday[year] = 0;
        if (leap != 0)
        {
            i = (code >> 16) & 0x1;
            ctx->_yday[year] += moon[i];
            /* Big month or small month.... got it. Leap month only
             * have two day, big month or small month. */
        }
        code >>= 4;
        for (i = 0; i < Nmonth-1; i++)
        {
            /* 12 months. */
            ctx->_yday[year] += moon[code&0x1];
            code >>= 1;
        }
        ctx->_ymonth[year] = 12;
        if (leap != 0) ctx->_ymonth[year]++;
    }
    return Nyear;
}


/* Compute the days of each month in the given lunar year */
int make_mday(LibLunarContext *ctx, int year)
{
    int i, leapMonth;
    long code;
    
    code = yearInfo[year];
    leapMonth = code & 0xf;
    /* leapMonth == 0 means no leap month */
    code >>= 4;
    if (leapMonth == 0)
    {
        ctx->_mday[Nmonth] = 0;
        for (i = Nmonth-1; i >= 1; i--)
        {
            ctx->_mday[i] = moon[code&0x1];
            code >>= 1;
        }
    }
    else
    {
        /*
         There is a leap month (run4 yue4) L in this year.
         mday[1] contains the number of days in the 1-st month;
         mday[L] contains the number of days in the L-th month;
         mday[L+1] contains the number of days in the L-th leap month;
         mday[L+2] contains the number of days in the L+1 month, etc.
         
         cf. yearInfo[]: info about the leap month is encoded differently.
         */
        i = (yearInfo[year] >> 16) & 0x1;
        ctx->_mday[leapMonth+1] = moon[i];
        
        for (i = Nmonth; i >= 1; i--)
        {
            if (i == leapMonth+1)
                i--;
            ctx->_mday[i] = moon[code&0x1];
            code >>= 1;
        }
    }
    return leapMonth;
}


void Report(SSLunarSimpleDate *solar, SSLunarSimpleDate *lunar, SSLunarSimpleDate *lunar2)
{
    if (showHZ)
        ReportGB(solar, lunar, lunar2);
    else
        ReportE(solar, lunar, lunar2);
}

#if 0
void ReportGB(Date *solar, Date *lunar, Date *lunar2)
{
    printf("%s%d%s%2d%s%2d%s%2d%s%s%s\n", "阳历：　",
           solar->year, "年", solar->month, "月", solar->day,
           "日", solar->hour, "时　",
           "星期", weekdayGB[solar->weekday]);
    printf("%s%d%s%s%2d%s%2d%s%s%s%s%s\n", "阴历：　",
           lunar->year, "年", (lunar->leap? "闰":""),
           lunar->month, "月", lunar->day, "日",
           ZhiGB[zhi.hour], "时　",
           "生肖属", ShengXiaoGB[zhi.year]);
    printf("%s%s%s%s%s%s%s%s%s%s%s%s%s\n", "干支：　",
           GanGB[gan.year], ZhiGB[zhi.year], "年　",
           GanGB[gan.month], ZhiGB[zhi.month], "月　",
           GanGB[gan.day], ZhiGB[zhi.day], "日　",
           GanGB[gan.hour], ZhiGB[zhi.hour], "时　");
    printf("%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
           "用四柱神算推算之时辰八字：　",
           GanGB[gan2.year], ZhiGB[zhi2.year], "年　",
           GanGB[gan2.month], ZhiGB[zhi2.month], "月　",
           GanGB[gan2.day], ZhiGB[zhi2.day], "日　",
           GanGB[gan2.hour], ZhiGB[zhi2.hour], "时　");
    if (jieAlert)
    {
        printf("* %s, %s\n", "是日为节",
               "月柱可能要修改");
        if (lunar2->month==1)
            printf("* %s\n", "年柱亦可能要修改");
        printf("* %s\n", "请查有节气时间之万年历");
    }
}


void ReportE(Date *solar, Date *lunar, Date *lunar2)
{
    printf("Solar : %d.%d.%d.%d\t%s\n", solar->year, solar->month, solar->day,
           solar->hour, weekday[solar->weekday]);
    printf("Lunar : %d.%d%s.%d.%d\tShengXiao: %s\n",
           lunar->year, lunar->month, (lunar->leap?"Leap":""), lunar->day,
           lunar->hour, ShengXiao[zhi.year] );
    printf("GanZhi: %s-%s.%s-%s.%s-%s.%s-%s\n",
           Gan[gan.year], Zhi[zhi.year], Gan[gan.month], Zhi[zhi.month],
           Gan[gan.day], Zhi[zhi.day], Gan[gan.hour], Zhi[zhi.hour]);
    printf("        (GanZhi Order)\t%d-%d.%d-%d.%d-%d.%d-%d\n",
           gan.year+1, zhi.year+1, gan.month+1, zhi.month+1,
           gan.day+1, zhi.day+1, gan.hour+1, zhi.hour+1);
    printf("        (JiaZi Cycle)\t%d.%d.%d.%d\n\n",
           GZcycle(gan.year, zhi.year), GZcycle(gan.month, zhi.month),
           GZcycle(gan.day, zhi.day), GZcycle(gan.hour, zhi.hour));
    printf("BaZi (8-characters) according to 'Four Column Calculation':\n");
    printf("        %s-%s.%s-%s.%s-%s.%s-%s\n",
           Gan[gan2.year], Zhi[zhi2.year], Gan[gan2.month], Zhi[zhi2.month],
           Gan[gan2.day], Zhi[zhi2.day], Gan[gan2.hour], Zhi[zhi2.hour]);
    printf("        (GanZhi Order)\t%d-%d.%d-%d.%d-%d.%d-%d\n",
           gan2.year+1, zhi2.year+1, gan2.month+1, zhi2.month+1,
           gan2.day+1, zhi2.day+1, gan2.hour+1, zhi2.hour+1);
    printf("        (JiaZi Cycle)\t%d.%d.%d.%d\n\n",
           GZcycle(gan2.year, zhi2.year), GZcycle(gan2.month, zhi2.month),
           GZcycle(gan2.day, zhi2.day), GZcycle(gan2.hour, zhi2.hour));
    if (jieAlert)
    {
        printf("* The month column may need adjustment because the date falls on a jie.\n");
        if (lunar2->month==1)
            printf("* The day column may need adjustment, too.\n");
        printf("* Please consult a detailed conversion table.\n");
    }
}
#else
void ReportE(SSLunarSimpleDate *solar, SSLunarSimpleDate *lunar, SSLunarSimpleDate *lunar2) {}
void ReportGB(SSLunarSimpleDate *solar, SSLunarSimpleDate *lunar, SSLunarSimpleDate *lunar2) {}
#endif





