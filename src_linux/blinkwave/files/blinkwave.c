#include <stdio.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <fcntl.h>

struct sigma_delta_data {
	unsigned int enable;
	unsigned int value;
};

#define IOCTL_MAGIC 'c'
#define IOCTL_READ_REGS  _IOR(IOCTL_MAGIC, 1, struct sigma_delta_data*) // чтение регистров
#define IOCTL_WRITE_REGS _IOW(IOCTL_MAGIC, 2, struct sigma_delta_data*) // запись регистров
 
int main()
{
    int fd;
    struct sigma_delta_data mod_data;

    mod_data.enable = 1;
    mod_data.value = 200;
    
    fd = open("/dev/80000000.Sigma_Delta_Modulator", O_RDWR);
    if(fd < 0) {
        printf("Cannot open device file...\n");
        return 0;
    }

    printf("Write Value to Driver\n");
    ioctl(fd, IOCTL_WRITE_REGS, (struct sigma_delta_data*) &mod_data); 

    printf("Reading Value from Driver\n");
    ioctl(fd, IOCTL_READ_REGS, (struct sigma_delta_data*) &mod_data);
    printf("Value is %d %d\n", mod_data.enable, mod_data.value);

    printf("Closing Driver\n");
    close(fd);

    return 0;    
}