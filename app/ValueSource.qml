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

    // Rcar signal
    property bool parkingBrakeIsEngaged: false
    property bool engineOn: false
    property bool oilLevelWarning: false
    property real oilLevel: 0
    property bool batteryLevelWarning: false

    property bool is_Seat_Row1_Pos1_IsBelted: false
    property bool is_Seat_Row1_Pos2_IsBelted: false
    property bool is_Seat_Row2_Pos1_IsBelted: false
    property bool is_Seat_Row2_Pos2_IsBelted: false
    property bool is_Seat_NotIsBelted: false

    property bool is_HighBeamOn: false
    property bool is_LowBeamOn: false
    property bool is_BeamOn: false

    property bool is_Row1_Left_IsOpen: false
    property bool is_Row1_Right_IsOpen: false
    property bool is_Row2_Left_IsOpen: false
    property bool is_Row2_Right_IsOpen: false
    property bool is_Door_IsOpen: false


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
	    VehicleSignals.subscribe("Vehicle.Powertrain.CombustionEngine.Speed")

	    VehicleSignals.subscribe("Vehicle.Cabin.SteeringWheel.Switches.CruiseEnable")
	    VehicleSignals.subscribe("Vehicle.Cabin.SteeringWheel.Switches.CruiseSet")
	    VehicleSignals.subscribe("Vehicle.Cabin.SteeringWheel.Switches.CruiseResume")
	    VehicleSignals.subscribe("Vehicle.Cabin.SteeringWheel.Switches.CruiseCancel")

	    VehicleSignals.subscribe("Vehicle.Cabin.SteeringWheel.Switches.LaneDepartureWarning")
	    VehicleSignals.subscribe("Vehicle.Cabin.SteeringWheel.Switches.Info")

	    VehicleSignals.get("Vehicle.Cabin.Infotainment.HMI.DistanceUnit")
	    VehicleSignals.subscribe("Vehicle.Cabin.Infotainment.HMI.DistanceUnit")

        // Rcar signal
        VehicleSignals.subscribe("Vehicle.Chassis.ParkingBrake.IsEngaged")
        VehicleSignals.subscribe("Vehicle.Private.OBD.OilLevel")
        VehicleSignals.subscribe("Vehicle.Powertrain.Battery.GrossCapacity")

        VehicleSignals.subscribe('Vehicle.Cabin.Seat.Row1.Pos1.IsBelted')
        VehicleSignals.subscribe('Vehicle.Cabin.Seat.Row1.Pos2.IsBelted')
        VehicleSignals.subscribe('Vehicle.Cabin.Seat.Row2.Pos1.IsBelted')
        VehicleSignals.subscribe('Vehicle.Cabin.Seat.Row2.Pos2.IsBelted')

        VehicleSignals.subscribe('Vehicle.Body.Lights.IsHighBeamOn')
        VehicleSignals.subscribe('Vehicle.Body.Lights.IsLowBeamOn')

        VehicleSignals.subscribe('Vehicle.Cabin.Door.Row1.Left.IsOpen')
        VehicleSignals.subscribe('Vehicle.Cabin.Door.Row1.Right.IsOpen')
        VehicleSignals.subscribe('Vehicle.Cabin.Door.Row2.Left.IsOpen')
        VehicleSignals.subscribe('Vehicle.Cabin.Door.Row2.Right.IsOpen')
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
            } else if (path === "Vehicle.Powertrain.CombustionEngine.Speed") {
	        if(!runAnimation) {
                    valueSource.rpm = parseFloat(value) / 1000

                    if (valueSource.rpm > 0) {
                        valueSource.engineOn = true
                    } else {
                        valueSource.engineOn = false
                    }
                }
            } else if (path === "Vehicle.Cabin.SteeringWheel.Switches.CruiseEnable" && value === "true") {
                if(valueSource.cruiseEnabled) {
                    valueSource.cruiseEnabled = false
                    valueSource.cruiseSet = false
                } else {
                    valueSource.cruiseEnabled = true
                }
            } else if ((path === "Vehicle.Cabin.SteeringWheel.Switches.CruiseSet" ||
                        path === "Vehicle.Cabin.SteeringWheel.Switches.CruiseResume") &&
                       value == "true") {
                if(valueSource.cruiseEnabled) {
                    valueSource.cruiseSet = true
                }
            } else if (path === "Vehicle.Cabin.SteeringWheel.Switches.CruiseCancel" && value === "true") {
                valueSource.cruiseSet = false
            } else if (path === "Vehicle.Cabin.SteeringWheel.Switches.LaneDepartureWarning" && value === "true") {
                valueSource.laneDepartureWarnEnabled = !valueSource.laneDepartureWarnEnabled
            } else if (path === "Vehicle.Cabin.SteeringWheel.Switches.Info" && value === "true") {
                valueSource.displayNumericSpeeds = !valueSource.displayNumericSpeeds
            } else if (path === "Vehicle.Cabin.Infotainment.HMI.DistanceUnit") {
                if (value === "km") {
                    valueSource.mphDisplay = false
                } else if (value === "mi") {
                    valueSource.mphDisplay = true
                }
            } else if (path === "Vehicle.Chassis.ParkingBrake.IsEngaged") {
                if (value === "true") {
                    valueSource.parkingBrakeIsEngaged = true
                } else if (value === "false") {
                    valueSource.parkingBrakeIsEngaged = false
                }
                
            } else if (path === "Vehicle.Private.OBD.OilLevel") {
                if (value < 10) {
                    valueSource.oilLevelWarning = true
                } else {
                    valueSource.oilLevelWarning = false
                }
            } else if (path === "Vehicle.Powertrain.Battery.GrossCapacity") {
                if (value < 10) {
                    valueSource.batteryLevelWarning = true
                } else {
                    valueSource.batteryLevelWarning = false
                }
            } else if (path === 'Vehicle.Cabin.Seat.Row1.Pos1.IsBelted' ||
                       path === 'Vehicle.Cabin.Seat.Row1.Pos2.IsBelted' ||
                       path === 'Vehicle.Cabin.Seat.Row2.Pos1.IsBelted' ||
                       path === 'Vehicle.Cabin.Seat.Row2.Pos2.IsBelted' ) {

                if ( path === 'Vehicle.Cabin.Seat.Row1.Pos1.IsBelted' ) {
                    if (value === "true") {
                        valueSource.is_Seat_Row1_Pos1_IsBelted = true
                    } else if (value === "false") {
                        valueSource.is_Seat_Row1_Pos1_IsBelted = false
                    }
                } else if ( path === 'Vehicle.Cabin.Seat.Row1.Pos2.IsBelted' ) {
                    if (value === "true") {
                        valueSource.is_Seat_Row1_Pos2_IsBelted = true
                    } else if (value === "false") {
                        valueSource.is_Seat_Row1_Pos2_IsBelted = false
                    }
                } else if ( path === 'Vehicle.Cabin.Seat.Row2.Pos1.IsBelted' ) {
                    if (value === "true") {
                        valueSource.is_Seat_Row2_Pos1_IsBelted = true
                    } else if (value === "false") {
                        valueSource.is_Seat_Row2_Pos1_IsBelted = false
                    }
                } else if ( path === 'Vehicle.Cabin.Seat.Row2.Pos2.IsBelted' ) {
                    if (value === "true") {
                        valueSource.is_Seat_Row2_Pos2_IsBelted = true
                    } else if (value === "false") {
                        valueSource.is_Seat_Row2_Pos2_IsBelted = false
                    }
                }

                if (valueSource.is_Seat_Row1_Pos1_IsBelted && 
                    valueSource.is_Seat_Row1_Pos2_IsBelted && 
                    valueSource.is_Seat_Row2_Pos1_IsBelted &&
                    valueSource.is_Seat_Row2_Pos2_IsBelted ) {
                        valueSource.is_Seat_NotIsBelted = false
                } else{
                        valueSource.is_Seat_NotIsBelted = true
                }

            } else if (path === 'Vehicle.Body.Lights.IsHighBeamOn' ||
                       path === 'Vehicle.Body.Lights.IsLowBeamOn' ) {
                if ( path === 'Vehicle.Body.Lights.IsHighBeamOn' ) {
                    if (value === "true") {
                        valueSource.is_HighBeamOn = true
                    } else if (value === "false") {
                        valueSource.is_HighBeamOn = false
                    }
                } else if ( path === 'Vehicle.Body.Lights.IsLowBeamOn' ) {
                    if (value === "true") {
                        valueSource.is_LowBeamOn = true
                    } else if (value === "false") {
                        valueSource.is_LowBeamOn = false
                    }
                }

                if (valueSource.is_HighBeamOn || 
                    valueSource.is_LowBeamOn ) {
                        valueSource.is_BeamOn = true
                } else{
                        valueSource.is_BeamOn = false
                }
            } else if (path === 'Vehicle.Cabin.Door.Row1.Left.IsOpen' ||
                       path === 'Vehicle.Cabin.Door.Row1.Right.IsOpen' ||
                       path === 'Vehicle.Cabin.Door.Row2.Left.IsOpen' ||
                       path === 'Vehicle.Cabin.Door.Row2.Right.IsOpen') {
                if ( path === 'Vehicle.Cabin.Door.Row1.Left.IsOpen' ) {
                    if (value === "true") {
                        valueSource.is_Row1_Left_IsOpen = true
                    } else if (value === "false") {
                        valueSource.is_Row1_Left_IsOpen = false
                    }
                } else if ( path === 'Vehicle.Cabin.Door.Row1.Right.IsOpen' ) {
                    if (value === "true") {
                        valueSource.is_Row1_Right_IsOpen = true
                    } else if (value === "false") {
                        valueSource.is_Row1_Right_IsOpen = false
                    }
                } else if ( path === 'Vehicle.Cabin.Door.Row2.Left.IsOpen' ) {
                    if (value === "true") {
                        valueSource.is_Row2_Left_IsOpen = true
                    } else if (value === "false") {
                        valueSource.is_Row2_Left_IsOpen = false
                    }
                } else if ( path === 'Vehicle.Cabin.Door.Row2.Right.IsOpen' ) {
                    if (value === "true") {
                        valueSource.is_Row2_Right_IsOpen = true
                    } else if (value === "false") {
                        valueSource.is_Row2_Right_IsOpen = false
                    }
                }

                if (valueSource.is_Row1_Left_IsOpen || 
                    valueSource.is_Row1_Right_IsOpen || 
                    valueSource.is_Row2_Left_IsOpen ||
                    valueSource.is_Row2_Right_IsOpen ) {
                        valueSource.is_Door_IsOpen = true
                } else {
                        valueSource.is_Door_IsOpen = false
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
