// Autogenerated from Pigeon (v0.1.15), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class SearchReply;
@class SearchRequest;

@interface SearchReply : NSObject
@property(nonatomic, copy, nullable) NSString * result;
@end

@interface SearchRequest : NSObject
@property(nonatomic, copy, nullable) NSString * query;
@end

@protocol Api
-(nullable SearchReply *)search:(SearchRequest*)input error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void ApiSetup(id<FlutterBinaryMessenger> binaryMessenger, id<Api> _Nullable api);

NS_ASSUME_NONNULL_END