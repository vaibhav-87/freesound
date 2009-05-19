package ui {	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.Sprite;	import flash.events.MouseEvent;	import flash.text.AntiAliasType;	import flash.text.TextField;	import flash.text.TextFormat;	import flash.text.TextFormatAlign;		/**     * @author bram     */    public class LargeSoundDisplay extends Sprite implements ISoundDisplay    {        private var _observers : Vector.<ISoundDisplayObserver>;        private var _playing : Sprite;        private var _mapping : Vector.<Number>;        private var _background : SwappingBackground;        private var _timeDisplay : TimeDisplay;        private var _playerControls : LargePlayerControls;        private var _measureReadout : TextField;        private var _measureReadoutSprite : Sprite;        private var _showMeasureReadout : Boolean;        private var _width : int;        private var _height : int;                private var _latestX:Number, _latestY:Number;        public function LargeSoundDisplay(width : int, height : int, waveformUrl : String, spectralUrl : String, duration : Number)        {            _width = width;            _height = height;            _latestX = _latestY = 0;        	            createMapping(height);        	            _observers = new Vector.<ISoundDisplayObserver>();            _background = new SwappingBackground(width, height, waveformUrl, spectralUrl);            addChild(_background);                        _playing = new Sprite();            _playing.graphics.lineStyle(2, 0xffffff, 0.7);            _playing.graphics.moveTo(0, 0);            _playing.graphics.lineTo(0, height - 1);            _playing.visible = false;            addChild(_playing);        	            _timeDisplay = new TimeDisplay();            _timeDisplay.x = width - _timeDisplay.width;            _timeDisplay.y = height - _timeDisplay.height; 			_timeDisplay.duration = duration;            addChild(_timeDisplay);        	            _playerControls = new LargePlayerControls();            _playerControls.y = height - _playerControls.getMaxHeight();            addChild(_playerControls);                        _measureReadoutSprite = new Sprite();            _measureReadoutSprite.graphics.beginFill(0, 0.5);			_measureReadoutSprite.graphics.lineStyle(1, 0x707070, 0.5);			_measureReadoutSprite.graphics.drawRoundRect(0, 0 ,140, 16, 3, 3);            addChild(_measureReadoutSprite);                        _measureReadout = new TextField();			_measureReadout.defaultTextFormat = new TextFormat("VeraMono", 10, 0xffffff, null, null, null, null, null, TextFormatAlign.LEFT);			_measureReadout.embedFonts = true;            _measureReadout.antiAliasType = AntiAliasType.ADVANCED;			_measureReadout.height = 14;            _measureReadout.width = 140;			_measureReadout.x = 2;			_measureReadout.y = 1;            _measureReadoutSprite.addChild(_measureReadout);            _measureReadoutSprite.visible = false;            			            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);        }        public function measureReadout(on : Boolean) : void        {            _showMeasureReadout = on;            _measureReadoutSprite.visible = on;                        if (on)                addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);        	else                removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);        }        public function onMouseDown(e : MouseEvent) : void        {			_latestX = e.stageX;			_latestY = e.stageY;            for each (var observer:ISoundDisplayObserver in _observers)            	observer.onSoundDisplayClick(this, e.stageX / _width);        }        public function onMouseOver(e : MouseEvent) : void        {			_latestX = e.stageX;			_latestY = e.stageY;    		_measureReadoutSprite.visible = _showMeasureReadout;        }        public function onMouseOut(e : MouseEvent) : void        {			_latestX = e.stageX;			_latestY = e.stageY;    		_measureReadoutSprite.visible = false;        }                public function updateMeasureDisplay():void        {        	onMouseMove();        }        public function onMouseMove(e : MouseEvent = null) : void        {        	if (e)        	{				_latestX = e.stageX;				_latestY = e.stageY;        	}        				if (_measureReadoutSprite.visible)			{				var padding: int = 10;								_measureReadoutSprite.x = _latestX + padding;	            _measureReadoutSprite.y = _latestY + padding;	        		            if (_measureReadoutSprite.y + _measureReadoutSprite.height + padding > _height)	        		_measureReadoutSprite.y = _latestY - padding*2;	        		            if (_measureReadoutSprite.x + _measureReadoutSprite.width +padding > _width)	        		_measureReadoutSprite.x = _latestX - (_measureReadoutSprite.width + padding);		            var readout:String;	            	            if (_background.getCurrentDisplay() == SwappingBackground.ID_SPECTRAL)	            {	            	readout = _mapping[int(_latestY)].toFixed(2) + "hz";	            }	            else	            {	            	if (_latestY == _height/2)	            	{	            		readout = "-inf db";	            	}	            	else	            	{	            		var lin:Number = Math.abs((_latestY - _height/2)/(_height/2));		            	var db:Number = 20 * Math.log(lin) * Math.LOG10E;		            	readout = db.toFixed(2) + "db";	            	}	            }	            	            readout += " " + TimeDisplay.timeToString((_timeDisplay.duration * _latestX)/_width);	            	            _measureReadout.text = readout;			}        }        public function setLoading(procent : Number) : void        {            _background.setLoadProgress(procent);        }        public function setPlaying(procent : Number, time : Number) : void        {            _timeDisplay.update(time);        	            if (procent == 0 && time == 0)            {                _playing.visible = false;                return;            }        	            _playing.visible = true;            if (procent >= 0 && procent < 1)                _playing.x = _width * procent;            else                _playing.x = 0;        }        public function setWaveformBackground() : void        {            _background.setWaveformImage();        }        public function setSpectralBackground() : void        {            _background.setSpectralImage();        }        public function setSoundDuration(duration : Number) : void        {            _timeDisplay.duration = duration;        }        public function setPlayButtonState(playing : Boolean) : void        {            _playerControls.setPlayButtonState(playing);        }        public function addSoundDisplayObserver(observer : ISoundDisplayObserver) : void        {            _observers.push(observer);        }        public function addPlayerControlsObserver(observer : IPlayerControlsObserver) : void        {            _playerControls.addPlayerControlsObserver(observer);        }        private function createMapping(height : int) : void        {            _mapping = new Vector.<Number>();    		            var y_min : Number = Math.log(100.0) * Math.LOG10E;            var y_max : Number = Math.log(22050.0) * Math.LOG10E;	                    for (var y : int = height - 1;y >= 0; y--)            {                var freq : Number = Math.pow(10.0, y_min + y / (height - 1.0) * (y_max - y_min));                _mapping.push(freq);            }        }        public function displayErrorMessage(message : String) : void        {            var tmp : Bitmap = new Bitmap(new BitmapData(message.length * 8, 35, true, 0x00000000));            DText.draw(tmp.bitmapData, message, 0, 0, DText.LEFT);            tmp.x = 50;            tmp.y = 50;            addChild(tmp);        }    }}