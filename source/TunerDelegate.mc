import Toybox.Lang;
import Toybox.WatchUi;

class TunerDelegate extends WatchUi.BehaviorDelegate {
    private var _model as TunerModel;

    function initialize(model as TunerModel) {
        BehaviorDelegate.initialize();
        _model = model;
    }

    function onNextPage() as Boolean {
        _model.step(1);
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        _model.step(-1);
        WatchUi.requestUpdate();
        return true;
    }

    // START (upper right) / tap: settings menu.
    function onSelect() as Boolean {
        return openMenu();
    }

    // Long-press UP / MENU: same menu.
    function onMenu() as Boolean {
        return openMenu();
    }

    private function openMenu() as Boolean {
        var menu = new WatchUi.Menu2({ :title => "Tuner" });
        menu.addItem(new WatchUi.MenuItem("Guitar tunings", null, :guitar, {}));
        menu.addItem(new WatchUi.MenuItem("Other instruments", null, :other, {}));
        menu.addItem(new WatchUi.MenuItem("Show note only", "Any instrument", :chromatic, {}));
        menu.addItem(new WatchUi.MenuItem("Auto string", _model.autoString ? "On" : "Off", :auto, {}));
        menu.addItem(new WatchUi.MenuItem("Vibrate in tune", _model.haptic ? "On" : "Off", :vibe, {}));
        menu.addItem(new WatchUi.MenuItem("Play tone", "Experimental", :tone, {}));
        menu.addItem(new WatchUi.MenuItem("Demo needle", _model.demo ? "On" : "Off", :demo, {}));
        WatchUi.pushView(menu, new MainMenuDelegate(_model), WatchUi.SLIDE_UP);
        return true;
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _model as TunerModel;

    function initialize(model as TunerModel) {
        Menu2InputDelegate.initialize();
        _model = model;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :guitar) {
            pushPresets("Guitar tunings", Instruments.guitarPresets());
            return;
        } else if (id == :other) {
            pushPresets("Instruments", Instruments.otherPresets());
            return;
        } else if (id == :chromatic) {
            _model.setChromatic();
        } else if (id == :auto) {
            _model.setAutoString(!_model.autoString);
        } else if (id == :vibe) {
            _model.haptic = !_model.haptic;
        } else if (id == :tone) {
            ToneGenerator.play(_model.chromatic ? _model.a4 : _model.targetFreq());
        } else if (id == :demo) {
            _model.setDemo(!_model.demo);
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    private function pushPresets(title as String, list as Array<Number>) as Void {
        var menu = new WatchUi.Menu2({ :title => title });
        var names = Instruments.names();
        for (var i = 0; i < list.size(); i++) {
            menu.addItem(new WatchUi.MenuItem(names[list[i]], null, list[i], {}));
        }
        WatchUi.pushView(menu, new PresetMenuDelegate(_model), WatchUi.SLIDE_LEFT);
    }
}

class PresetMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _model as TunerModel;

    function initialize(model as TunerModel) {
        Menu2InputDelegate.initialize();
        _model = model;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        _model.setPreset(item.getId() as Number);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
