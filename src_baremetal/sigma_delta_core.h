#ifndef SIGMADELTA_H		/* prevent circular inclusions */
#define SIGMADELTA_H		/* by using protection macros */

#include "xil_types.h"

// смещение регистров
#define ENABLE_OFFSET 0x0
#define VALUE_OFFSET 0x4

// дескриптор сигма-дельта модулятора
typedef struct {
	u32 baseAddr;
	u32 value;
	u32 enable;
	u32 isInit;
} SigmaDelta;

// инициализация дескриптора
u32 sigmaDeltaInit(SigmaDelta* sigmaDeltaInst, u32 addr);

// проверка инициализации дескриптора
u32 sigmaDeltaIsInit(SigmaDelta* sigmaDeltaInst);

// проверка включения модулятора
u32 sigmaDeltaIsEnable(SigmaDelta* sigmaDeltaInst);

// включение модулятора
u32 sigmaDeltaEnable(SigmaDelta* sigmaDeltaInst);

// выключение модулятора
u32 sigmaDeltaDisable(SigmaDelta* sigmaDeltaInst);


#endif
