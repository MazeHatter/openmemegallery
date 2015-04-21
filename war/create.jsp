<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.blobstore.UploadOptions" %>

<%
    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	UploadOptions uploadOptions = UploadOptions.Builder.withMaxUploadSizeBytesPerBlob(1200000);
	String uploadURL = blobstoreService.createUploadUrl("/upload", uploadOptions);
    String blobKey = request.getParameter("img-key");
	if (blobKey == null) {
		blobKey = "";
	}
	
	String openmusicurl;
	if (request.getServerName().equals("localhost")) {
		openmusicurl = "http://localhost:8889";
	}
	else {
		openmusicurl = "http://openmusicgallery.appspot.com";
	}     
%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>OMG Creator</title>    
    <link rel="stylesheet" href="<%= openmusicurl%>/omgbam.css" type="text/css" />
    <link rel="stylesheet" href="create.css" type="text/css" />    
  </head>

  <body>
    <div id="main-body">
    
    <div class="main-tabs">
	<div id="background-tab" class="selected-main-tab">Background</div>
	<div id="characters-tab" class="main-tab">Characters</div>
	<div id="dialog-tab" class="main-tab">Dialog</div>
	<div id="soundtrack-tab" class="main-tab">Music</div>
	<div id="doodle-tab" class="main-tab">Doodle</div>
	<div id="submit-tab" class="main-tab">Submit</div>	
	</div>

	<img id="image-preview"/>
	
	<div id="preview-window">
	</div>
	    
    <div id="detail-tab-frame">

		<div class="detail-page" id="background-page">		
			<strong>Add a background from an Image URL </strong>

			<p>	
				<input placeholder="Image URL" class="picture-url" type="text" name="picture-url"></input>
				<br/>
				<button class="picture-url-next">Next</button>

				<span class="error-loading">
					Error loading image
				</span>

			</p>

			<p>Examples: <a href="javascript:void(0)" class="warehouse-example">Warehouse</a></p>
			<hr/>
			<p class="main-hint">Propose images for examples, ask for help, and make suggestions about this site on the 
			<a href="http://www.reddit.com/r/openmemegallery/">omg subreddit</a>
			</p>

		</div>		

		<div class="detail-page" id="characters-page">
			<strong>Add a character from an Image URL </strong>
	
			<p>	
				<input placeholder="Image URL" class="picture-url" type="text" name="picture-url"></input>
				<br/>
				<button class="picture-url-next">Next</button>

				<span class="error-loading">
					Error loading image
				</span>
			</p>
			
			<div id="character-list">
			</div>
			
			<a href="javascript:void(0)" class="load-examples">Click Here to Load Examples</a>
			<hr/>
			<p class="main-hint">Direct Characters by dragging on the scene.</p>
		</div>

		<div class="detail-page" id="dialog-page">
			<strong>Add a Dialog Bubble </strong>
			<p>
				<input id="dialog-text" placeholder="Put Text Here" type="text">
			</p>
			<p>
				Enter some Text in the box above and then click on the 
				scene when and where it should appear.
			</p>
		</div>
		
		<div class="detail-page" id="soundtrack-page">
			<strong>Add a sound from an Sound URL (*.mp3, *.ogg) </strong>
	
			<p>	
				<input placeholder="Sound URL" class="url" type="text" name="url"></input>
				<br/>
				<button class="url-next">Next</button>
				<span class="error-loading">
					Error loading image
				</span>

			</p>
			<strong>Or create your own music</strong>
			<p>
				<a href="javascript:void(0)" class="create-melody">
				Start with a Melody
				</a> 
				- 
				<a href="javascript:void(0)" class="create-drumbeat">
				Start with a Drumbeat
				</a>
			</p>
						
			<div class="list">
			</div>

			<hr/>

			<p class="main-hint">
				Single click the scene to play the entire file.
				<br/><br/>
				Click and hold to play for a specific length.
			</p>

		</div>
		<div class="detail-page" id="doodle-page">
		</div>
		<div class="detail-page" id="submit-page">

			<form action="/meme" method="POST">	
			Title: 
			<br/>
			<input type="text" name="title"></input>
			<br/>
			Text:
			<br/>
			<textarea type="text" name="text"></textarea>
			<br/>
			Tags:
			<br/>
			<input type="text" name="tags"></input>
			<br/>
			<br/>
			<input id="custom-json" type="hidden" name="custom-json"></input>
			<input id="submit-picture-input" type="hidden" name="picture"></input>
			
			<p class="warning">Your Meme is not Posted Yet! Hit the Post Button below</p>
			<input type="submit" value="Post!"/>
			
			</form>

		</div>
		
		
	</div>

	<div id="fullscreen-window-background">
	</div>
	
	<div id="omgbam-dialog">
	
		<div class="powered-by-omgbam">
			Powered by <a target="_OUT" href="http://openmusicgallery.appspot.com/omgbam.jsp">OMGBam</a> 
			on <a target="_OUT" href="http://openmusicgallery.appspot.com/">OpenMusicGallery</a>
		</div>
	
	<div id="omgbam">
	
		<div id="master"><div class="artist">
			<div class="song"></div>
		</div></div>

		<div id="bam-controls">
				
		<div id="melody-maker" class="area">
			<div class="remixer-caption" id="melody-maker-caption">Melody</div>	
			<canvas id="melody-maker-canvas">
			</canvas>
		</div>
		
		<div id="beatmaker" class="area">
			<div class="remixer-caption">Drumbeat</div>
			<canvas id="beatmaker-canvas">
			</canvas>
		</div>
		
		<div id="mm-options" class="option-panel">		
			<div class="panel-option" id="play-mm">Play</div>
			<div class="panel-option" id="share-mm">Share</div>
			<div class="panel-option" id="next-mm">Next</div>
			<div class="panel-option" id="clear-mm">Clear</div>
		</div>
		
		<div id="remixer" class="area">
			<div class="remixer-caption" id="remixer-caption">Section</div>
			<div class="remixer-message" id="no-section-message">
				<p class="nodata">(This Section is empty. Add some things to it!)</p> 
			</div>
				
			<div class="remixer-area" id="remixer-add-buttons">
				<div class="remixer-add-button" id="remixer-add-melody">
					Add <br/>Melody
				</div>
				<div class="remixer-add-button" id="remixer-add-bassline">
					Add <br/>Bassline
				</div>
				<div class="remixer-add-button" id="remixer-add-drumbeat">
					Add <br/>Drumbeat
				</div>			
			</div>
		
		</div>
		
		<div class="option-panel" id="remixer-option-panel">
			<div class="panel-option" id="play-section">Play</div>
			<div class="panel-option" id="share-section">Share</div>
			<div class="panel-option" id="remixer-next">Next</div>				
			<div class="panel-option" id="clear-remixer">Clear</div>
		
		</div>
		
		<div id="song-option-panel">
			<div class="horizontal-panel-option" id="play-song">Play</div>	
			<div class="horizontal-panel-option" id="share-song">Share</div>
			<div class="horizontal-panel-option" id="next-song">Next</div>				
			<div class="horizontal-panel-option" id="clear-song">Clear</div>
		</div>
		
		<div id="song-edit-panel">
			<div class="horizontal-panel-option" id="remove-section-button">Remove</div>
		</div>
		
		<div id="rearranger">
			<div class="remixer-caption">Song</div>
			<input class="entity-name" value="unnamed"/>
			<div class="remixer-area" id="rearranger-area">
			</div>
			<div class="section" id="add-section">+ Add Section</div>	
		</div>
		
		</div> <!--omgbam-controls-->	
	</div> <!--omgbam-->

	<div class="omgbam-dialog-buttons">
		<div class="horizontal-panel-option" id="omgbam-dialog-ok">OK</div>	
		<div class="horizontal-panel-option" id="omgbam-dialog-cancel">Cancel</div>
	</div>
	</div> <!--omgbam-dialog-->
	
 
