#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include <rtl-sdr.h>

#define true 1
#define false 0

void demodulate(FILE *f, const uint8_t *buf, int n_read)
{
	for (int j = 0; j+1 < n_read; j+=2)
	{
		double i = (double) ((int16_t)(buf[j]) - 127);
		double q = (double) ((int16_t)(buf[j+1]) - 127);
		double amp = sqrt(i*i + q*q);
		//printf("i(%02x)=%0.1f q(%02x)=%0.1f amp=%0.1f\n", buf[j], i, buf[j+1], q, amp);
		if ((j % 20) == 0) {
			double sample = (amp);
			int16_t sample16 = (int16_t)(256.0 * (sample - 64.0));
			//printf("s=%0.1f s16=%04x\n", sample, sample16);
			/* Encode stream in S16LE */
			fputc((uint8_t)(sample16 & 0xff), f);
			fputc((uint8_t)(sample16 >> 8), f);
		}
	}
}

int main(void)
{
	rtlsdr_dev_t *dev;
	rtlsdr_open(&dev, 0);
	rtlsdr_set_tuner_gain_mode(dev, true); // manual gain
	rtlsdr_set_tuner_gain(dev, 192); // 19.2dB
	rtlsdr_set_agc_mode(dev, true);
	rtlsdr_set_center_freq(dev, 104300000); // GOLD FM
	rtlsdr_set_tuner_bandwidth(dev, 0); // auto
	rtlsdr_set_sample_rate(dev, 960000); // 20 * 48kHz
	rtlsdr_reset_buffer(dev);

	FILE *f = fopen("data48k.s16", "wb");

	static const int buf_len = 240000; // 0.125 seconds of (i,q)
	uint8_t buf[buf_len];
	for (int i = 0; i < 8; ++i)
	{
		int n_read;
		rtlsdr_read_sync(dev, &buf, buf_len, &n_read);
		printf("%d bytes read\n", n_read);

		demodulate(f, buf, n_read);
	}
	rtlsdr_close(dev);
	printf("try: aplay -r 48000 -c 1 -f S16_LE -t raw data48k.s16\n");
	return 0;
}
