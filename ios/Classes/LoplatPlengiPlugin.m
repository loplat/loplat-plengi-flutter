#import "LoplatPlengiPlugin.h"
#if __has_include(<loplat_plengi/loplat_plengi-Swift.h>)
#import <loplat_plengi/loplat_plengi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "loplat_plengi-Swift.h"
#endif

@implementation LoplatPlengiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLoplatPlengiPlugin registerWithRegistrar:registrar];
}
@end
