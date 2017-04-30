#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>

#define OFFSET 5

#define ST "___NCSTART_DATA=1"
#define END "___NCEND_DATA=1"

int main(int argc, char **argv) {

	FILE *fp;
	int c;
	int len_st=strlen(ST);
	int len_end=strlen(END);
	char buf_start[len_st];
	char buf_end[len_end];

	off_t start_pos=0;
	off_t stop_pos=0;

	if ((fp = fopen(argv[1], "r")) == NULL) {
			printf("error open: %s\r\n", argv[1]);
			exit(1);
	}

	int hammer=0;

	int i=0;

	while (!feof(fp)) {

		c=getc(fp);

		switch (hammer) {
			case 0:
				if (c==ST[i]) {
					buf_start[i]=c;
					i++;
				} else {
					i=0;
				}

				if (i == len_st) {
					start_pos=ftello(fp);
					printf("START HERE: %ld!!!\n",start_pos);
					hammer++;
				}
				break;
			case 1:
				if (c==END[i]) {
					buf_end[i]=c;
					i++;
				} else {
					i=0;
				}

				if (i == len_end) {
					stop_pos=ftello(fp);
					printf("END HERE: %ld!!!\n",stop_pos);
					hammer++;
				}
				break;
		}
	}

	fclose(fp);

	switch (hammer) {
		case 0:
			printf("Start label not found");
			exit(1);
			break;
		case 1:
			printf("Start label found but end label absent");
			exit(1);
			break;
	}



	return 0;
}

