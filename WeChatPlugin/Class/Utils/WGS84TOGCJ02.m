//
//  WGS84TOGCJ02.m
//  Goddess
//
//  Created by kuxing on 14-8-4.
//  Copyright (c) 2014年 yangyanan. All rights reserved.
//

#import "WGS84TOGCJ02.h"
const double a = 6378245.0;
const double ee = 0.00669342162296594323;
const double pi = 3.14159265358979324;

@implementation WGS84TOGCJ02
    
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc
{
    CLLocationCoordinate2D adjustLoc;
    if([self isLocationOutOfChina:wgsLoc]){
        adjustLoc = wgsLoc;
    }else{
        double adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        double adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        double radLat = wgsLoc.latitude / 180.0 * pi;
        double magic = sin(radLat);
        magic = 1 - ee * magic * magic;
        double sqrtMagic = sqrt(magic);
        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
        adjustLoc.latitude = wgsLoc.latitude + adjustLat;
        adjustLoc.longitude = wgsLoc.longitude + adjustLon;
    }
    return adjustLoc;
}

//判断是不是在中国
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location
{
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

+ (double)transformLatWithX:(double)x withY:(double)y
{
    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    lat += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * pi) + 3320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return lat;
}

+ (double)transformLonWithX:(double)x withY:(double)y
{
    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    lon += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return lon;
}
    
#define LAT_OFFSET_0(x,y) -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
#define LAT_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_2 (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_3 (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0

#define LON_OFFSET_0(x,y) 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
#define LON_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_2 (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_3 (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0

#define RANGE_LON_MAX 137.8347
#define RANGE_LON_MIN 72.004
#define RANGE_LAT_MAX 55.8271
#define RANGE_LAT_MIN 0.8293
// jzA = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
#define jzA 6378245.0
#define jzEE 0.00669342162296594323


+ (double)transformLat:(double)x bdLon:(double)y
{
	double ret = LAT_OFFSET_0(x, y);
	ret += LAT_OFFSET_1;
	ret += LAT_OFFSET_2;
	ret += LAT_OFFSET_3;
	return ret;
}

+ (double)transformLon:(double)x bdLon:(double)y
{
	double ret = LON_OFFSET_0(x, y);
	ret += LON_OFFSET_1;
	ret += LON_OFFSET_2;
	ret += LON_OFFSET_3;
	return ret;
}

+ (BOOL)outOfChina:(double)lat bdLon:(double)lon
{
	if (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX)
		return true;
	if (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX)
		return true;
	return false;
}

+ (CLLocationCoordinate2D)gcj02Encrypt:(double)ggLat bdLon:(double)ggLon
{
	CLLocationCoordinate2D resPoint;
	double mgLat;
	double mgLon;
	if ([self outOfChina:ggLat bdLon:ggLon]) {
		resPoint.latitude = ggLat;
		resPoint.longitude = ggLon;
		return resPoint;
	}
	double dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
	double dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
	double radLat = ggLat / 180.0 * M_PI;
	double magic = sin(radLat);
	magic = 1 - jzEE * magic * magic;
	double sqrtMagic = sqrt(magic);
	dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
	dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
	mgLat = ggLat + dLat;
	mgLon = ggLon + dLon;
	
	resPoint.latitude = mgLat;
	resPoint.longitude = mgLon;
	return resPoint;
}

+ (CLLocationCoordinate2D)gcj02Decrypt:(double)gjLat gjLon:(double)gjLon {
	CLLocationCoordinate2D  gPt = [self gcj02Encrypt:gjLat bdLon:gjLon];
	double dLon = gPt.longitude - gjLon;
	double dLat = gPt.latitude - gjLat;
	CLLocationCoordinate2D pt;
	pt.latitude = gjLat - dLat;
	pt.longitude = gjLon - dLon;
	return pt;
}

+ (CLLocationCoordinate2D)bd09Decrypt:(double)bdLat bdLon:(double)bdLon
{
	CLLocationCoordinate2D gcjPt;
	double x = bdLon - 0.0065, y = bdLat - 0.006;
	double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
	double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
	gcjPt.longitude = z * cos(theta);
	gcjPt.latitude = z * sin(theta);
	return gcjPt;
}

+(CLLocationCoordinate2D)bd09Encrypt:(double)ggLat bdLon:(double)ggLon
{
	CLLocationCoordinate2D bdPt;
	double x = ggLon, y = ggLat;
	double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
	double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
	bdPt.longitude = z * cos(theta) + 0.0065;
	bdPt.latitude = z * sin(theta) + 0.006;
	return bdPt;
}


+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location
{
	return [self gcj02Encrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location
{
	return [self gcj02Decrypt:location.latitude gjLon:location.longitude];
}


+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location
{
	CLLocationCoordinate2D gcj02Pt = [self gcj02Encrypt:location.latitude
												  bdLon:location.longitude];
	return [self bd09Encrypt:gcj02Pt.latitude bdLon:gcj02Pt.longitude] ;
}

+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location
{
	return  [self bd09Encrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location
{
	return [self bd09Decrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location
{
	CLLocationCoordinate2D gcj02 = [self bd09ToGcj02:location];
	return [self gcj02Decrypt:gcj02.latitude gjLon:gcj02.longitude];
}
@end
