function MemeCreator(params) {
	this.setupTabs();
}

MemeCreator.prototype.setupTabs = function () {
	var tabs = [
	            {mode: "BACKGROUND"},
			    {mode: "CHARACTERS"},
			    {mode: "DIALOG"},
			    {mode: "SOUNDTRACK"},
			    {mode: "DOODLE"},
			    {mode: "SUBMIT"}
			    ];
	
	tabs.forEach(function (tab, i) {
		tab.div = document.getElementById(tab.mode.toLowerCase() + "-tab");
		tab.pageDiv = document.getElementById(tab.mode.toLowerCase() + "-page");
		tab.div.onclick = function () {
			tabs.forEach(function (tab2) {
				tab2.div.className = "main-tab";
				tab2.pageDiv.style.display = "none";
			});
			
			MemeCreator.prototype.showTab(tab);
			movie.scene.mode = tab.mode;
			
			tab.div.className = "selected-main-tab";
			tab.pageDiv.style.display = "block";
		};
		
		if (i > 0)
			tab.pageDiv.style.display = "none";
		else
			MemeCreator.prototype.showTab(tab);
	});
	
};

MemeCreator.prototype.showTab = function (tab) {
	if (tab.mode == "BACKGROUND") {
		this.showBackgroundTab(tab);
	}
	if (tab.mode == "DOODLE") {
		this.showDoodleTab(tab);
	}
	if (tab.mode == "CHARACTERS") {
		this.showCharactersTab(tab);
	}
	if (tab.mode == "SOUNDTRACK") {
		this.showSoundsTab(tab);
	}
	if (tab.mode == "DIALOG") {
		movie.dialogInput = document.getElementById("dialog-text")
	}
	if (tab.mode == "SUBMIT") {
		document.getElementById("custom-json").value = getJSON();
	}
	tab.shown = true;
};

MemeCreator.prototype.showDoodleTab = function (tab) {
	if (tab.shown)
		return;
	
	movie.scene.doodles.currentWidth = 6;
	
	for (var ic = 0; ic < movie.colors.length; ic++) {
		tab.pageDiv.appendChild(this.makeDoodleColorBox(ic));
	}
	
	pp = document.createElement("span");
	pp.innerHTML = "<br/>Line Width:";
	tab.pageDiv.appendChild(pp);
	
	var select, option;
	select = document.createElement("select");
	for (ic = 1; ic < 21; ic++) {
		option = document.createElement("option");
		option.value = ic;
		option.innerHTML = ic;
		
		if (ic == movie.scene.doodles.currentWidth) {
			option.selected = true;
		}
		select.add(option);
	}
	select.onchange = function () {
		movie.scene.doodles.currentWidth = parseInt(select.value); 
	};
	tab.pageDiv.appendChild(select);

};

MemeCreator.prototype.makeDoodleColorBox = function (i) {
	var colorBox = document.createElement("div");
	colorBox.className = "doodle-color-box";
	colorBox.style.backgroundColor = movie.colors[i];
	colorBox.onclick = function () {
		var offs = 5;
		if (movie.scene.doodles.currentColorBox){ 
			var oldColor = movie.scene.doodles.currentColorBox;
			oldColor.className = "doodle-color-box";
			oldColor.style.zIndex = 0;
		}
		var newColor = colorBox;

		newColor.className = "selected-doodle-color-box";
		newColor.style.zIndex = 1;
		movie.scene.doodles.currentColor = i;
		movie.scene.doodles.currentColorBox = newColor;
	};
	return colorBox;	

};

MemeCreator.prototype.showBackgroundTab = function (tab) {
	if (tab.shown)
		return;
	
	var mc = this;
	
	var imgInput = tab.pageDiv.getElementsByClassName("picture-url")[0];
	var nextButton = tab.pageDiv.getElementsByClassName("picture-url-next")[0];
	nextButton.onclick = function () {
		mc.addBackdrop(imgInput.value);
	};
	
	this.errorLoadingBackgroundDiv = tab.pageDiv.getElementsByClassName("error-loading")[0];

	imgInput.onkeypress = function (key) {
		if (key.key == "Enter") {
			nextButton.onclick();
		}
		else {
			mc.errorLoadingBackgroundDiv.style.display = "none";
		}
	};

	var loadExamples = tab.pageDiv.getElementsByClassName("warehouse-example")[0];
	loadExamples.onclick = function () {
		mc.addBackdrop("img/warehouse.jpg");
	};
};

