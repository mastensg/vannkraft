const int r = 6;
const int led = 13;
const int in = A0;

const int slowness = 8;

int last = 0;

void
setup()
{
    pinMode(led, OUTPUT);
    pinMode(r, OUTPUT);

    digitalWrite(led, LOW);
    digitalWrite(r, LOW);

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
    case 'r': digitalWrite(r,   LOW);   break;
    case 'R': digitalWrite(r,   HIGH);  break;

    case 'l': digitalWrite(led, LOW);   break;
    case 'L': digitalWrite(led, HIGH);  break;
    }
}
