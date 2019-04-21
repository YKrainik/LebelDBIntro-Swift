//
//  Wrapper.cpp
//  LevelDBIntro
//
//  Created by AP Yury Krainik on 4/15/19.
//  Copyright © 2019 AP Yury Krainik. All rights reserved.
//

#include "Wrapper.hpp"
#include <db.h>

void* c_creatLeveldb(char* path) {
	leveldb::DB *_db;
	leveldb::Options options;
	options.create_if_missing = true;
	std::string string = path;
	leveldb::DB::Open(options, string, &_db);

	return _db;
}

void c_closeLeveldb(void* leveldb) {
	leveldb::DB *_db = (leveldb::DB *)leveldb;
	if (_db) {
		delete _db;
		leveldb = NULL;
	}
}

void c_leveldbSetValue(void* leveldb, struct _CString_ key, struct _CString_ value) {
	leveldb::Slice keySlice = leveldb::Slice(key.basePtr, key.lenght);
	leveldb::Slice valueSlice = leveldb::Slice(value.basePtr, value.lenght);
	leveldb::DB *_db = (leveldb::DB *)leveldb;
	leveldb::WriteOptions writeOption;
	leveldb::Status status = _db->Put(writeOption, keySlice, valueSlice);
	if (status.ok() != true) {
		printf("%s:%d c_leveldbSetValue error", __FILE__, __LINE__);
	}
}

struct _CString_ c_leveldbGetValue(void* leveldb, struct _CString_* key) {
	leveldb::Slice keySlice = leveldb::Slice(key->basePtr, key->lenght);
	std::string valueString;
	leveldb::DB *_db = (leveldb::DB *)leveldb;
	leveldb::ReadOptions readOptions;
	leveldb::Status status = _db->Get(readOptions, keySlice, &valueString);
	if (!status.ok()) {
		printf("%s:%d c_leveldbSetValue error", __FILE__, __LINE__);
	}
	long size = valueString.size();
	char* p = (char*)malloc(size * sizeof(char));
	std::strcpy(p, valueString.c_str());
	_CString_ result;
	result.basePtr = p;
	result.lenght = size;
	return result;
}

void c_leveldbDeleteValue(void* leveldb, struct _CString_ key) {
	leveldb::Slice keySlice = leveldb::Slice(key.basePtr, key.lenght);
	leveldb::DB *_db = (leveldb::DB *)leveldb;
	leveldb::WriteOptions writeOption;
	leveldb::Status status = _db->Delete(writeOption, keySlice);
	if (!status.ok()) {
		printf("%s:%d c_leveldbSetValue error", __FILE__, __LINE__);
	}
}

void* c_createIterator(void* leveldb) {
	leveldb::DB *_db = (leveldb::DB *)leveldb;
	leveldb::ReadOptions readOptions;
	return _db->NewIterator(readOptions);
}

void c_iteratorSeekToFirst(void* iterator) {
	leveldb::Iterator *_iterator = (leveldb::Iterator *)iterator;
	_iterator->SeekToFirst();
}

bool c_iteratorIsValid(void* iterator) {
	leveldb::Iterator *_iterator = (leveldb::Iterator *)iterator;
	return _iterator->Valid();
}

void c_iteratorNext(void* iterator) {
	leveldb::Iterator *_iterator = (leveldb::Iterator *)iterator;
	_iterator->Next();
}

struct _CString_ c_iteratorGetValue(void* iterator) {
	leveldb::Iterator *_iterator = (leveldb::Iterator *)iterator;
	leveldb::Slice valueSlice = _iterator->value();

	long size = valueSlice.size();
	char* p = (char*)malloc(size * sizeof(char));
	std::strcpy(p, valueSlice.data());
	_CString_ result;
	result.basePtr = p;
	result.lenght = size;
	return result;
}

struct KeyValue c_iteratorGetKeyValue(void* iterator) {
	leveldb::Iterator *_iterator = (leveldb::Iterator *)iterator;
	leveldb::Slice keySlice = _iterator->key();
	leveldb::Slice valueSlice = _iterator->value();

	long keySize = keySlice.size();
	char* keyP = (char*)malloc(keySize * sizeof(char));
	std::strcpy(keyP, keySlice.data());
	_CString_ keyResult;
	keyResult.basePtr = keyP;
	keyResult.lenght = keySize;

	long valueSize = valueSlice.size();
	char* valueP = (char*)malloc(valueSize * sizeof(char));
	std::strcpy(valueP, valueSlice.data());
	_CString_ valueResult;
	valueResult.basePtr = valueP;
	valueResult.lenght = valueSize;

	KeyValue result;
	result.key = keyResult;
	result.value = valueResult;

	return result;
}

void c_iteratorFree(void* iterator) {
	leveldb::Iterator *_iterator = (leveldb::Iterator *)iterator;
	delete _iterator;
}

void c_FreeCString(struct _CString_* string) {
	free(string->basePtr);
	string->basePtr = NULL;
}
