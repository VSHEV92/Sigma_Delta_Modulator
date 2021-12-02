#include <xparameters.h>
#include <xil_printf.h>
#include "sigma_delta_core.h"

#include "xil_io.h"

SigmaDelta sigmaDeltaArray[8];

int main(){
	sigmaDeltaInit(sigmaDeltaArray, XPAR_SIGMA_DELTA_MODULATOR_0_BASEADDR);
	xil_printf("Start \n");
	xil_printf("Is Enable %d\n", Xil_In32(XPAR_SIGMA_DELTA_MODULATOR_0_BASEADDR + ENABLE_OFFSET));
	xil_printf("Start1 \n");
	//sigmaDeltaEnable(sigmaDeltaArray);

	//xil_printf("Is Enable %d\n", sigmaDeltaIsEnable(sigmaDeltaArray));


	return 0;
}
