
var OVERLAP = 1;
var id = 0;
var viewer;

var c= canvas;
var ctx=c.getContext("2d");
	
window.onload = function() {

	
	ctx.lineWidth = 6;

	viewer = {currentColor: 0,
			paths: [], 
			colors: ["#FFFFFF", "#FF0000", "#FFFF00", "#00FF00", "#0000FF", 
			  		"#FF8000", "#9E9E9E", "#00FFFF", "#800080", "#632DFF", "#63FF08"],
	         xsize: c.clientWidth, 
	         ysize: c.clientHeight,
	         animating:false,
	         mode: OVERLAP,
	         lastUp: 0
	};

	for (var ic = 0; ic < viewer.colors.length; ic++){
		document.getElementById("color-" + ic).style.backgroundColor = viewer.colors[ic];
	}

	tool = new tool_pencil();

	c.addEventListener("mousedown", tool.mousedown, false);
	c.addEventListener("mousemove", tool.mousemove, false);
	c.addEventListener("mouseup",   tool.mouseup, false);
	c.addEventListener("touchstart", tool.touchstart, false);
	c.addEventListener("touchmove", tool.touchmove, false);
	c.addEventListener("touchend",   tool.touchend, false);

};


function draw(){	
	//var c=document.getElementById("main-canvas");
	var ctx=c.getContext("2d");
	var xsize = c.clientWidth;
	var ysize = c.clientHeight;
	var freq;
	var panX = 0;
	var skipNext = false;
	
	ctx.lineWidth = 6;
	
	//ctx.clearRect(0, 0, c.width, c.height);	
	ctx.drawImage(imgPreview, 0, 0);

	for (var ip = 0; ip < viewer.paths.length; ip++){
		var nowInLoop = -1;
		panX = 0;
		freq = 0;
		if (viewer.paths[ip].animating){
			nowInLoop = (new Date).getTime() - (viewer.mode == OVERLAP ? viewer.paths[ip].loopStarted : viewer.loopStarted);
		}

		ctx.beginPath();
		for (var is = 1; is < viewer.paths[ip].pxdata.length; is++){
			var pxdata = viewer.paths[ip].pxdata;
			if (!viewer.paths[ip].finished && (nowInLoop == -1 || pxdata[is][2] < nowInLoop)){
				if (pxdata[is][1] == -1){
					skipNext = true;
				}
				else {
					if (!skipNext) {
						ctx.moveTo(pxdata[is -1][0], pxdata[is -1][1]);
						ctx.lineTo(pxdata[is][0], pxdata[is][1]);
					}
					skipNext = false;
				}

				if (nowInLoop > -1 && is == pxdata.length - 1){
					if (ip == 0){
						viewer.loopStarted = (new Date).getTime();
						viewer.paths[0].loopStarted = viewer.loopStarted;
						for (var ip2 = 0; ip2 < viewer.paths.length; ip2++){
							if (viewer.paths[ip2].finished){
								viewer.paths[ip2].loopStarted = viewer.loopStarted;
								viewer.paths[ip2].finished = false;
							}
						}
						
					}
					else {
//						viewer.paths[ip].loopStarted = viewer.loopStarted;
						viewer.paths[ip].finished = true;						
					}
				}
			}
			else{
				break;
			}
		}

		ctx.closePath();
		ctx.strokeStyle = viewer.colors[viewer.paths[ip].color]; 
		ctx.stroke();
	}
	if (viewer.animating){
		requestAnimFrame(function() {
			draw();
		});

	}
}	


