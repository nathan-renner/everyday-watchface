import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time.Gregorian as Date;
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
    var showDate = true;
    var isMilitaryTime = false;
    private var fontlg, fontsm, screenWidth, fieldRadius, fieldPenWidth;

    function initialize() {
        WatchFace.initialize();
        
        colors = themes.get(Props.getValue("ThemeColor"));
        numOfFields = Props.getValue("NumOfFields");
        showDate = Props.getValue("ShowDate");
        isMilitaryTime = Props.getValue("UseMilitaryFormat");
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

        // Refresh if settings are updated
        colors = themes.get(Props.getValue("ThemeColor"));
        numOfFields = Props.getValue("NumOfFields");
        showDate = Props.getValue("ShowDate");
        isMilitaryTime = Props.getValue("UseMilitaryFormat");

        drawClock(dc);
        drawFields(dc);
    }

    private function drawClock (dc) {
        var dateString = getDateString();
        var time = getTime();
        var extra = 16;
        var timeY = 24;
        var dateY = 36;
        if (numOfFields == 6) {
            timeY = 0;
            dateY = 12;
        } else if (numOfFields == 2) {
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

    private function getTime() {
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

    private function drawFields(dc) {
        drawField(dc, true);
        drawField(dc, false);
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
