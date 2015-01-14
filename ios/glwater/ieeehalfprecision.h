
//
//  ieeehalfprecision.h
//  glwater
//
//  Created by maruojie on 15/1/14.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#ifndef glwater_ieeehalfprecision_h
#define glwater_ieeehalfprecision_h

extern int singles2halfp(void *target, void *source, int numel);
extern int doubles2halfp(void *target, void *source, int numel);
extern int halfp2singles(void *target, void *source, int numel);
extern int halfp2doubles(void *target, void *source, int numel);

#endif