function tool_pencil () {
	//var canvas = document.getElementById("mainCanvas");
	var context = canvas.getContext("2d");	
	var tool = this;
	this.started = false;
	this.lastX = -1;
	this.lastY = 0;
	this.lastColor = -1;
	this.drawnSegments = 0;
	this.drawnPaths = 0; 
	this.looperCounter = 0;
	this.continuingOn = false;


	this.touchstart = function (ev) {
		ev.preventDefault(); 
		x = ev.targetTouches[0].pageX - canvas.offsetLeft;
		y = ev.targetTouches[0].pageY - canvas.offsetTop;
		tool.start(x, y);
	}
	this.touchmove = function (ev) {
		ev.preventDefault(); 
		x = ev.targetTouches[0].pageX - canvas.offsetLeft;
		y = ev.targetTouches[0].pageY - canvas.offsetTop;
		tool.move(x, y);
	}
	this.touchend = function (ev) {
		ev.preventDefault(); 
		tool.end();
	}

	this.mousedown = function (ev) {
		x = ev.pageX - canvas.offsetLeft;
		y = ev.pageY - canvas.offsetTop;
		tool.start(x, y);
	}
	this.start = function(x, y){
		var now = (new Date).getTime();
		if (now - viewer.lastUp < 500){
			tool.drawnPaths--;
		}
		else {
			tool.drawnSegments = 0;
			segments = [];
			tool.drawnPaths = viewer.paths.length;
			if (viewer.hasAudio){
				mixer.channels[tool.drawnPaths] = makeChannel(viewer.currentColor);
			}
			if (viewer.animating){
				tool.loopCounter = viewer.loopStarted;
			}
			else {
				context.strokeStyle = viewer.colors[viewer.currentColor];
				context.beginPath();
				context.moveTo(x, y);
				tool.loopCounter = (new Date).getTime();
			}
		}


		tool.started = true;

		tool.lastX = x;
		tool.lastY = y;

		segments[tool.drawnSegments] = [x, y, (new Date).getTime() - tool.loopCounter];
		tool.drawnSegments++;

		viewer.paths[tool.drawnPaths] = {color: viewer.currentColor, 
				pxdata: segments,
				i:0,
				animating:false,
				finished:false
		};
		onEdit();
	};

	this.mousemove = function (ev) {
		x = ev.pageX - canvas.offsetLeft;
		y = ev.pageY - canvas.offsetTop;
		tool.move(x, y);
	}

	this.move = function(x, y){

		if (tool.started) {
			if (!viewer.animating)
			{
				context.lineTo(x, y);
				context.moveTo(x, y);
				context.stroke();
			}

			segments[tool.drawnSegments] = [x, y, (new Date).getTime() - tool.loopCounter];

			tool.lastX = x;
			tool.lastY = y;
			tool.drawnSegments++;

		}
	};

	this.mouseup = function (ev) {
		ev.preventDefault(); 
		tool.end();
	}

	this.end = function (){
		if (tool.started) {
			if (!viewer.animating){
				context.closePath();	
			}
			var now = (new Date).getTime();
			tool.started = false;

			segments[tool.drawnSegments] = [tool.lastX, -1, now - tool.loopCounter];

			tool.drawnSegments++;

			if (!viewer.animating){
				animate();
			}
			else {
				if (tool.drawnPaths > 0){
					viewer.paths[tool.drawnPaths].finished = true;
				}
			}
			viewer.paths[tool.drawnPaths].loopStarted = now;
			viewer.paths[tool.drawnPaths].animating = true;

			tool.drawnPaths++;
			viewer.lastUp = now;

		}
	};
}

function animate(){
	viewer.animating = true;
	viewer.loopStarted = (new Date).getTime();
	draw();
}

function chooseColor(color){
	var offs = 5;
	if (viewer.currentColor > -1){ 
		var oldColor = document.getElementById("color-" + viewer.currentColor);
		oldColor.style.borderWidth = "1px";
		//  var newLeft = oldColor.style.left + 3;
		//  oldColor.style.left = newLeft + "px";
		oldColor.style.borderColor = "#808080";
		oldColor.style.zIndex = 0;
	}
	var newColor = document.getElementById("color-" + color);
	newColor.style.borderWidth = "3px";
	//  var newLeft2 = newColor.style.left - 3;
	//  newColor.style.left = newLeft2;
	newColor.style.borderColor = "#FFFFFF";
	newColor.style.zIndex = 1;
	viewer.currentColor = color;


}
function onEdit(){
	id = 0;	
}
function clearButton(){
	onEdit();

	viewer.animating = false;
	viewer.paths = [];
	draw();
}
function undoButton(){
	if (viewer.paths.length == 1){
		clearButton();
		return;
	}

	viewer.paths = viewer.paths.slice(0, viewer.paths.length - 1);
	draw();
	onEdit();
}

function getDoodleJSON(){
	var odoodle = {audio: viewer.audio, paths: viewer.paths	};
	var doodle = JSON.stringify(odoodle);
	return doodle;
	
}

window.requestAnimFrame = (function(callback) {
	return window.requestAnimationFrame || 
			window.webkitRequestAnimationFrame || 
			window.mozRequestAnimationFrame || 
			window.oRequestAnimationFrame || 
			window.msRequestAnimationFrame || 
			function(callback) {
		window.setTimeout(callback, 1000 / 60);
	};
})();






