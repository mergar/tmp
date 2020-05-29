#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <net/netmap_user.h>
#include <net/netmap.h>
#include <errno.h>
#include <inttypes.h>   /* PRI* macros */

void nm_ioctl(struct nmreq_header *hdr)
{
        int fd = open("/dev/netmap", O_RDWR);

        if (fd < 0)
                exit(1);
                //throw sysexception("open /dev/netmap", errno);

        if (ioctl(fd, NIOCCTRL, hdr) < 0) {
                int err = errno;
                close(fd);

                if (hdr->nr_reqtype == NETMAP_REQ_VALE_LIST && err == ENOENT)
                        return;
                else
                        exit(1);
                        //throw sysexception("netmap NIOCTRL", err);
        }
}

int main()
{
	struct nmreq_header hdr;
        struct nmreq_vale_list req;
	int i=0, j=0, x=0;
	char *token = NULL;

        for (i = 0; i < 64; i++) {
                memset(&hdr, 0, sizeof(hdr));

                hdr.nr_version = NETMAP_API;
                hdr.nr_reqtype = NETMAP_REQ_VALE_LIST;
                hdr.nr_body    = (uintptr_t)&req;
                req.nr_bridge_idx = i;
                req.nr_port_idx = 0;

                nm_ioctl(&hdr);

                if (hdr.nr_name[0] == 0)
                        break;
 
		printf("bridge index: [%d]\n",i);

                for (j = 0; j < 255; j++) {
                        memset(&hdr, 0, sizeof(hdr));
 
                        hdr.nr_version = NETMAP_API;
                        hdr.nr_reqtype = NETMAP_REQ_VALE_LIST;
                        hdr.nr_body    = (uintptr_t)&req;
                        req.nr_bridge_idx = i;
                        req.nr_port_idx = j;
 
                        nm_ioctl(&hdr);
        
                        if (hdr.nr_name[0] == 0 || req.nr_port_idx != j) {
                                break;
                        }
        
//			printf("  port[%d] -> [%s]\n",j,hdr.nr_name);

			for (x = 0, token = strtok(hdr.nr_name, ":"); token; x++, token = strtok(NULL, ":")) {
				switch(x) {
					case 0:
						printf("switch name: %s\n", token);
						break;
						;;
					case 1:
						printf("  port name: %s\n",token);
						break;
						;;
					default:
						printf (" unknown config: %s\n",token);
						break;
				}
			}
//			token = strtok(hdr.nr_name, ":");
//			printf( " %s\n", token ); //printing the token

		}
	}
}
