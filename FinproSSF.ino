extern "C"{
  void start();
  void check_or();
  void check_and();
}

void setupButton() {
  // setup int 0, check_or button
  EICRA |= (1 << ISC01); // Set interrupt on falling edge
  EICRA &= ~(1 << ISC00);
  // Enable interrupt
  EIMSK |= (1 << INT0);

  // Enable global interrupt
  sei();

  // setup int 0, check_or button
  EICRA |= (1 << ISC11); // Set interrupt on falling edge
  EICRA &= ~(1 << ISC10);
  // Enable interrupt
  EIMSK |= (1 << INT1);
}

int main(){
  init();
  setupButton();
  start();
}

// ISR untuk button or
ISR(INT0_vect) {
  check_or(); 
}

// ISR untuk button and
ISR(INT1_vect) {
  check_and();
}