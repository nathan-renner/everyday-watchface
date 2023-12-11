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
    1 => [0xFD6C2E, 0x331609],
    2 => [0xDBFF00, 0x2C3300],
    3 => [0x42FF00, 0x0D3300],
    4 => [0x2EF0FD, 0x093033],
    5 => [0xC72EFD, 0x280933],
};

var layouts as Dictionary<Number, Array<Number>> = {
    2 => [2],
    3 => [3],
    4 => [2, 2],
    5 => [3, 2],
    6 => [3, 3],
};

var solidFields = [2, 5, 7, 8, 10, 11];

var NULL_PLACEHOLDER as String = "--";

class EverydayView extends WatchUi.WatchFace {
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

    private var fontlg, fontsm, screenWidth, fieldRadius, fieldPenWidth;

    function initialize() {
        WatchFace.initialize();
        
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
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        screenWidth = dc.getWidth();
        fieldRadius = screenWidth * 0.225 / 2;
        fieldPenWidth = fieldRadius * 0.167;

        var fonts = Rez.Fonts;
        fontlg = WatchUi.loadResource(numOfFields == 2 ? fonts.xl : fonts.lg) as BitmapResource;
        fontsm = WatchUi.loadResource(fonts.sm) as BitmapResource;
        // var draw = Rez.Drawables;
        // steps = WatchUi.loadResource(draw.StepsIconPink);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
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

        // dc.setColor(colors[0], Graphics.COLOR_BLUE);
        // dc.drawBitmap(100, 100, steps);

        drawClock(dc);
        drawFields(dc);
    }

    private function drawClock (dc as Dc) {
        var dateString = getDateString();
        var time = getTime();
        var extra = 16;
        var timeY = 12;
        var dateY = 24;
        if (numOfFields == 6) {
            timeY = 0;
            dateY = 12;
        } else if (numOfFields <= 3) {
            timeY += extra;
            dateY += extra;
        }

        if (showDate == true) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, dateY, fontsm, dateString, Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2, timeY, fontlg, time[0], Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2, timeY, fontlg, time[1], Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function getTime () as Array<String>  {
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

    private function drawFields(dc as Dc) {
        var layout = layouts[numOfFields];
        var gap = 15;
        var topRowY = 208;

        if (numOfFields == 6) {
            topRowY -= 18;
        } else if (numOfFields <= 3) {
            topRowY += 30;
        }
        var bottomRowY = topRowY + fieldRadius * 2 + gap;
        var middle = screenWidth / 2;
        // var fieldAndGap = fieldRadius + gap;

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

    private function getFieldData (fieldNum as Number) {
        var AMInfo = AM.getInfo();
        switch (fieldNum) {
            case 0:
                var total = AMInfo.activeMinutesWeek.total;
                var goal = AMInfo.activeMinutesWeekGoal;
                return total == 0 ? 0 : total > goal ? 1 : 1.0 * total / goal;
            case 1:
                return 1.0 * System.getSystemStats().battery / 100;
            case 2:
                return System.getDeviceSettings().phoneConnected ? "ON" : "OFF";
            case 3:
                var bb = null;
                if (
                    Toybox has :SensorHistory && 
                    Toybox.SensorHistory has :getBodyBatteryHistory
                ) {
                    bb = Toybox.SensorHistory.getBodyBatteryHistory({});
                } else {
                    return NULL_PLACEHOLDER;
                }

                bb = bb.next();

                if (bb != null) {
                    return 1.0 * bb.data / 100;
                }

                return NULL_PLACEHOLDER;
            case 4:
                return 0; // not sure how to do total calories yet
            case 5: 
                return Date.info(Time.now(), Time.FORMAT_MEDIUM).day;
            case 6:
                if (!(AMInfo has :floorsClimbed)) {
                    return NULL_PLACEHOLDER;
                }
                var floors = AMInfo.floorsClimbed;
                var floorsGoal = AMInfo.floorsClimbedGoal;
                return floors == 0 ? 0 : floors > floorsGoal ? 100 : 1.0 * floors / floorsGoal;
            case 7:
                var hr = Activity.getActivityInfo().currentHeartRate;
                System.println(hr);
                return hr == null ? NULL_PLACEHOLDER : hr;
            case 8:
                return System.getDeviceSettings().notificationCount;
            case 9:
                var steps = AMInfo.steps;
                var stepGoal = AMInfo.stepGoal;
                return steps == 0 ? 0 : steps > stepGoal ? 100 : 1.0 * steps / stepGoal;
            case 10:
                var stress = null;
                if (
                    Toybox has :SensorHistory && 
                    Toybox.SensorHistory has :getStressHistory
                ) {
                    stress = Toybox.SensorHistory.getBodyBatteryHistory({});
                } else {
                    return NULL_PLACEHOLDER;
                }

                stress = stress.next();

                if (stress != null) {
                    return (1.0 * stress.data / 100).toNumber();
                }

                return NULL_PLACEHOLDER;
            case 11:
                var temp = Weather.getCurrentConditions().temperature;
                
                if (tempUnit == 0) {
                    temp = 1.0 * temp * 9 / 5 + 32;
                }

                return Lang.format("$1$°",[temp.format("%d")]);
            default: 
                return NULL_PLACEHOLDER;
        }
    }

    private function drawField (dc as Dc, x as Number, y as Number, fieldNum as Number) {
        var field = fields[fieldNum];
        var data = getFieldData(field);
        
        if (solidFields.indexOf(field) != -1) {
            dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, fieldRadius);

            dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y - fieldRadius / 2 + 5, fontsm, data, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setPenWidth(fieldPenWidth);
            dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(x, y, fieldRadius - fieldPenWidth / 2, Graphics.ARC_CLOCKWISE, 0, 0);

            if (data != 0 && data != NULL_PLACEHOLDER) {
                dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
                dc.drawArc(x, y, fieldRadius - fieldPenWidth / 2, Graphics.ARC_CLOCKWISE, 90, 360 * (1 - data) + 90);
            }
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
