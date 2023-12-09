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
    private var font, fieldWidth;

    function initialize() {
        WatchFace.initialize();
        
        colors = themes.get(Props.getValue("ThemeColor"));
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        fieldWidth = dc.getWidth() * 0.225;

        var fonts = Rez.Fonts;
        font = WatchUi.loadResource(fonts.pt72);
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

        dc.setColor(colors[0], Graphics.COLOR_TRANSPARENT);
        dc.drawText(100, 100, font, "MON MON MON", Graphics.TEXT_JUSTIFY_CENTER);
        // drawField(dc);
    }

    // private function drawField (dc) {
    //     dc.setColor(colors[1], Graphics.COLOR_TRANSPARENT);
    //     dc.fillCircle(100, 100, fieldWidth / 2);


    // }

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
