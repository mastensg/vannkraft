const int led = 13;

void
setup()
{
    pinMode(led, OUTPUT);

    digitalWrite(led, LOW);

    Serial.begin(9600);
}

void
loop()
{
    while (!Serial.available())
        ;

    digitalWrite(led, HIGH);
}
