#include <proxies/common.h>
#include <proxies/interface.h>

#include "lib.h"
#include "needham_type.h"

void print_buffer_proxy(const unsigned char * buf, int len)
{
  mute();
  print_buffer(buf, len);
  unmute();
}

// Teach csec something about field offsets
void struct_properties()
{
  msg_t dummy;
  void * p1 = &dummy.msg.msg3.nonce;
  void * p2 = &dummy;
  if(p1 - p2 < 0) {
    printf("impossible");
    exit(1);
  }
  if(p1 - p2 > sizeof(dummy) - sizeof(dummy.msg.msg3.nonce)) {
    printf("impossible");
    exit(1);
  }

  p1 = &dummy.msg.msg1.nonce;
  if(p1 - p2 < 0) {
    printf("impossible");
    exit(1);
  }
  if(p1 - p2 > sizeof(dummy) - sizeof(dummy.msg.msg1.nonce)) {
    printf("impossible");
    exit(1);
  }

  p1 = &dummy.msg.msg2.nonce1;
  if(p1 - p2 < 0) {
    printf("impossible");
    exit(1);
  }
  if(p1 - p2 > sizeof(dummy) - sizeof(dummy.msg.msg2.nonce1)) {
    printf("impossible");
    exit(1);
  }

  p1 = &dummy.msg.msg2.nonce2;
  if(p1 - p2 < 0) {
    printf("impossible");
    exit(1);
  }
  if(p1 - p2 > sizeof(dummy) - sizeof(dummy.msg.msg2.nonce2)) {
    printf("impossible");
    exit(1);
  }
}
