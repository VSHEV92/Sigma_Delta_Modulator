// Приложение запускает бегущую волну на светодиодах

#include <xparameters.h>
#include <xil_printf.h>
#include <xil_io.h>
#include <math.h>
#include <Sigma_Delta_Modulator.h>

#define PI 3.14159265

// число модуляторов
#define IP_NUMB 8

// число отсчетов в волне
#define WAVE_LEN 256

// адрес первого ядро
#define BASE XPAR_SIGMA_DELTA_MODULATOR_0_S_AXI_BASEADDR

// смещения адресов ядре
#define OFFSET 0x10000

// задержка (лучше бы через таймер и прерывания)
void delay(u32 del){
	for (u32 i = 0; i < del; i++);
}

// запустить волну справа налево
void startWave(u8* waveSamples, SigmaDelta* sigmaDeltaArray, u8 leftDirection){
	for (int j = 0; j<WAVE_LEN*2; j++){
		if (leftDirection) {
			for (int i = 0; i<IP_NUMB; i++)
				sigmaDeltaSetValue(sigmaDeltaArray+i, waveSamples[j+i*WAVE_LEN/IP_NUMB]);
		} else {
			for (int i = 0; i<IP_NUMB; i++)
				sigmaDeltaSetValue(sigmaDeltaArray+IP_NUMB-1-i, waveSamples[j+i*WAVE_LEN/IP_NUMB]);
		}
		delay(1000000);
	}
}

void startWaveLeft(u8* waveSamples, SigmaDelta* sigmaDeltaArray){
	startWave(waveSamples, sigmaDeltaArray, 1);
}

void startWaveRigth(u8* waveSamples, SigmaDelta* sigmaDeltaArray){
	startWave(waveSamples, sigmaDeltaArray, 0);
}

// массив дескрипторов ядер
SigmaDelta sigmaDeltaArray[IP_NUMB];

int main(){

	// массив отсчетов волны
	u8 waveSamples[WAVE_LEN*3];

	// -------------------------------------------------------------------
	// инициализация отсчетов волны
	for (int i = 0; i<WAVE_LEN*3; i++)
		waveSamples[i] = 0;

	for (int i = WAVE_LEN; i<WAVE_LEN+WAVE_LEN/2; i++)
		waveSamples[i] = WAVE_LEN * 0.9 * sin((i-WAVE_LEN)*PI/WAVE_LEN);

	for (int i = WAVE_LEN+WAVE_LEN/2; i<WAVE_LEN*2; i++)
		waveSamples[i] = WAVE_LEN * 0.9 * sin((WAVE_LEN*2 - i)*PI/WAVE_LEN);

	// -------------------------------------------------------------------
	// инициализация ядер
		for (int i = 0; i<8; i++){
			sigmaDeltaInit(sigmaDeltaArray+i, BASE+OFFSET*i);
			sigmaDeltaEnable(sigmaDeltaArray+i);
			sigmaDeltaSetValue(sigmaDeltaArray+i, 0);
		}

	// -------------------------------------------------------------------
	// запуск бегущей волны
	while(1){
		startWaveLeft(waveSamples, sigmaDeltaArray);
		startWaveRigth(waveSamples, sigmaDeltaArray);
	}
	return 0;
}

