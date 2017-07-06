# NoBitLost-Test-Project
## Users guide

Users interface represents on the web-page of the freeboard.io, which is service for visualization data from IoT devices. Page is public and can be viewed by anyone at the url: [freeboard.io](https://freeboard.io/board/lZxTjP)
On this board presented 3 panes:
### 1.	Sparkline (graph) of temperature. 

Values of temperature is reading from sensor on device.

![Graph of temperature pane](http://savepic.ru/14708289.png)

### 2.	State of led. 

The led on the device consists of 3 diodes for 3 colors: red, green, and blue. Led is changing state according to the mode. In the pane, there are 3 indicators for 3 diodes of led.

![State of led pane](http://savepic.ru/14745167.png)

### 3.	Pane for manual led mode changing. 

There are 4 buttons on this pane for relevant modes. Current mode of led state changing marking below the pane.

![Pane for manual led mode changing](http://savepic.ru/14713423.png)

Name | Discription | State model
-----|-------------|------------
Blink mode | Mode of the led state changing, when all 3 diodes on or off at the same time.| (0,0,0) → (1,1,1) → (0,0,0)
Sequential mode | Mode of the led state changing, when diodes of the led turning on by sequence for the all 8 binary combination of states for 3 diodes. | (0,0,0) → (0,0,1) → (0,1,0) → (0,1,1) → (1,0,0) → (1,0,1) → (1,1,0) → (1,1,1) → (0,0,0)
Overlay mode | Mode of the led state changing, when diodes turning on by the coupled sequence. | (0,0,0) → (1,0,0) → (1,1,0) → (1,1,1) → (0,1,1) → (0,0,1) → (0,0,0)
Random mode | Mode of the led state changing, when state depends on time: state is binary value of the remainder of the division current time reading from timer to 8.

Updating of value in sparkline happening at intervals of 10 seconds. 

Updating of led mode happening at intervals of 3 seconds.

## Time chart of user-device communication:
![Time chart of user-device communication](http://savepic.ru/14737127.png)
