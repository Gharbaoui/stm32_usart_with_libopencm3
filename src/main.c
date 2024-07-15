#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/usart.h>


void gpio_setup(void);
void usart_setup(void);
void uart_write_byte(uint8_t data);
void uart_write(const uint8_t *data, uint32_t length);

void gpio_setup(void)
{
  rcc_periph_clock_enable(RCC_GPIOA);
  
  gpio_mode_setup(GPIOA, GPIO_MODE_AF, GPIO_PUPD_PULLUP, GPIO2);
  gpio_set_af(GPIOA, GPIO_AF7, GPIO2);
}

void usart_setup(void)
{
  rcc_periph_clock_enable(RCC_USART2);

  usart_set_flow_control(USART2, USART_FLOWCONTROL_NONE);
  usart_set_databits(USART2, 8);
  usart_set_baudrate(USART2, 115200);
  usart_set_parity(USART2, 0);
  usart_set_stopbits(USART2, 1);

  usart_set_mode(USART2, USART_MODE_TX);
  usart_enable(USART2);
}

void uart_write_byte(uint8_t data)
{
  if (data == '\n')
    usart_send_blocking(USART2, '\r');
  usart_send_blocking(USART2, (uint16_t)data);
}

void uart_write(const uint8_t *data, uint32_t length)
{
  for (uint32_t i = 0; i < length; ++i)
    uart_write_byte(data[i]);
}

int main(void) {
  rcc_clock_setup_pll(&rcc_hsi_configs[RCC_CLOCK_3V3_180MHZ]);
  gpio_setup();
  usart_setup();
  uart_write("hello world-1\n", 14);
  uart_write("hello world-2\n", 14);
  
  while (1) {
    __asm("nop");
  }
}
