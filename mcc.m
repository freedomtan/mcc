#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

kern_return_t MCCUserClientOpen(io_connect_t* conn) {
  kern_return_t result;
  mach_port_t mainPort;
  io_service_t service;

  result = IOMainPort(MACH_PORT_NULL, &mainPort);

  CFMutableDictionaryRef matchingDictionary = IOServiceMatching("AppleT8103MemCacheController");
  NSLog(@"dict matched %@", matchingDictionary);
  service = IOServiceGetMatchingService(mainPort, matchingDictionary);
  NSLog(@"service matched %d", service);

  result = IOServiceOpen(service, mach_task_self(), 0, conn);
  if (result != kIOReturnSuccess) {
    printf("Error: IOServiceOpen() = 0x%08x\n", result);
    return result;
  }

  return kIOReturnSuccess;
}

int main(int argc, char* argv[]) {
  io_connect_t connection;
  MCCUserClientOpen(&connection);

  // 2 is what specified in AppleMCCUserClient::externalMethod()
  // I guess there are two separate system caches
  uint64_t caches[2];
  uint32_t cacheCount = 2;

  // 0x11 is to call AppleMemCacheController::getCacheSize()
  kern_return_t kret = IOConnectCallScalarMethod(connection, 0x11, NULL, 0, caches, &cacheCount);
  if (kret) {
    NSLog(@"failed to get cache count, ret = 0x%08x", kret);
    exit(-1);
  }

  NSLog(@"cache count = 0x%x", cacheCount);
  NSLog(@"cache size = 0x%llx", caches[0]);
  NSLog(@"cache size = 0x%llx", caches[1]);

  // totalCacheSize = 16 MiB on M1 MacBook Pro 2020
  // the number matches AnandTech's number
  uint64_t totalCacheSize = 0;
  for (int i=0; i < cacheCount; i++) {
    totalCacheSize += caches[0];
  }
  NSLog(@"total cache size = 0x%llx (%llu)", totalCacheSize, totalCacheSize);

  exit(0);
}
