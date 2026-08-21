import Foundation
// Usage: kb get   ->  prints current keyboard backlight (0.0-1.0)
//        kb set X ->  sets keyboard backlight to X
guard dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_NOW) != nil,
      let cls = NSClassFromString("KeyboardBrightnessClient") as? NSObject.Type else { print("0"); exit(0) }
let client = cls.init()
let kbID: UInt64 = 1
let args = CommandLine.arguments
func getB() -> Float {
  let sel = NSSelectorFromString("brightnessForKeyboard:")
  guard client.responds(to: sel) else { return 0 }
  typealias F = @convention(c)(AnyObject, Selector, UInt64) -> Float
  return unsafeBitCast(client.method(for: sel), to: F.self)(client, sel, kbID)
}
func setB(_ v: Float) {
  let sel = NSSelectorFromString("setBrightness:forKeyboard:")
  guard client.responds(to: sel) else { return }
  typealias F = @convention(c)(AnyObject, Selector, Float, UInt64) -> Bool
  _ = unsafeBitCast(client.method(for: sel), to: F.self)(client, sel, v, kbID)
}
if args.count >= 2, args[1] == "set", args.count >= 3, let v = Float(args[2]) { setB(v) }
else { print(getB()) }
