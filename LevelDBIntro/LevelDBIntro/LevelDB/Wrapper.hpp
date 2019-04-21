//
//  Wrapper.hpp
//  LevelDBIntro
//
//  Created by AP Yury Krainik on 4/15/19.
//  Copyright © 2019 AP Yury Krainik. All rights reserved.
//

#ifndef Wrapper_hpp
#define Wrapper_hpp

#include <stdbool.h>

struct _CString_ {
	char* basePtr;
	long lenght;
};

typedef struct KeyValue {
	struct _CString_ key;
	struct _CString_ value;
} pair;

#ifdef __cplusplus
extern "C" {
#endif
	void* c_creatLeveldb(char* path);
	void c_closeLeveldb(void* leveldb);
	void c_leveldbSetValue(void* leveldb, struct _CString_ key, struct _CString_ value);
	struct _CString_ c_leveldbGetValue(void* leveldb, struct _CString_* key);
	void c_leveldbDeleteValue(void* leveldb, struct _CString_ key);

	void* c_createIterator(void* leveldb);
	void c_iteratorSeekToFirst(void* iterator);
	bool c_iteratorIsValid(void* iterator);
	void c_iteratorNext(void* iterator);
	struct _CString_ c_iteratorGetValue(void* iterator);
	struct KeyValue c_iteratorGetKeyValue(void* iterator);
	void c_iteratorFree(void* iterator);

	void c_FreeCString(struct _CString_* string);
#ifdef __cplusplus
}
#endif

#endif /* Wrapper_hpp */
