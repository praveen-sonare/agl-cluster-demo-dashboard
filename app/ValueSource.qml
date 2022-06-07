/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Copyright (C) 2018, 2019 Konsulko Group
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.2
Item {
    id: valueSource
    property real kph: 0
    property bool mphDisplay: false
    property real speedScaling: mphDisplay == true ? 0.621504 : 1.0
    property real rpm: 1
    property real fuel: 0.85
    property string gear: {
        var g;
        if (kph < 30) {
            return "1";
        }
        if (kph < 50) {
            return "2";
        }
        if (kph < 80) {
            return "3";
        }
        if (kph < 120) {
            return "4";
        }
        if (kph < 160) {
            return "5";
        }
    }
    property string prindle: {
        var g;
        if (kph > 0) {
            return "D";
        }
        return "P";
    }

    property bool start: true
    property int turnSignal: -1
    property bool startUp: false
    property real temperature: 0.6
    property bool cruiseEnabled: false
    property bool cruiseSet: false
    property bool laneDepartureWarnEnabled: false
    property bool displayNumericSpeeds: true

    function randomDirection() {
        return Math.random() > 0.5 ? Qt.LeftArrow : Qt.RightArrow;
    }

    Component.onCompleted : {
        if(!runAnimation) {
            VehicleSignals.connect()
        }
    }

    Connections {
        target: VehicleSignals

        onConnected: {
	    VehicleSignals.authorize()
        }

        onAuthorized: {
	    VehicleSignals.subscribe("Vehicle.Speed")
	    VehicleSignals.subscribe("Vehicle.Powertrain.CombustionEngine.Engine.Speed")
	    VehicleSignals.subscribe("Vehicle.ADAS.CruiseControl.IsActive")
	    VehicleSignals.subscribe("Vehicle.ADAS.CruiseControl.IsSet")
	    VehicleSignals.subscribe("Vehicle.ADAS.LaneDepartureDetection.IsActive")
	    VehicleSignals.subscribe("Vehicle.Cabin.Infotainment.Cluster.Mode")
	    VehicleSignals.get("Vehicle.Cabin.Infotainment.HMI.DistanceUnit")
	    VehicleSignals.subscribe("Vehicle.Cabin.Infotainment.HMI.DistanceUnit")
	}

        onGetSuccessResponse: {
            //console.log("response path = " + path + ", value = " + value)
            if (path === "Vehicle.Cabin.Infotainment.HMI.DistanceUnit") {
                if (value === "km") {
                    valueSource.mphDisplay = false
                } else if (value === "mi") {
                    valueSource.mphDisplay = true
                }
            }
        }

        onSignalNotification: {
            //console.log("signal path = " + path + ", value = " + value)
            if (path === "Vehicle.Speed") {
                // units are always km/h
                // Checking Vehicle.Cabin.Infotainment.HMI.DistanceUnit for the
                // display unit would likely be a worthwhile enhancement.
	        if(!runAnimation) {
                    valueSource.kph = parseFloat(value)
                }
            } else if (path === "Vehicle.Powertrain.CombustionEngine.Engine.Speed") {
	        if(!runAnimation) {
                    valueSource.rpm = parseFloat(value) / 1000
                }
            } else if (path === "Vehicle.ADAS.CruiseControl.IsActive" && value === "true") {
                if(valueSource.cruiseEnabled) {
                    valueSource.cruiseEnabled = false
                    valueSource.cruiseSet = false
                } else {
                    valueSource.cruiseEnabled = true
                }
            } else if (path === "Vehicle.ADAS.CruiseControl.IsSet") {
                if (value === "true") {
                    if(valueSource.cruiseEnabled)
                        valueSource.cruiseSet = true
                } else {
                    valueSource.cruiseSet = false
                }
            } else if (path === "Vehicle.ADAS.LaneDepartureDetection.IsActive" && value === "true") {
                valueSource.laneDepartureWarnEnabled = !valueSource.laneDepartureWarnEnabled
            } else if (path === "Vehicle.Cabin.Infotainment.Cluster.Mode" && value === "true") {
                valueSource.displayNumericSpeeds = !valueSource.displayNumericSpeeds
            } else if (path === "Vehicle.Cabin.Infotainment.HMI.DistanceUnit") {
                if (value === "km") {
                    valueSource.mphDisplay = false
                } else if (value === "mi") {
                    valueSource.mphDisplay = true
                }
            }
        }
    }

    SequentialAnimation {
        running: runAnimation
        loops: 1

        // We want a small pause at the beginning, but we only want it to happen once.
        PauseAnimation {
            duration: 1000
        }

        PropertyAction {
            target: valueSource
            property: "start"
            value: false
        }

        SequentialAnimation {
            loops: Animation.Infinite

            // Simulate startup with indicators blink
            PropertyAction {
                target: valueSource
                property: "startUp"
                value: true
            }
            PauseAnimation {
                duration: 1000
            }
            PropertyAction {
                target: valueSource
                property: "startUp"
                value: false
            }

            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    from: 0
                    to: 30
                    duration: 3000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    from: 1
                    to: 6.1
                    duration: 3000
                }
            }
            ParallelAnimation {
                // We changed gears so we lost a bit of speed.
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    from: 30
                    to: 26
                    duration: 600
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    from: 6
                    to: 2.4
                    duration: 600
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 60
                    duration: 3000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 5.6
                    duration: 3000
                }
            }
            ParallelAnimation {
                // We changed gears so we lost a bit of speed.
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 56
                    duration: 600
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 2.3
                    duration: 600
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 100
                    duration: 3000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 5.1
                    duration: 3000
                }
            }
            ParallelAnimation {
                // We changed gears so we lost a bit of speed.
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 96
                    duration: 600
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 2.2
                    duration: 600
                }
            }

            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 140
                    duration: 3000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 6.2
                    duration: 3000
                }
            }

            // Slow down a bit
            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 115
                    duration: 6000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 5.5
                    duration: 6000
                }
            }

            // Turn signal on
            PropertyAction {
                target: valueSource
                property: "turnSignal"
                value: randomDirection()
            }

            // Cruise for a while
            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 110
                    duration: 10000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 5.2
                    duration: 10000
                }
            }

            // Turn signal off
            PropertyAction {
                target: valueSource
                property: "turnSignal"
                value: -1
            }

            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 115
                    duration: 10000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 5.5
                    duration: 10000
                }
            }

            // Start downshifting.

            // Fifth to fourth gear.
            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.Linear
                    to: 100
                    duration: 5000
                }

                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 3.1
                    duration: 5000
                }
            }

            // Fourth to third gear.
            NumberAnimation {
                target: valueSource
                property: "rpm"
                easing.type: Easing.InOutSine
                to: 5.5
                duration: 600
            }

            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 60
                    duration: 5000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 2.6
                    duration: 5000
                }
            }

            // Third to second gear.
            NumberAnimation {
                target: valueSource
                property: "rpm"
                easing.type: Easing.InOutSine
                to: 6.3
                duration: 600
            }

            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 30
                    duration: 5000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 2.6
                    duration: 5000
                }
            }

            NumberAnimation {
                target: valueSource
                property: "rpm"
                easing.type: Easing.InOutSine
                to: 6.5
                duration: 600
            }

            // Second to first gear.
            ParallelAnimation {
                NumberAnimation {
                    target: valueSource
                    property: "kph"
                    easing.type: Easing.InOutSine
                    to: 0
                    duration: 5000
                }
                NumberAnimation {
                    target: valueSource
                    property: "rpm"
                    easing.type: Easing.InOutSine
                    to: 1
                    duration: 4500
                }
            }

            PauseAnimation {
                duration: 5000
            }
        }
    }
}
