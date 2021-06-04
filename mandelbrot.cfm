<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
	<script>
/**
 * Render the mandelbrot fractal using canvas
 * 
 * TODO:
 * 
 * DONE: Allow use to change saturation and lightness
 * DONE: switch between color / b&w
 * DONE: Rotate the canvas
 * DONE: Add render loader
 * DONE: Restyle form layout
 * DONE: allow user to adjust the width / height?
 * DONE: Screenshot and create links to that render
 * DONE: Can user adjust the hue some how?
 * 
 * Use web workers
 */
var settings;

var mandelbrot = function(){
	//Grab our canvas element
	var canvasElement = document.getElementById("output").getContext('2d');
	var xInput = document.getElementById("Xinput");
	var yInput = document.getElementById("Yinput");
	var zInput = document.getElementById("Zinput");
	var status = document.getElementById("status");
	
	var colorArray = [];
	
	//Our settings
	settings = {
		width: 600,
		height: 600,
		//Striped render settings (faster)
		step: 10,
		blockx: 0,//Block of X values we are currenty on
		blockwidth: 10,//width of a rectangle (always height of 1)
		iterations: 1000,
		xs: 0,//X Position of currently rendered strip
		cx: 0,//Center X
		cy: 0,//Center Y
		cz: 150,//Center Z
		//Notify when done
		done: true,
		//Initial Mouse position
		posx: 0,
		posy: 0,
		color: false,
		rotation: "none",
		hueOne: 60,
		hueTwo: 190,
		saturation: 95,
		lightness: 80
	};
	
	return {
		//Begin generation
		begin: function(){
			//Set canvas width / height
			$("#output").attr({
				width: settings.width,
				height: settings.height
			});
			
			//Grab our values
			xInput.value = settings.cx;
			yInput.value = settings.cy;
			zInput.value = settings.cz;
			
			//Status to rendering
			status.innerHTML = "<span>Pass 1 Rendering</span>";
			
			//I see a Canvas element and i want to paint it black
			canvasElement.fillStyle = "rgb(0,0,0)";
			canvasElement.fillRect(0, 0, settings.width, settings.height);
			
			//If canvas has been rotated, restore to initial and resave
			if(settings.rotation !== "none"){
				canvasElement.restore();
				canvasElement.save();
			}
			
			switch(settings.rotation){
				case "cw90":
					canvasElement.translate(settings.width, 0);
					canvasElement.rotate(90 * Math.PI / 180);
					break;
				case "acw90":
					canvasElement.translate(0, settings.height);
					canvasElement.rotate(-90 * Math.PI / 180);
					break;
				case "cw180":
					canvasElement.translate(settings.width, settings.height);
					canvasElement.rotate(180 * Math.PI / 180);
					break;
				default:
					//Restore canvas to inital settings
					canvasElement.restore();
					break;
			}
			
			//If this is our initial page load, save the canvas
			if(settings.rotation === "none"){
				canvasElement.save();
			}
			
			settings.blockx = 0;
			settings.blockwidth = 10; 
			settings.xs = 0;
			if(settings.done){
			    settings.done = false;
			    setTimeout('mandelbrot.generate()', 0);
			}
		},
		//Generate fractal
		generate: function(){
			var RGBArray;

			//Generate each vertical strip (600px wide)
			for (ys = 0; ys < settings.height; ys++){
				var x0 = (settings.xs - (settings.width/2)) / settings.cz + settings.cx;
				var y0 = (ys - (settings.height/2)) / settings.cz + settings.cy;
				
				var x = 0;
				var y = 0;
				
				//Used in the color / greyscale generation
				var iteration = 0;
				
				while ( x*x + y*y <= 4  &&  iteration < settings.iterations ){
					var xtemp = x*x - y*y + x0;
					y = 2*x*y + y0;
					x = xtemp;
					iteration++;
				}
				
				if(settings.color){
					//Color setting
					if(iteration >= settings.iterations){
						RGBArray = [0, 0, 0];
					} else {
						//var test = settings.iterations % iteration;
						RGBArray = colorArray[iteration];
					}
				} else {
					//Grayscale setting
					RGBArray = [iteration, iteration , iteration];
				}
				
				canvasElement.fillStyle = "rgb(" + RGBArray[0] + "," + RGBArray[1] + "," + RGBArray[2] + ")";
				canvasElement.fillRect(settings.xs, ys, settings.blockwidth, 1);
			}//End For
			
			//Incriment xs by step value
			settings.xs += settings.step;
			
			//If our x value is above width (600), move onto next block
			if (settings.xs >= settings.width){
				//Move onto the next block now all x values rendered
				settings.blockx++;
				//Each block sets a new initial value of x and block width
				switch(settings.blockx){
					case 1:
						status.innerHTML = "<span>Pass 2 Rendering</span>";
						settings.xs = 5;
		                settings.blockwidth = 5;
						break;
					case 2:
						status.innerHTML = "<span>Pass 3 Rendering</span>";
						settings.xs = 2;
		                settings.blockwidth = 3;
						break;
					case 3:
						status.innerHTML = "<span>Pass 4 Rendering</span>";
						settings.xs = 7;
		                settings.blockwidth = 3;
						break;
					case 4:
						status.innerHTML = "<span>Pass 5 Rendering</span>";
						settings.xs = 3;
		                settings.blockwidth = 2;
						break;
					case 5:
						status.innerHTML = "<span>Pass 6 Rendering</span>";
						settings.xs = 9;
		                settings.blockwidth = 1;
						break;
					case 6:
						status.innerHTML = "<span>Pass 7 Rendering</span>";
						settings.xs = 6;
		                settings.blockwidth = 1;
						break;
					case 7:
						status.innerHTML = "<span>Pass 8 Rendering</span>";
						settings.xs = 1;
		                settings.blockwidth = 1;
						break;
					case 8:
						status.innerHTML = "<span>Pass 9 Rendering</span>";
						settings.xs = 4;
		                settings.blockwidth = 1;
						break;
					case 9:
						status.innerHTML = "<span>Pass 10 Rendering</span>";
						settings.xs = 8;
		                settings.blockwidth = 1;
						break;
					default:
						settings.done = true;
						status.innerHTML = "Finished";
						break;
				}
			}
			
			if(!settings.done){
				setTimeout('mandelbrot.generate()', 0);
			}
		},
		
		//Zoom in
		zoomIn: function(){
			settings.cz *= 1.3;
			this.begin();
		},
		
		//Zoom out
		zoomOut: function(){
			settings.cz *= 0.7;
        	this.begin();
		},
		
		//Recenter
		recenter: function(){
			//Reset to standard values
			settings.cx = 0;
			settings.cy = 0;
			settings.cz = 150;
			
			settings.cx = (settings.posx) / settings.cz + settings.cx;
			settings.cy = (settings.posy) / settings.cz + settings.cy;
			this.begin();
		},
		
		//Zoom to point on click
		zoomToPoint: function(posX, posY){
			switch(settings.rotation){
				case "cw90":
					settings.cx = (posY - (settings.height/2)) / settings.cz + settings.cx;
					settings.cy = -((posX - (settings.width/2)) / settings.cz - settings.cy);
					break;
				case "acw90":
					settings.cx = -((posY - (settings.height/2)) / settings.cz - settings.cx);
					settings.cy = (posX - (settings.width/2)) / settings.cz + settings.cy;
					break;
				case "cw180":
					settings.cx = -((posX - (settings.width/2)) / settings.cz - settings.cx);
					settings.cy = -((posY - (settings.height/2)) / settings.cz - settings.cy);
					break;
				default:
					settings.cx = (posX - (settings.width/2)) / settings.cz + settings.cx;
					settings.cy = (posY - (settings.height/2)) / settings.cz + settings.cy;
					break;
			}
			
			this.begin();
		},
		
		//Get values
		getValues: function(){
			settings.cx = parseFloat(xInput.value);
			settings.cy = parseFloat(yInput.value);
			settings.cz = parseFloat(zInput.value);
			this.begin();
		},
		
		//Rotate Canvas
		rotateCanvas: function(value){
			settings.rotation = value;
			this.begin();
		},
		
		//Set the saturation / lightness settings
		setColourValues: function(slider, value){
			switch(slider){
				case "hue":
					settings.hueOne = value[0];
					settings.hueTwo = value[1];
					break;
				case "saturation":
					settings.saturation = value;
					break;
				case "lightness":
					settings.lightness = value;
					break;
			}
			this.generateColorArray();
		},
		
		generateColorArray: function(){
			var step = ((settings.hueTwo - settings.hueOne)/settings.iterations);
			
			//Clear array for next generation
			colorArray = [];
			
			for(i=0; i <= settings.iterations; i++){
				var hueValue = settings.hueOne + (step * i);
				var rgbArray = this.hsvToRgb(hueValue, settings.saturation, settings.lightness);
				colorArray.push(rgbArray);
			}
			this.begin();
		},
		
		setDimensionValues: function(slider, value){
			switch(slider){
				case "width":
					settings.width = value;
					break;
				case "height":
					settings.height = value;
					break;
			}
			this.begin();
		},
		
		callPreset: function(index){
			settings.cx = presets[index].x;
			settings.cy = presets[index].y;
			settings.cz = presets[index].z;
			this.begin();
		},
		
		//Convert from HSV to RGB, for better colour gradient
		//Hue, Saturation, Value(lightness)
		hsvToRgb: function(h, s, v){
			var r, g, b;
			var i;
			var f, p, q, t;
			
			// Make sure our arguments stay in-range
			h = Math.max(0, Math.min(360, h));
			s = Math.max(0, Math.min(100, s));
			v = Math.max(0, Math.min(100, v));
			
			// We accept saturation and value arguments from 0 to 100 because that's
			// how Photoshop represents those values. Internally, however, the
			// saturation and value are calculated from a range of 0 to 1. We make
			// That conversion here.
			s /= 100;
			v /= 100;
			
			if(s == 0) {
				// Achromatic (grey)
				r = g = b = v;
				return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
			}
			
			h /= 60; // sector 0 to 5
			i = Math.floor(h);
			f = h - i; // factorial part of h
			p = v * (1 - s);
			q = v * (1 - s * f);
			t = v * (1 - s * (1 - f));
			
			switch(i) {
				case 0:
					r = v;
					g = t;
					b = p;
					break;
					
				case 1:
					r = q;
					g = v;
					b = p;
					break;
					
				case 2:
					r = p;
					g = v;
					b = t;
					break;
					
				case 3:
					r = p;
					g = q;
					b = v;
					break;
					
				case 4:
					r = t;
					g = p;
					b = v;
					break;
					
				default: // case 5:
					r = v;
					g = p;
					b = q;
			}
			
			return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
		}
	};
}();

