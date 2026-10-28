import Toybox.Attention;
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

    // Tap: next string (consumed here so it doesn't trigger onSelect's tone).
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        _model.step(1);
        WatchUi.requestUpdate();
        return true;
    }

    // START: play the reference tone for the selected string.
    function onSelect() as Boolean {
        if (Attention has :playTone) {
            var f = _model.targetFreq().toNumber();
            Attention.playTone({ :toneProfile => [new Attention.ToneProfile(f, 1500)] });
        }
        return true;
    }

    // Long-press UP / MENU: instrument picker.
    function onMenu() as Boolean {
        var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.PresetsTitle) });
        var names = Instruments.names();
        for (var i = 0; i < names.size(); i++) {
            menu.addItem(new WatchUi.MenuItem(names[i], null, i, {}));
        }
        var demoLabel = WatchUi.loadResource(Rez.Strings.DemoMode);
        var state = _model.demo ? WatchUi.loadResource(Rez.Strings.DemoOn) : WatchUi.loadResource(Rez.Strings.DemoOff);
        menu.addItem(new WatchUi.MenuItem(demoLabel, state, :demo, {}));
        WatchUi.pushView(menu, new PresetMenuDelegate(_model), WatchUi.SLIDE_UP);
        return true;
    }
}

class PresetMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _model as TunerModel;

    function initialize(model as TunerModel) {
        Menu2InputDelegate.initialize();
        _model = model;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :demo) {
            _model.setDemo(!_model.demo);
        } else {
            _model.setPreset(id as Number);
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
