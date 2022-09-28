/* Fonctions commune pour la gestion des sockets et autres. */

#include <stdio.h>
#include <stddef.h>
// #include <asm/errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <string.h>
#include <stdlib.h>

#include "common.h"
#include "lib.h"

int print_connect_error (int err)
{
 
  printf("\nErreur de connect %d",err);
  return(1);
  /* 
      switch (err) 
        {
        case  EBADF: 
          printf("\n EBADF : Mauvais descripteur."); 
          break;
        case  EFAULT: 
          printf("\n EFAULT : La structure d'adresse de la socket pointe en dehors de l'espace d'adressage.");
          break;
        case ENOTSOCK:
          printf("\n ENOTSOCK : Le descripteur ne correspond pas � une socket.");
          break;
        case EISCONN:
          printf("\n EISCONN : La socket est d�j� connect�e.");
          break;
        case ECONNREFUSED:
          printf("\n ECONNREFUSED : La connexion est refus�e par le serveur.");
          break;
        case ETIMEDOUT:
          printf ("\n ETIMEDOUT : D�passement du d�lai maximum pendant la connexion.");
          break;
        case ENETUNREACH:
          printf("\n ENETUNREACH : Le r�seau est inaccessible.");
          break;
        case EHOSTUNREACH:
          printf("\n EHOSTUNREACH : Le correspondant ne peut pas �tre joint.");
          break;
        case EADDRINUSE:
          printf("\n EADDRINUSE : L'adresse est d�j� utilis�e.");
          break;
        case EINPROGRESS:
          printf("\n EINPROGRESS : La socket est non-bloquante, et la connexion ne peut pas �tre �tablie imm�diatement.");
          break;
        case EALREADY:
          printf("\n EALREADY : La socket est non-bloquante et une tentative de connexion pr�c�dente ne s'est pas encore termin�e.");
          break;
        };
  
  printf("\n");
  */
}



int create_bind_socket(int port) {
  struct sockaddr_in sa;
  int listen_fd, opt;
  
  listen_fd = socket(PF_INET, SOCK_STREAM, 0);
  opt = 1;
  setsockopt (listen_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof (opt));
  memset(&sa, 0, sizeof (sa));
  sa.sin_family = PF_INET;
  sa.sin_addr.s_addr = htonl(INADDR_ANY);
  sa.sin_port = htons(port);
  bind(listen_fd, (struct sockaddr *) &sa, sizeof (sa));
  listen(listen_fd, 1);

  return (listen_fd);
}

int connect_socket(char *addr, int port) {
  int sock_fd;
  struct sockaddr_in sa;
  int err;

  sock_fd = socket(PF_INET, SOCK_STREAM, 0);
  memset(&sa, 0, sizeof (sa));

  sa.sin_family = AF_INET;

  sa.sin_port = htons(port);

  sa.sin_addr.s_addr = inet_addr(addr);

  err = connect(sock_fd, (struct sockaddr *) &sa, sizeof (sa));

  if (err != 0) 
    { 
      printf("\nErreur de connexion"); 
      print_connect_error(err);
      exit(1);
    };

  return (sock_fd);
}