//Presets
var presets = [
	{
		x: 0,
		y: 0,
		z: 150
	},
	{
		x: -0.11404972381053438,
		y: -0.9691746638978361,
		z: 137599.99528990302
	},
	{
		x: 0.3141450013727253,
		y: 0.001370197053958128,
		z: 4543.126598883796
	},
	{
		x: -1.7654074600723384,
		y: 0.03493273323105303,
		z: 664168.8956652617
	},
	{
		x: -1.2201883160029843,
		y: 0.12655661422096004,
		z: 24684.879417265794
	},
	{
		x: -1.227399208022797,
		y: 0.1180088714334293,
		z: 340302.0247938686
	},
	{
		x: -1.227233313985799,
		y: 0.11844778148400746,
		z: 64674276.53726063
	},
	{
		x: -0.7596173056724186,
		y: 0.10184305269313652,
		z: 16868.311042793615
	},
	{
		x: -0.7451569862372087,
		y: 0.11257193773672058,
		z: 302307.18965191697
	},
	{
		x: -0.7692788139286832,
		y: 0.11526351489713421,
		z: 336229.49506218336
	}
	];

//Events etc.
jQuery(function($){
	//Get the ball rolling
	mandelbrot.begin();
	
	//Add the events
	$("#zoomIn").click(function(){mandelbrot.zoomIn();});
	$("#zoomOut").click(function(){mandelbrot.zoomOut();});
	$("#update").click(function(){mandelbrot.getValues();});
	$("#reCenter").click(function(){mandelbrot.recenter();});
	$("#rotate").change(function(){
		var rValue = $(this).val();
		mandelbrot.rotateCanvas(rValue);
	});
	$("#output").click(function(e){
		var offset = $(this).offset();
		var posX = e.pageX - offset.left;
		var posY = e.pageY - offset.top;
		mandelbrot.zoomToPoint(posX, posY);
	});
	$("input[name='color']", document.getElementById("controls")).click(function(e){
		var $sliders = $("#sliders", document.getElementById("colorContainer"));
		switch(e.target.id){
			case "colorY":
				$("#v1").html(settings.hueOne + "&deg;");
				$("#v2").html(settings.hueTwo + "&deg;");
				
				//Generate our color array
				mandelbrot.generateColorArray();
				settings.color = true;
				$sliders.slideDown();
				break;
			case "colorN":
				settings.color = false;
				$sliders.slideUp();
				break;
		}
		//Restart render on value change
		mandelbrot.begin();
	});
	
	/**
	 * Dimension Sliders
	 */
	var $bo = $("#borderOverlay");
	var $container = $("#container");
	
	//Width
	var $widthSlide = $("#widthSlide", document.getElementById("dimentionContainer"));
	$widthSlide.slider({
		min: 300,
		max: 1000,
		step: 1,
		value: 600
	});
	//Update value on slide
	$widthSlide.bind('slide', function(e, ui){
		//Get current container height
		var height = $container.height();
		$bo.css({
			height: height,
			width: ui.value,
			border: "1px dotted red",
			zIndex: "10"
		});
		
		$("#width span").html(ui.value + "px");
	});
	//Update dimensions on stop
	$widthSlide.bind('slidestop', function(e, ui){
		//Current height
		var height = $container.height();
		
		$bo.css({
			zIndex: "-10",
			border: "none"
		});
		$container.css({
			width: ui.value,
			height: height
		});
		mandelbrot.setDimensionValues("width", ui.value);
	});
	
	//Height
	var $heightSlide = $("#heightSlide", document.getElementById("dimentionContainer"));
	$heightSlide.slider({
		min: 300,
		max: 1000,
		step: 1,
		value: 600
	});
	//Update value on slide
	$heightSlide.bind('slide', function(e, ui){
		//Get current container width
		var width = $container.width();
		$bo.css({
			height: ui.value,
			width: width,
			border: "1px dotted red",
			zIndex: "10"
		});
		
		$("#height span").html(ui.value + "px");
	});
	//Update dimensions on stop
	$heightSlide.bind('slidestop', function(e, ui){
		//Current width
		var width = $container.width();
		
		$bo.css({
			zIndex: "-10",
			border: "none"
		});
		$container.css({
			width: width,
			height: ui.value
		});
		mandelbrot.setDimensionValues("height", ui.value);
	});
	
	/**
	 * Color sliders
	 */
	//Hue
	var $hueSlide = $("#hue-slider", document.getElementById("colorContainer"));
	$hueSlide.slider({
		min: 0,
		max: 360,
		step: 1,
		range: true,
		values: [settings.hueOne, settings.hueTwo]
	});
	$hueSlide.bind('slide', function(e, ui){
		$("#v1").html(ui.values[0] + "&deg;");
		$("#v2").html(ui.values[1] + "&deg;");
	});
	//Update canvas on stop
	$hueSlide.bind('slidestop', function(e, ui){
		mandelbrot.setColourValues("hue", ui.values);
	});
	
	//Saturation
	var $satSlide = $("#saturation", document.getElementById("colorContainer"));
	$satSlide.slider({
		min: 0,
		max: 100,
		step: 1,
		value: settings.saturation
	});
	//Update value on slide
	$satSlide.bind('slide', function(e, ui){
		$("#sat span").html(ui.value);
	});
	//Update canvas on stop
	$satSlide.bind('slidestop', function(e, ui){
		mandelbrot.setColourValues("saturation", ui.value);
	});
	
	//Lightness
	var $lightSlide = $("#lightness", document.getElementById("colorContainer"));
	$lightSlide.slider({
		min: 0,
		max: 100,
		step: 1,
		value: settings.lightness
	});
	//Update value on slide
	$lightSlide.bind('slide', function(e, ui){
		$("#light span").html(ui.value);
	});
	//Update canvas on stop
	$lightSlide.bind('slidestop', function(e, ui){
		mandelbrot.setColourValues("lightness", ui.value);
	});
	
	/**
	 * Samples Carousel
	 */
	var $carousel = $("#car");
	$carousel.jcarousel({
		scroll: 4,
		visible: 6
		});
	$carousel.find("li").bind("click", function(e){
		var $this = $(this);
		var index = $this.index();//thx jQuery 1.4!
		mandelbrot.callPreset(index);
	});
});
	</script>
</head>

<body>



</body>
</html>