<script src="omgmaker.js"></script>
<script src="create.js"></script>

<script>
var urlNextButton = document.getElementById("picture-url-next");
var step1 = document.getElementById("step-1");
var step2 = document.getElementById("step-2");
var step3 = document.getElementById("step-3");
var imgInput = document.getElementById("picture-input");
var youtubeInput = document.getElementById("youtube-input");
var imgPreview = document.getElementById("image-preview");

var memeMakerDiv = document.getElementById("preview-window");
var memeMaker;
memeMaker = new MemeMaker({div: memeMakerDiv});
	
var memeCreator = new MemeCreator();
	
	
imgPreview.onload = function () {
	var width = imgPreview.clientWidth;
	var height = imgPreview.clientHeight;
	
	imgPreview.style.display = "none";
	
	memeMaker = new MemeMaker({div: memeMakerDiv, backgroundImg: imgPreview});
	
};


  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-50186685-3', 'auto');
  ga('send', 'pageview');


	// url for openmusicgallery
	var _omusic_url = "<%= openmusicurl%>";

</script>

<script src="<%= openmusicurl%>/omgbam.js"></script>
<script src="<%= openmusicurl%>/omg_partsui.js"></script>
<script src="<%= openmusicurl%>/omg_player.js"></script>
<script src="<%= openmusicurl%>/omg_util.js"></script>
	
	</div> <!--main-body-->
  </body>
</html>
