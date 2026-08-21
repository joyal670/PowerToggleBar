import Foundation
import CoreGraphics
// Usage: disp get   -> prints current brightness 0.0-1.0
//        disp set X -> sets brightness to X
guard let h = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_NOW),
      let gp = dlsym(h, "DisplayServicesGetBrightness"),
      let sp = dlsym(h, "DisplayServicesSetBrightness") else { print("0.5"); exit(0) }
typealias GetFn = @convention(c)(UInt32, UnsafeMutablePointer<Float>) -> Int32
typealias SetFn = @convention(c)(UInt32, Float) -> Int32
let get = unsafeBitCast(gp, to: GetFn.self)
let set = unsafeBitCast(sp, to: SetFn.self)
let did = CGMainDisplayID()
let args = CommandLine.arguments
if args.count >= 3, args[1] == "set", let v = Float(args[2]) {
  _ = set(did, max(0.0, min(1.0, v)))
} else {
  var cur: Float = 0.5
  _ = get(did, &cur)
  print(cur)
}
