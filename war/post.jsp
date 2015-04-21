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
%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Post to Open Meme Gallery</title>
    <style>
    body {
    	max-width:900px;
    	margin:auto;
	}
    input {
    	width:600px;
    }
    textarea {
    	width:600px;
    	height:200px;
    }
    
    #step-2, #step-3 {
    	display:none;	
    }
    .post-type {
    	padding:3px;
    	border:1px solid #808080;
    	border-radius:2px;
    	margin:3px;
    }
    
    .main-canvas {
    	display:none;
    }
    .color_box {
    	display:inline-block;
    	height:18px;
    	width:18px;
    }
    .long-button {
    	width:600px;
	}
	#uploader {
		display:none;
	}
    </style>
  </head>

  <body>
    <strong>Post to Open Meme Gallery</strong>
    
    <div id="step-1">

		<p><strong>Step 1: Upload a Picture</strong>. 
			If you're sharing a YouTube video, this will be the thumbnail.
		</p>

		<div class="post-type">		
			<h3>An Image already on the web</h3>
	
			<p>	
				Image URL:
				<br/>
				<input id="picture-url" type="text" name="picture-url"></input>
				<br/>
				<button class="long-button" id="picture-url-next">Next</button>
			</p>

		</div>
		
		
		<div class="post-type">		
			<h3>A YouTube Video</h3>
	
			<p>	
				YouTube Video ID:
				<br/>
				<input id="youtube-id" type="text" name="youtube-id"></input>
				<br/>
				<button class="long-button" id="youtube-submit">Next</button>
			</p>

		</div>
		
		
		<div id="uploader" class="post-type">		

			<h3>An Image on my computer</h3>
	
			<p>Select a File
			<br/>
		    <form action="<%= uploadURL %>" method="post" enctype="multipart/form-data">
		            <input type="file" name="myFile">
		            <input type="submit" value="Upload">
		    </form>
		    </p>
		</div>
    
    	
		<!--<div class="post-type">		
			<h3>No Image File</h3>
			<button id="no-image-next">Proceed with No Image File</button>
		</div>-->

	</div>

		
	<div id="step-2">

		<p><strong>Step 2: Customize</strong>. 
			Add Doodles, Text, Music, and more!
			<button id="done-customizing">Click Here When Finished</button>			
		</p>

		<img id="image-preview"/>
		
		<div id="meme-maker">
		</div>
		<small>Based on HTML5MovieMaker by <a href="http://cloudmoviecompany.com">CloudMovieCompany.com</a></small>						
	
	</div>
	
	<div id="step-3">
		
		<p><strong>Last Step: Some Meta Data</strong>.
		</p>

		<form action="/meme" method="POST">	
		Title: 
		<br/>
		<input type="text" name="title"></input>
		<br/>
		Text:
		<br/>
		<textarea type="text" name="text"></textarea>
		<br/>
		YouTube Link:
		<br/>
		<input id="youtube-input" type="text" name="video"></input>
		<br/>
		Tags:
		<br/>
		<input type="text" name="tags"></input>
		<br/>
		<br/>
		<input id="custom-json" type="hidden" name="custom-json"></input>
		<input id="picture-input" type="hidden" name="picture"></input>
		<input type="submit" value="Post!"/>
		</form>
	</div>
 
<script src="omgmaker.js"></script>

<script>
var urlNextButton = document.getElementById("picture-url-next");
var step1 = document.getElementById("step-1");
var step2 = document.getElementById("step-2");
var step3 = document.getElementById("step-3");
var imgUrlInput = document.getElementById("picture-url");
var imgInput = document.getElementById("picture-input");
var youtubeInput = document.getElementById("youtube-input");
var imgPreview = document.getElementById("image-preview");

var memeMakerDiv = document.getElementById("meme-maker");
var memeMaker;

imgPreview.onload = function () {
	var width = imgPreview.clientWidth;
	var height = imgPreview.clientHeight;
	
	imgPreview.style.display = "none";
	
	memeMaker = new MemeMaker({div: memeMakerDiv, backgroundImg: imgPreview});
	
};

urlNextButton.onclick = function () {
	step1.style.display = "none";
	step2.style.display = "block";	
	
	imgInput.value = imgUrlInput.value;
	
	if (imgInput.value) {
		imgPreview.src = imgInput.value;
	}
	else {
		memeMaker = new MemeMaker({div: memeMakerDiv});
	}
	
};

document.getElementById("done-customizing").onclick = function () {
	step2.style.display = "none";
	step3.style.display = "block";	

	document.getElementById("custom-json").value = memeMaker.getJSON();		
};

document.getElementById("youtube-submit").onclick = function () {
	var youtubeId = document.getElementById("youtube-id").value;
	if (!youtubeId) {
		alert("Um, you need an ID");
		return;
	}
	
	imgInput.value = "https://img.youtube.com/vi/" + youtubeId + "/0.jpg";
	youtubeInput.value = "https://www.youtube.com/watch?v=" + youtubeId;

	step1.style.display = "none";
	step3.style.display = "block";	

};


var imgKey = "<%= blobKey %>";
if (imgKey) {
	step1.style.display = "none";
	step2.style.display = "block";
	
	imgInput.value = "/upload?blob-key=" + imgKey;
	imgPreview.src = imgInput.value;
}


<%
String miketest = request.getScheme() + "://" + request.getServerName();
if (request.getServerPort() != 80)
	miketest = miketest + ":" + request.getServerPort();

%>
var miketest = "<%= miketest %>";
</script>

<!--<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-50186685-3', 'auto');
  ga('send', 'pageview');

</script>

<script src="doodle.js"></script>-->

  </body>
</html>
