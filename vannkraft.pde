import processing.serial.*;
import cc.arduino.*;

/*********************************************************************/

final boolean debug = false;
boolean left_down = false;
boolean right_down = false;

/*********************************************************************/

/* Digital outputs */
final int led = 13;
final int relay =6;

/* Analog inputs */
final int left_input = 1;
final int right_input = 0;

/* Relay states */
final int pump = 1;
final int drain = 0;

/* Game states */
final int waiting = 0;
final int preparing = 1;
final int pumping = 2;
final int draining = 3;

/* Assume constant power while wheel is running */
final float power = 5.0;
final float max_energy = 50.0;

/*********************************************************************/

int state;

int started_preparing_at;
int started_pumping_at;

int lastX;
int lastY;

PFont font;

Arduino arduino;

Wheel left_wheel;
Wheel right_wheel;

/*********************************************************************/

class Wheel
{
    int pin;
    boolean started;
    int started_at;
    int last_ran_at;
    boolean stopped;

    Wheel(int p)
    {
        pin = p;
    }

    void draw(float x)
    {
        float energy;

        energy = (last_ran_at - started_at) * power / 1000;

        fill(0x0c, 0x04, 0x3E);
        textSize(height / 12);
        text(String.format("%2.1f J", energy), width * x, height * 3 / 4);

        /* Bar graph */
        /*
        rectMode(CENTER);
        rect(x, height * 7 / 8, width / 16, energy);
        */
    }

    void reset()
    {
        int now = millis();

        started = false;
        started_at = now;
        last_ran_at = now;
        stopped = false;
    }

    void update()
    {
        update(0 < arduino.analogRead(pin));
    }

    void update(boolean running)
    {
        int now = millis();

        if (running)
        {
            last_ran_at = now;
        }

        if (running && !started)
        {
            started = true;
            started_at = now;
        }

        stopped = !running && last_ran_at + 5000 < now;
    }
}

/*********************************************************************/

void
center_text(String s, float h)
{
    fill(0x0c, 0x04, 0x3E);
    textSize(height * h);
    text(s, width / 2, height / 2);
}

void
center_text(int n, float h)
{
    center_text("" + n, h);
}

/*********************************************************************/

String
arduino_port()
{
    final String pattern = "/dev/tty.usbmodem";
    String[] ports = Arduino.list();
    String p;
    int i;

    for(i = 0; i < ports.length; ++i)
    {
        p = ports[i];

        if (p.contains(pattern))
            return p;
    }

    return "";
}

/*********************************************************************/

void
setup()
{
    arduino = new Arduino(this, Arduino.list()[0], 57600);
    arduino.pinMode(led, Arduino.OUTPUT);
    arduino.pinMode(relay, Arduino.OUTPUT);
    arduino.digitalWrite(relay, drain);

    left_wheel = new Wheel(left_input);
    right_wheel = new Wheel(right_input);

    state = waiting;

    font = createFont("DejaVuSans", 16, true);
    textFont(font);
    textAlign(CENTER, CENTER);

    size(1024, 768);

    noCursor();
    lastX = mouseX;
    lastY = mouseY;
}

/*********************************************************************/

void draw()
{
    int countdown;
    int now = millis();

    background(0xC3EBF7);

    switch (state)
    {
        case waiting:

            arduino.digitalWrite(relay, drain);

            center_text("Trykk på skjermen", 1./8);
            
            if (mouseX != lastX || mouseY != lastY)
            {
              state = preparing;
              started_preparing_at = now;
            }

            break;

        case preparing:

            arduino.digitalWrite(relay, drain);

            countdown = (started_preparing_at + 3999 - now) / 1000;

            if (1 > countdown)
            {
                state = pumping;
                started_pumping_at = now;
            }
            else
            {
                center_text(countdown, 3./4);
            }

            break;

        case pumping:

            arduino.digitalWrite(relay, pump);

            countdown = (started_pumping_at + 16999 - now) / 1000;

            if (1 > countdown)
            {
                state = draining;

                left_wheel.reset();
                right_wheel.reset();
            }
            else if (15 < countdown)
            {
                center_text("Pump!", 1./4);
            }
            else
            {
                center_text(countdown, 3./4);
            }

            break;

        case draining:

            arduino.digitalWrite(relay, drain);

            if (debug)
            {
                left_wheel.update(left_down);
                right_wheel.update(right_down);
            }
            else
            {

                left_wheel.update();
                right_wheel.update();
            }


            if (left_wheel.stopped && right_wheel.stopped)
            {
                state = waiting;
                lastX = mouseX;
                lastY = mouseY;

                break;
            }

            left_wheel.draw(1./4);
            right_wheel.draw(3./4);

            break;

        default:

            println("?");
            break;
    }
}

/*********************************************************************/

void
mouse()
{
    if (debug && state != waiting)
    {
        state = draining;
        left_wheel.reset();
        right_wheel.reset();
        return;
    }

    if (state != waiting)
        return;

    state = preparing;
    started_preparing_at = millis();
}

//void mouseClicked()  { mouse(); }
//void mouseDragged()  { mouse(); }
void mousePressed()  { mouse(); }
//void mouseReleased() { mouse(); }

/*********************************************************************/

void keyPressed()
{
    if (key == CODED)
    {
        if (keyCode == LEFT) left_down = true;
        if (keyCode == RIGHT) right_down = true;
    }
}

void
keyReleased()
{
    if (key == CODED)
    {
        if (keyCode == LEFT) left_down = false;
        if (keyCode == RIGHT) right_down = false;
    }
}
