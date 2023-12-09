import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Application.Properties as Props;

class EverydayView extends WatchUi.WatchFace {
    var themes = {
        0 => [0xFF6FA6, 0x331621],
        1 => [0xFD6C2E, 0x331609],
        2 => [0xDBFF00, 0x2C3300],
        3 => [0x42FF00, 0x0D3300],
        4 => [0x2EF0FD, 0x093033],
        5 => [0xC72EFD, 0x280933],
    };
    var colors = themes.get(0) as Array;
    var numOfFields = 6;
    private var fontlg, fontsm, screenWidth, fieldRadius, fieldPenWidth;

    function initialize() {
        WatchFace.initialize();
        
        colors = themes.get(Props.getValue("ThemeColor"));
        numOfFields = Props.getValue("NumOfFields");
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        screenWidth = dc.getWidth();
        fieldRadius = screenWidth * 0.225 / 2;
        fieldPenWidth = fieldRadius * 0.167;

        var fonts = Rez.Fonts;
        fontlg = WatchUi.loadResource(numOfFields == 2 ? fonts.xl : fonts.lg);
        fontsm = WatchUi.loadResource(fonts.sm);
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

        colors = themes.get(Props.getValue("ThemeColor"));
        numOfFields = Props.getValue("NumOfFields");

        // Get the current time and format it correctly
        // var timeFormat = "$1$$2$";
        // var clockTime = System.getClockTime();
        // var hours = clockTime.hour;
        // if (!System.getDeviceSettings().is24Hour) {
        //     if (hours > 12) {
        //         hours = hours - 12;
        //     }
        // } else {
        //     if (Props.getValue("UseMilitaryFormat")) {
        //         timeFormat = "$1$$2$";
        //         hours = hours.format("%02d");
        //     }
        // }
        // var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        drawClock(dc);
        drawField(dc, true);
        drawField(dc, false);
    }

    private function drawClock (dc) {
        var extra = 16;
        var timeY = 24;
        if (numOfFields == 6) {
            timeY = 0;
        } else if (numOfFields == 2) {
            timeY += extra;
        }

        if (numOfFields != 6) {
            var dateY = 36;
            if (numOfFields == 2) {
                dateY += extra;
            }

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenWidth / 2, dateY, fontsm, "THU 24", Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2, timeY, fontlg, "09", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenWidth / 2, timeY, fontlg, "24", Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function drawField (dc, isSolid) {
        if (isSolid) {
            dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(200, 250, fieldRadius);
        } else {
            dc.setPenWidth(fieldPenWidth);
            dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(100, 250, fieldRadius - fieldPenWidth / 2, Graphics.ARC_CLOCKWISE, 0, 0);

            dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(100, 250, fieldRadius - fieldPenWidth / 2, Graphics.ARC_CLOCKWISE, 90, 180);
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
