#include <sys/ioctl.h>

struct sigma_delta_data {
	unsigned int enable;
	unsigned int value;
};

#define IOCTL_MAGIC 'c'
#define IOCTL_READ_REGS  _IOR(IOCTL_MAGIC, 1, struct sigma_delta_data*) // чтение регистров
#define IOCTL_WRITE_REGS _IOW(IOCTL_MAGIC, 2, struct sigma_delta_data*) // запись регистров

// проверка включения модулятора
unsigned int sigmaDeltaIsEnable(int fd);

// включение модулятора
unsigned int sigmaDeltaEnable(int fd);

// выключение модулятора
unsigned int sigmaDeltaDisable(int fd);

// задать значение модулятора
unsigned int sigmaDeltaSetValue(int fd, unsigned int value);

// получить значение модулятора
unsigned int sigmaDeltaGetValue(int fd);