MemeCreator.prototype.addBackdrop = function (src) {
	
	var mc = this;
	var errorCallback = function () {
		mc.errorLoadingBackgroundDiv.style.display = "inline-block";
	};
	
	var submitInput = document.getElementById("submit-picture-input");
	submitInput.value = src;

	//TODO not oop 
	addBackdrop(src, false, errorCallback);

};
MemeCreator.prototype.showCharactersTab = function (tab) {
	if (tab.shown)
		return;
	
	var mc = this;
	this.characterList = document.getElementById("character-list");
	var imgInput = tab.pageDiv.getElementsByClassName("picture-url")[0];
	var nextButton = tab.pageDiv.getElementsByClassName("picture-url-next")[0];
	var loadExamples = tab.pageDiv.getElementsByClassName("load-examples")[0];
	this.characterList.errorLoadingDiv = tab.pageDiv.getElementsByClassName("error-loading")[0];

	imgInput.onkeypress = function (key) {
		if (key.key == "Enter") {
			nextButton.onclick();
		}
		else {
			mc.characterList.errorLoadingDiv.style.display = "none";
		}
	};
	
	nextButton.onclick = function () {
		mc.addCharacterFromFile(imgInput.value);
		loadExamples.style.display = "none";
	};
	
	loadExamples.onclick = function () {
		mc.addCharacterFromFile("img/dino/car.png");
		mc.addCharacterFromFile("img/dino/trex_1.png");
		loadExamples.style.display = "none";
	}
};

MemeCreator.prototype.addCharacterFromFile = function (filename) {
	var mc = this;
	
	var errorCallback = function () {
		mc.characterList.errorLoadingDiv.style.display = "inline-block";
	};
	var loadCallback = function (character) {
		mc.makeCharacterButton(character);			
	};
	
	addCharacterFromFile(filename, loadCallback, errorCallback);
};

MemeCreator.prototype.makeCharacterButton = function (character){
	
	var mc = this;
	
	var newCanvas = document.createElement("canvas");

	newCanvas.onclick = function () {
		recallCharacter(character);
		mc.selectListButton(mc.characterList.children, newCanvas, "character-button");
		
	};	
	
	newCanvas.height = 80;
	newCanvas.width = 60;
	
	this.characterList.appendChild(newCanvas);
	mc.selectListButton(mc.characterList.children, newCanvas, "character-button");
	
	drawCharacter(character, 
		newCanvas.width / 2, newCanvas.height - 20, newCanvas.getContext("2d"));			

};

MemeCreator.prototype.showSoundsTab = function (tab) {
	if (tab.shown)
		return;
	
	var mc = this;
	this.soundList = tab.pageDiv.getElementsByClassName("list")[0];
	var imgInput = tab.pageDiv.getElementsByClassName("url")[0];
	var nextButton = tab.pageDiv.getElementsByClassName("url-next")[0];
	nextButton.onclick = function () {
		var sound = addSoundFile(imgInput.value);
		mc.makeSoundButton(sound);	

	};
	
	var createDrumbeat = tab.pageDiv.getElementsByClassName("create-drumbeat")[0];
	createDrumbeat.onclick = function () {
		mc.createDrumbeat();
	};

	var createDrumbeat = tab.pageDiv.getElementsByClassName("create-melody")[0];
	createDrumbeat.onclick = function () {
		mc.createMelody();
	};

};

MemeCreator.prototype.createDrumbeat = function () {
	
	MemeCreator.prototype.showOMGBam({command: "new",
		type : "DRUMBEAT"});
	
	bam.beatmaker.setSize();
};

MemeCreator.prototype.createMelody = function () {
	
	MemeCreator.prototype.showOMGBam({command: "new",
		type : "MELODY"});

	bam.mm.setSize();
};

MemeCreator.prototype.showOMGBam = function (params) {

	var fullscreenWindow = document.getElementById("fullscreen-window-background");
	var omgbam = document.getElementById("omgbam");
	
	omgbam.style.display = "block";
	
	fullscreenWindow.style.display = "block";
	fullscreenWindow.onclick = function () {
		fullscreenWindow.onclick = null;
		
		fullscreenWindow.style.display = "none";
		omgbam.style.display = "none";
		omg.player.stop();
	};

	//bam.setup("http://openmusicgallery.appspot.com", false);
	bam.setup("http://localhost:8889", false);
	bam.load(params);
	bam.offsetTop = 60;
};




MemeCreator.prototype.selectListButton = function (list, button, className){
	
	for (var ib = 0; ib < list.length; ib++) {
		if (list[ib] == button) {
			list[ib].className = "selected-" + className;
		}
		else {
			list[ib].className = className;
		}
	}
};


MemeCreator.prototype.makeSoundButton = function (sound){
	console.log("hmmm")
	var mc = this;
	var newItem = document.createElement("div");
		
	newItem.onclick = function () {
		recallSound(sound);
		mc.selectListButton(mc.soundList.children, newItem, "sound-button");
	};
	
	console.log(this.soundList.appendChild(newItem))		
	this.selectListButton(this.soundList.children, newItem, "sound-button");
	
};

