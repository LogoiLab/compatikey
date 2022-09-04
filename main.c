#define F_CPU 8000000UL

#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include "config.h"

ISR(PCINT0_vect) {
	if (PINB & _BV(SWITCH))
    PORTA ^= _BV(LED_GREEN);
}

void pwm_setup (void) {
	// Set Timer 0 prescaler to clock/8.
	// At 8.0 MHz this is 1.0 MHz.
	// See ATtiny20 datasheet, Table 11.9.
	TCCR0B |= (1 << CS01);

	// Set to 'Fast PWM' mode
	TCCR0A |= (1 << WGM01) | (1 << WGM00);

	// Clear OC0B output on compare match, upwards counting.
	TCCR0A |= (1 << COM0B1);
}

void pwm_write (int val) {
	OCR0B = val;  //LED Control signal on PA7
}

void adc_setup (void) {
  // Clear ADC power reduction register
  PRADC = 0;

	// Set the ADC input to PB2/ADC1
	ADMUX |= (1 << MUX0); //BatLevel on PA1
	ADMUX |= (1 << ADLAR);

	// Set the prescaler to clock/128 & enable ADC
	ADCSRA |= (1 << ADPS1) | (1 << ADPS0) | (1 << ADEN);
}

int adc_read (void) {
	// Start the conversion
	ADCSRA |= (1 << ADSC);

	// Wait for it to finish - blocking
	while (ADCSRA & (1 << ADSC));

	return ADCH;
}

int main() {

}
