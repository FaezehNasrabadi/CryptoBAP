
#include "rpc-enc.h"
#include "lib.h"

#include <polarssl/net.h>

#include <proxies/common.h>
#include <proxies/interface.h>
#include <proxies/system_proxies.h>

#include <string.h>

int net_recv_proxy( void *ctx, unsigned char *buf, int len )
{
  mute();
  int ret = net_recv(ctx, buf, len);
  unmute();

  mute();
  if(ret != len)
  {
    fail("read_proxy: ret != len not handled yet, ret = %d, len = %d", ret, len);
  }
  unmute();

  ret = len;

  input("msg", ret);
  store_buf((unsigned char*) buf);

  return ret;
}

int net_send_proxy( void *ctx, unsigned char *buf, int len )
{
  mute();
  int ret = net_send(ctx, buf, len);
  unmute();

  mute();
  if(ret != len)
  {
    fail("write_proxy: ret != len not handled yet");
  }
  unmute();

  ret = len;

  load_buf(buf, ret, "msg");
  output();

  return ret;
}

/**
 * \brief          Initiate a TCP connection with host:port
 *
 * \param fd       Socket to use
 * \param host     Host to connect to
 * \param port     Port to connect to
 *
 * \return         0 if successful, or one of:
 *                      POLARSSL_ERR_NET_SOCKET_FAILED,
 *                      POLARSSL_ERR_NET_UNKNOWN_HOST,
 *                      POLARSSL_ERR_NET_CONNECT_FAILED
 */
int net_connect_proxy( int *fd, const char *host, int port )
{
  mute();
  int ret = net_connect(fd, host, port);
  unmute();

  load_buf(host, strlen_proxy(host), "");
  output();
  load_buf(&port, sizeof(port), "");
  output();

  // Let the attacker decide what this function returns.
  input("net_connect_result", sizeof(ret));
  store_buf(&ret);

  return ret;
}


/**
 * \brief          Create a listening socket on bind_ip:port.
 *                 If bind_ip == NULL, all interfaces are binded.
 *
 * \param fd       Socket to use
 * \param bind_ip  IP to bind to, can be NULL
 * \param port     Port number to use
 *
 * \return         0 if successful, or one of:
 *                      POLARSSL_ERR_NET_SOCKET_FAILED,
 *                      POLARSSL_ERR_NET_BIND_FAILED,
 *                      POLARSSL_ERR_NET_LISTEN_FAILED
 */
int net_bind_proxy( int *fd, const char *bind_ip, int port )
{
  mute();
  int ret = net_bind(fd, bind_ip, port);
  unmute();

  SymN("socket", 0);
  Nondet();
  assume_intype("bitstring");
  size_t len = sizeof(*fd);
  assume_len(&len, false, sizeof(len));
  store_buf(fd);

  load_buf(bind_ip, strlen_proxy(bind_ip), "");
  output();
  load_buf(&port, sizeof(port), "");
  output();

  // Let the attacker decide what this function returns.
  input("net_bind_result", sizeof(ret));
  store_buf(&ret);

  return ret;
}



/**
 * \brief           Accept a connection from a remote client
 *
 * \param bind_fd   Relevant socket
 * \param client_fd Will contain the connected client socket
 * \param client_ip Will contain the client IP address
 *
 * \return          0 if successful, POLARSSL_ERR_NET_ACCEPT_FAILED, or
 *                  POLARSSL_ERR_NET_WOULD_BLOCK is bind_fd was set to
 *                  non-blocking and accept() is blocking.
 */
int net_accept_proxy( int bind_fd, int *client_fd, void *client_ip )
{
  mute();
  int ret = net_accept(bind_fd, client_fd, client_ip);
  unmute();

  SymN("socket", 0);
  Nondet();
  assume_intype("bitstring");
  size_t len = sizeof(*client_fd);
  assume_len(&len, false, sizeof(len));
  store_buf(client_fd);

  // Let the attacker decide what this function returns.
  input("client_ip", MAX_PRINCIPAL_LENGTH);
  store_buf(client_ip);
  input("net_accept_result", sizeof(ret));
  store_buf(&ret);

  return ret;

}

void net_close_proxy(int c)
{
  mute();
  net_close(c);
  unmute();
}


