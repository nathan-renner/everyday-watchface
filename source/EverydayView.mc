import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Activity;
using Toybox.System;
using Toybox.Time.Gregorian as Date;
using Toybox.Application.Properties as Props;
using Toybox.ActivityMonitor as AM;
using Toybox.SensorHistory;
using Toybox.Weather;

var themes as Dictionary<Number, Array<Number>> = {
    0 => [0xFF6FA6, 0x331621],
    1 => [0xFF3131, 0x330A0A],
    2 => [0xFD6C2E, 0x331609],
    3 => [0xDBFF00, 0x2C3300],
    4 => [0x5EF1C5, 0x133027],
    5 => [0x42FF00, 0x0D3300],
    6 => [0x2EF0FD, 0x093033],
    7 => [0x316BFF, 0x0A1533],
    8 => [0xC72EFD, 0x280933],
    9 => [Graphics.COLOR_LT_GRAY, Graphics.COLOR_DK_GRAY]
};

const NULL_PLACEHOLDER as String = "--";

class EverydayView extends WatchUi.WatchFace {
    var inLowPower = false;
    var canBurnIn = false;
    var colors as Array<Number> = themes.get(0);
    var numOfFields as Number = 6;
    var tempUnit as Number = 0;
    var showDate as Boolean = true;
    var isMilitaryTime as Boolean = false;
    var fields as Dictionary<Number, Number> = {
        1 => 7,
        2 => 11,
        3 => 8,
        4 => 9,
        5 => 3,
        6 => 1,
    };
    var isSquare = System.getDeviceSettings().screenShape == 3;
    private var fontlg, fontmd, fontsm, screenHeight, screenWidth, fieldRadius, fieldPenWidth, iconsSm, iconsLg;

    function initialize() {
        WatchFace.initialize();
        
        var settings = System.getDeviceSettings();
        if (settings has :requiresBurnInProtection) {
            canBurnIn = settings.requiresBurnInProtection;
        }

        colors = themes[Props.getValue("ThemeColor")];
        numOfFields = Props.getValue("NumOfFields");
        tempUnit = Props.getValue("TemperatureUnit");
        showDate = Props.getValue("ShowDate");
        isMilitaryTime = Props.getValue("UseMilitaryFormat");
        fields = {
            1 => Props.getValue("DataField1"),
            2 => Props.getValue("DataField2"),
            3 => Props.getValue("DataField3"),
            4 => Props.getValue("DataField4"),
            5 => Props.getValue("DataField5"),
            6 => Props.getValue("DataField6"),
        };
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        screenHeight = dc.getHeight();
        screenWidth = dc.getWidth();
        fieldRadius = isSquare ? screenWidth * 0.14 : screenWidth * 0.1125;
        fieldPenWidth = fieldRadius * 0.167;

        loadFonts();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        loadFonts();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Refresh if settings are updated
        colors = themes.get(Props.getValue("ThemeColor"));
        numOfFields = Props.getValue("NumOfFields");
        tempUnit = Props.getValue("TemperatureUnit");
        showDate = Props.getValue("ShowDate");
        isMilitaryTime = Props.getValue("UseMilitaryFormat");
        fields = {
            1 => Props.getValue("DataField1"),
            2 => Props.getValue("DataField2"),
            3 => Props.getValue("DataField3"),
            4 => Props.getValue("DataField4"),
            5 => Props.getValue("DataField5"),
            6 => Props.getValue("DataField6"),
        };

        if (inLowPower && canBurnIn) {
            drawClock(dc);
        } else {
            drawClock(dc);
            drawFields(dc);
        }
    }

    private function loadFonts() {
        var fonts = Rez.Fonts;
        fontlg = WatchUi.loadResource(numOfFields == 2 ? fonts.xl : fonts.lg) as BitmapResource;
        fontsm = WatchUi.loadResource(fonts.sm) as BitmapResource;
        iconsSm = WatchUi.loadResource(fonts.iconsSm) as BitmapResource;
        iconsLg = WatchUi.loadResource(fonts.iconsLg) as BitmapResource;

        if (canBurnIn && fonts has :md) {
            fontmd = WatchUi.loadResource(fonts.md) as BitmapResource;
        }
    }

