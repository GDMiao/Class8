//
//  DBConfig.h
//  FMDBDome
//
//  Created by chuliangliang on 15/7/18.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#ifndef FMDBDome_DBConfig_h
#define FMDBDome_DBConfig_h

#define DATABASE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]stringByAppendingString:@"/C8ChatDB.sqlite"]
//FMDB
#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

#endif
