#include "sigmadelta.h"

// проверка включения модулятора
unsigned int sigmaDeltaIsEnable(int fd){
    struct sigma_delta_data mod_data;
	ioctl(fd, IOCTL_READ_REGS, (struct sigma_delta_data*) &mod_data);
    return mod_data.enable;
}

// включение модулятора
unsigned int sigmaDeltaEnable(int fd){
    struct sigma_delta_data mod_data;
    ioctl(fd, IOCTL_READ_REGS, (struct sigma_delta_data*) &mod_data);
	mod_data.enable = 1;
    ioctl(fd, IOCTL_WRITE_REGS, (struct sigma_delta_data*) &mod_data);
	return 1;
}

// выключение модулятора
unsigned int sigmaDeltaDisable(int fd){
    struct sigma_delta_data mod_data;
    ioctl(fd, IOCTL_READ_REGS, (struct sigma_delta_data*) &mod_data);
	mod_data.enable = 0;
    ioctl(fd, IOCTL_WRITE_REGS, (struct sigma_delta_data*) &mod_data);
    return 1;
}

// задать значение модулятора
unsigned int sigmaDeltaSetValue(int fd, unsigned int value){
	struct sigma_delta_data mod_data;
    ioctl(fd, IOCTL_READ_REGS, (struct sigma_delta_data*) &mod_data);
	mod_data.value = value;
    ioctl(fd, IOCTL_WRITE_REGS, (struct sigma_delta_data*) &mod_data);
	return 1;
}

// получить значение модулятора
unsigned int sigmaDeltaGetValue(int fd){
    struct sigma_delta_data mod_data;
    ioctl(fd, IOCTL_READ_REGS, (struct sigma_delta_data*) &mod_data);
	return mod_data.value;
}