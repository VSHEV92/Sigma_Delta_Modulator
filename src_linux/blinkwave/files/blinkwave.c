#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <SIGMADELTA/sigmadelta.h>

#define PI 3.14159265

// число модуляторов
#define IP_NUMB 8

// число отсчетов в волне
#define WAVE_LEN 256

// запустить волну справа налево
void startWave(unsigned int* waveSamples, int* sigmaDeltaArray, int leftDirection){
	for (int j = 0; j<WAVE_LEN*2; j++){
		if (leftDirection) {
			for (int i = 0; i<IP_NUMB; i++)
				sigmaDeltaSetValue(sigmaDeltaArray[i], waveSamples[j+i*WAVE_LEN/IP_NUMB]);
		} else {
			for (int i = 0; i<IP_NUMB; i++)
				sigmaDeltaSetValue(sigmaDeltaArray[IP_NUMB-1-i], waveSamples[j+i*WAVE_LEN/IP_NUMB]);
		}
		usleep(5000);
	}
}

void startWaveLeft(unsigned int* waveSamples, int* sigmaDeltaArray){
	startWave(waveSamples, sigmaDeltaArray, 1);
}

void startWaveRigth(unsigned int* waveSamples, int* sigmaDeltaArray){
	startWave(waveSamples, sigmaDeltaArray, 0);
}

int main()
{
    int sigmaDeltaArray[IP_NUMB];

    // массив отсчетов волны
	unsigned int waveSamples[WAVE_LEN*3];

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
    sigmaDeltaArray[0] = open("/dev/80000000.Sigma_Delta_Modulator", O_RDWR);
    sigmaDeltaArray[1] = open("/dev/80010000.Sigma_Delta_Modulator", O_RDWR);
    sigmaDeltaArray[2] = open("/dev/80020000.Sigma_Delta_Modulator", O_RDWR);
    sigmaDeltaArray[3] = open("/dev/80030000.Sigma_Delta_Modulator", O_RDWR);
    sigmaDeltaArray[4] = open("/dev/80040000.Sigma_Delta_Modulator", O_RDWR);
    sigmaDeltaArray[5] = open("/dev/80050000.Sigma_Delta_Modulator", O_RDWR);
    sigmaDeltaArray[6] = open("/dev/80060000.Sigma_Delta_Modulator", O_RDWR);
    sigmaDeltaArray[7] = open("/dev/80070000.Sigma_Delta_Modulator", O_RDWR);

    for (int i = 0; i < IP_NUMB; i++)
        if(sigmaDeltaArray[i] < 0) {
            printf("Cannot open device file...\n");
            return -1;
        }
    for (int i = 0; i < IP_NUMB; i++){
        sigmaDeltaSetValue(sigmaDeltaArray[i], 0);
        sigmaDeltaEnable(sigmaDeltaArray[i]);
    }

	// -------------------------------------------------------------------
	// запуск бегущей волны
	while(1){
		startWaveLeft(waveSamples, sigmaDeltaArray);
		startWaveRigth(waveSamples, sigmaDeltaArray);
	}

    return 0;    
}