    private function drawClock (dc as Dc) {
        var dateString = getDateString();
        var time = getTime();
        var colorMain = Graphics.COLOR_WHITE;
        var colorAccent = colors[0];

        var multiplier = isSquare ? (screenHeight * 0.01).toNumber() : (screenHeight * 0.03).toNumber();
        var timeY = multiplier;
        var dateY = (multiplier * 1.8).toNumber();

        if (isSquare ? numOfFields > 3 : numOfFields == 6) {
            timeY = (multiplier * -0.3).toNumber();
            dateY = isSquare ? (multiplier * 0.9).toNumber() : multiplier;
        } else if (numOfFields <= 3) {
            timeY += isSquare ? multiplier * 4 : multiplier * 2;
            dateY += isSquare ? multiplier * 4 : multiplier * 2;
        }

        if (inLowPower && canBurnIn) {
            colorMain = Graphics.COLOR_LT_GRAY;
            colorAccent = Graphics.COLOR_LT_GRAY;
            timeY = screenHeight / 4;
            dateY = screenHeight / 4 + multiplier;
        }

        if (showDate == true) {
            dc.setColor(colorMain, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, dateY, fontsm, dateString, Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(colorMain, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2, timeY, inLowPower && canBurnIn ? fontmd : fontlg, time[0], Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2, timeY, inLowPower && canBurnIn ? fontmd : fontlg, time[1], Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function getTime() as Array<String>  {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;      
        if (!isMilitaryTime) {
            hour %= 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        hour = hour.format("%02d");

        return [hour, clockTime.min.format("%02d")];
    }

    private function getDateString() {
        var today = Date.info(Time.now(), Time.FORMAT_MEDIUM);

        return Lang.format("$1$ $2$", [today.day_of_week.substring(0, 3).toUpper(), today.day]);
    }

   private function getFieldData (fieldNum as Number) {
        if (fieldNum == 0) {
            var AMInfo = AM.getInfo();
            var total = AMInfo.activeMinutesWeek.total;
            var goal = AMInfo.activeMinutesWeekGoal;
            
            return [total == 0 ? 0 : total > goal ? 1 : 1.0 * total / goal, "A"];
        } 
        else if (fieldNum == 1) {
            return [1.0 * System.getSystemStats().battery / 100, "B"];
        } 
        else if (fieldNum == 2) {
            return [System.getDeviceSettings().phoneConnected ? "ON" : "OFF", "C"];
        } 
        else if (fieldNum == 3) {
            if (
                !(Toybox has :SensorHistory && 
                Toybox.SensorHistory has :getBodyBatteryHistory)
            ) {
                return [NULL_PLACEHOLDER, "D"];
            }

            var bb = Toybox.SensorHistory.getBodyBatteryHistory({});
            bb = bb.next();

            if (bb != null) {
                return [1.0 * bb.data / 100, "D"];
            }

            return [NULL_PLACEHOLDER, "D"];
        } 
        else if (fieldNum == 4) {
            return [Date.info(Time.now(), Time.FORMAT_MEDIUM).day, "E"];
        } 
        else if (fieldNum == 5) {
            var AMInfo = AM.getInfo();
            if (!(AMInfo has :floorsClimbed)) {
                return [NULL_PLACEHOLDER, "F"];
            }
            var floors = AMInfo.floorsClimbed;
            var floorsGoal = AMInfo.floorsClimbedGoal;
            return [floors == 0 ? 0 : floors > floorsGoal ? 100 : 1.0 * floors / floorsGoal, "F"];
        } 
        else if (fieldNum == 6) {
            var hr = Activity.getActivityInfo().currentHeartRate;

            return [hr == null ? NULL_PLACEHOLDER : hr, "G"];
        } 
        else if (fieldNum == 7) {
            return [System.getDeviceSettings().notificationCount, "H"];
        } 
        else if (fieldNum == 8) {
            var AMInfo = AM.getInfo();
            var steps = AMInfo.steps;
            var stepGoal = AMInfo.stepGoal;
            return [steps == 0 ? 0 : steps > stepGoal ? 100 : 1.0 * steps / stepGoal, "J"];
        } 
        else if (fieldNum == 9) {
            if (
                !(Toybox has :SensorHistory && 
                Toybox.SensorHistory has :getStressHistory)
            ) {
                return [NULL_PLACEHOLDER, "K"];
            }

            var stress = Toybox.SensorHistory.getStressHistory({});
            stress = stress.next();

            if (stress != null) {
                return [stress.data.format("%02d"), "K"];
            }

            return [NULL_PLACEHOLDER, "K"];
        } 
        else if (fieldNum == 10) {
            if (!(AM.getInfo() has :timeToRecovery)) {
                return [NULL_PLACEHOLDER, "I"];
            }
            var time = AM.getInfo().timeToRecovery;
            return [time == null ? 0 : time, "I"];
        } 
        else if (fieldNum == 11) {
            var conditions = Weather.getCurrentConditions();

            if (conditions == null) {
                return [NULL_PLACEHOLDER, "P"];
            }

            var temp = conditions.temperature;
            var c = conditions.condition;
            var icon;

            if (temp == null) {
                return [NULL_PLACEHOLDER, "P"];
            }
                
            if (tempUnit == 0) {
                temp = (1.0 * temp * 9 / 5 + 32).toNumber();
            }

            if (c == 0 || c == 23) {
                // sunny
                icon = "P";
            } else if (c == 1 || c == 22 || c == 52) {
                // partly cloudy
                icon = "M";
            } else if (c == 2 || c == 5 || c == 8 || c == 20 || c == 40) {
                // cloudy
                icon = "L";
            } else if (c == 4 || c == 7 || c == 16 || c == 17 || c == 18 || c == 19 || c == 21 || c == 34 || c == 43 || c == 44 || c == 45 || c == 46 || c == 46 || c == 48 || c == 49 || c == 50 || c == 51) {
                // snow
                icon = "O";
            } else if (c == 6 || c == 11 || c == 12 || c == 28 || c == 32) {
                // thunderstorm
                icon = "Q";
            } else {
                // raining
                icon = "N";
            }
            return [temp.format("%d") + "°", icon];
        }
        else {
            return [NULL_PLACEHOLDER];
        }
    }

    private function drawField (dc as Dc, x as Number, y as Number, fieldNum as Number) {
        var f = fields[fieldNum];
        var data = getFieldData(f) as Array;
        var buffer = (screenHeight * 0.025).toNumber();

        if (f == 0 || f == 1 || f == 3 || f == 5 || f == 8) {
            dc.setPenWidth(fieldPenWidth);
            dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(x, y, fieldRadius - fieldPenWidth / 2, Graphics.ARC_CLOCKWISE, 0, 0);

            dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y - fieldRadius / 2, iconsLg, data[1], Graphics.TEXT_JUSTIFY_CENTER);

            if (data[0] != 0 && data[0] != NULL_PLACEHOLDER) {
                dc.drawArc(x, y, fieldRadius - fieldPenWidth / 2, Graphics.ARC_CLOCKWISE, 90, 360 * (1 - data[0]) + 90);
            }
        } else {
            dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, fieldRadius);

            dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y - fieldRadius / 2 - buffer, iconsSm, data[1], Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y - fieldRadius / 2 + buffer, fontsm, data[0], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    private function drawFields(dc as Dc) {
        var layout = [];

        if (numOfFields == 2) {
            layout = [2, 0];
        } else if (numOfFields == 3) {
            layout = [3, 0];
        } else if (numOfFields == 4) {
            layout = [2, 2];
        } else if (numOfFields == 5) {
            layout = [3, 2];
        } else {
            layout = [3, 3];
        }

        var gap = (screenWidth * 0.04).toNumber();
        var topRowY = (screenHeight * 0.53).toNumber();

        if (isSquare && numOfFields > 3 || !isSquare && numOfFields == 6) {
            topRowY -= (screenHeight * 0.05).toNumber();
        } else if (numOfFields <= 3) {
            topRowY += (screenHeight * 0.077).toNumber();
        }
        var bottomRowY = topRowY + fieldRadius * 2 + gap;
        var middle = screenWidth / 2;

        for (var i = 0; i < layout.size(); i++) {
            var rowY = i == 0 ? topRowY : bottomRowY;
            var rowX = middle;
            if (layout[i] == 3) {
                rowX = middle - fieldRadius * 2 - gap;
            } else if (layout[i] == 2) {
                rowX = middle - fieldRadius - gap / 2;
            }
            for (var j = 1; j <= layout[i]; j++) {
                var fieldX = rowX;
                if (j == 2) {
                    fieldX = rowX + (fieldRadius + gap / 2) * j;
                } else if (j == 3) {
                    fieldX = rowX + (fieldRadius * 2 + gap) * 2;
                }
                drawField(dc, fieldX, rowY, (i * layout[0]) + j);
            }
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        fontlg = null;
        fontsm = null;
        iconsSm = null;
        iconsLg = null;
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {    
        inLowPower = false;
    	WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        inLowPower = true;
    	WatchUi.requestUpdate(); 
    }

}
