extern "C"{
  void start();
  void check_or();
}

void setupButton() {
  // Set interrupt on falling edge
  EICRA |= (1 << ISC01);
  EICRA &= ~(1 << ISC00);
  // Enable interrupt
  EIMSK |= (1 << INT0);
}

int main(){
  init();
  setupButton();
  start();
}

// ISR untuk button
ISR(INT0_vect) {
  check_or(); // Toggle LED PB1
}