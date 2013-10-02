const int a = 11;
const int b = 12;
const int led = 13;
const int in = A0;

const int slowness = 8;

int last = 0;

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
    char c;

    while (!Serial.available())
    {
        if (millis() >> slowness == last)
            continue;

        last = millis() >> slowness;

        Serial.println(analogRead(in));
    }

    c = Serial.read();

    switch (c)
    {
    case 'a': digitalWrite(a,   LOW);   break;
    case 'A': digitalWrite(a,   HIGH);  break;

    case 'b': digitalWrite(b,   LOW);   break;
    case 'B': digitalWrite(b,   HIGH);  break;

    case 'l': digitalWrite(led, LOW);   break;
    case 'L': digitalWrite(led, HIGH);  break;
    }
}
