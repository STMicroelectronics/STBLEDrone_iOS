# ST BLE Drone

This repository contains the ST BLE Drone app source code.

The ST Drone is an STEVAL-FCU001V1 board, based on STM32 processor and ST sensors such as the 9-axis gyroscope, accelerometer, magnetometer, pressure, temperature and BLE.
The GUI allows to pilot the ST Drone after the BLE connection has been established, then the drone is driven by touchable analog cursors. 

Video about ST drone flight: [YouTube](https://www.youtube.com/watch?v=vGFqIDVpMT4)

For more information about ST Drone: [Drone-zone community]( https://community.st.com/community/drone-zone) 

For more information about STEVAL-FCU001V1: [ST Site]( http://www.st.com/en/evaluation-tools/steval-fcu001v1.html) 

## Download the source

Since the project uses git submodules, <code>--recursive</code> option must be used to clone the repository:

```Shell
git clone --recursive https://github.com/STMicroelectronics/STBLEDrone_iOS.git
```

or run
```Shell
git clone https://github.com/STMicroelectronics/STBLEDrone_iOS.git
git submodule update --init --recursive
```

## License

Copyright (c) 2017  STMicroelectronics – All rights reserved
The STMicroelectronics corporate logo is a trademark of STMicroelectronics

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.

- Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
STMicroelectronics company nor the names of its contributors may be used to endorse or
promote products derived from this software without specific prior written permission.

- All of the icons, pictures, logos and other images that are provided with the source code
in a directory whose title begins with st_images may only be used for internal purposes and
shall not be redistributed to any third party or modified in any way.

- Any redistributions in binary form shall not include the capability to display any of the
icons, pictures, logos and other images that are provided with the source code in a directory
whose title begins with st_images.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.
