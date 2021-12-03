#include "Sigma_Delta_Modulator.h"
#include "xil_io.h"
#include <xil_printf.h>

// запись регистра
#define SigmaDelta_WriteReg(BaseAddr, RegOffset, Data)	\
		Xil_Out32((BaseAddr) + (u32)(RegOffset), (u32)(Data))

// чтение регистра
#define SigmaDelta_ReadReg(BaseAddr, RegOffset)		\
		Xil_In32((BaseAddr) + (u32)(RegOffset))

// инициализация дескриптора
u32 sigmaDeltaInit(SigmaDelta* sigmaDeltaInst, u32 addr){
	sigmaDeltaInst->baseAddr = addr;
	sigmaDeltaInst->isInit = 1;
	return 1;
}

// проверка инициализации дескриптора
u32 sigmaDeltaIsInit(SigmaDelta* sigmaDeltaInst){
	return sigmaDeltaInst->isInit;
}

// проверка включения модулятора
u32 sigmaDeltaIsEnable(SigmaDelta* sigmaDeltaInst){
	return SigmaDelta_ReadReg(sigmaDeltaInst->baseAddr, ENABLE_OFFSET);
}

// включение модулятора
u32 sigmaDeltaEnable(SigmaDelta* sigmaDeltaInst){
	SigmaDelta_WriteReg(sigmaDeltaInst->baseAddr, ENABLE_OFFSET, 1);
	return 1;
}

// выключение модулятора
u32 sigmaDeltaDisable(SigmaDelta* sigmaDeltaInst){
	SigmaDelta_WriteReg(sigmaDeltaInst->baseAddr, ENABLE_OFFSET, 0);
	return 1;
}

// задать значение модулятора
u32 sigmaDeltaSetValue(SigmaDelta* sigmaDeltaInst, u8 value){
	SigmaDelta_WriteReg(sigmaDeltaInst->baseAddr, VALUE_OFFSET, value);
	return 1;
}

// получить значение модулятора
u32 sigmaDeltaGetValue(SigmaDelta* sigmaDeltaInst){
	return SigmaDelta_ReadReg(sigmaDeltaInst->baseAddr, VALUE_OFFSET);
}
