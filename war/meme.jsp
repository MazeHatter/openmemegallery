<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Text" %><%
Entity meme = null;


StringBuffer requestURL = request.getRequestURL();
if (request.getQueryString() != null) {
    requestURL.append("?").append(request.getQueryString());
}
String completeURL = requestURL.toString();

String serverName = request.getScheme() + "://" + request.getServerName();
if (request.getServerPort() != 80)
	serverName = serverName + ":" + request.getServerPort();

String id = request.getParameter("id");
String picture = null;
String title = null;
String text = null;
String tags = null;
Text customJSON = null;
String customString = null;
long datetime = 0;
String video = null;
long views;

String videoId = "";
String videoIdParam = "?v=";
String videoIdParam2 = "/";

if (id == null){
	response.getWriter().print("bad");
}
else {
	Query q = new Query("Meme", KeyFactory.createKey("Meme", Long.parseLong(id)));
	DatastoreService ds = DatastoreServiceFactory.getDatastoreService();
	meme = ds.prepare(q).asSingleEntity();
	if (meme == null || meme.getProperty("title") == null){
		// TODO let the user know we didn't find this id
		response.getWriter().print("bad");
	}
	else {
		picture = (String)meme.getProperty("picture");
		video = (String)meme.getProperty("video");
		tags = (String)meme.getProperty("tags");
		datetime = (Long)meme.getProperty("datetime");
		title = (String)meme.getProperty("title");
		text = ((Text)meme.getProperty("text")).getValue();

		customJSON = (Text)meme.getProperty("custom-json");		
		if (customJSON != null) {
			customString = customJSON.getValue();
		}		
		
		if (picture != null && picture.indexOf("/") == 0)  {
			picture = serverName + picture;
		}
		
		if (video != null) {
			int index = video.indexOf(videoIdParam);
			if (index > -1) {
				videoId = video.substring(index + videoIdParam.length());
			}
			else {
				index = video.lastIndexOf(videoIdParam2);
				if (index > -1) {
					videoId = video.substring(index + videoIdParam2.length());
				}
			}
		}
		
		Object oviews = meme.getProperty("views");
		if (oviews == null) {
			views = 1;
		}
		else {
			views = 1 + (Long)oviews;
		}
		meme.setProperty("views", views);
		ds.put(meme);
	}
}
%><!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />        

<meta name="apple-mobile-web-app-capable" content="yes" />

<meta name="viewport" content="width=device-width" />


<meta property="og:image" content="<%= picture %>" />
<meta property="og:description" content="<%= text %>" />
<title>OMG!!! <%= title %></title>

<link rel="stylesheet" href="meme.css" type="text/css"/>

<link rel="apple-touch-startup-image" href="" />
<link rel="apple-touch-icon" href="" />
</head>

<body>
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&appId=108330069340139&version=v2.0";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>

<h1>
<%= title %>
</h1>


<div class="fb-like" data-href="<%= completeURL %>" data-layout="button_count" data-action="recommend" data-show-faces="true" data-share="true"></div>

<a href="https://twitter.com/share" class="twitter-share-button">Tweet</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>

<br/>
<br/>

<div>
<%= text %>
</div>

<br/>

<% if (videoId.length() > 0) { %>
<img class="hide-img" src="<%= picture %>" />

<iframe id="ytplayer" type="text/html" width="640" height="390"
  src="http://www.youtube.com/embed/<%= videoId %>"
  frameborder="0">
  </iframe>

<% } else if (customString != null) { %>
	<div id="meme-maker"></div>
<% }  else { %>

	<img src="<%= picture %>" />
<% }  %>


<!-- this is needed by the posted-at stuff-->
<script src="util.js">
</script>

<div id="posted-at">
</div>
<script>
document.getElementById("posted-at").innerHTML = 
	"Posted " + omg.util.getTimeCaption(<%= datetime %>);
</script>


<% if (customString != null) { %>
<script src="omgmaker.js"></script>
<script>
var customJSON = <%= customString %>;
var memeMaker = new MemeMaker({div: document.getElementById("meme-maker"),
							   viewOnly: true});
loadObject(customJSON);
playButton();
</script>
<% } %>


<h2><a href="create.jsp">Make your own Meme!</a></h2>
<h2><a href="index.html">More OMG!!!</a></h2>

	<div id="meme-list"></div>

	<script>
	var list = document.getElementById("meme-list");
	var newDiv;
	var newChildDiv;
	var newContent;
	var meme;
	var videoId;
	var videoIdParam = "?v=";
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "/meme", true);
    xhr.onreadystatechange = function(){
        if (xhr.readyState == 4){

            var ooo = JSON.parse(xhr.responseText);
            if (ooo && ooo.result && ooo.result === "good") {
            
            	for (var i = 0; i < ooo.data.length; i++) {
            		meme = ooo.data[i];		

            		newDiv = document.createElement("a");
            		newDiv.href = "/meme.jsp?id=" + meme.id;
            		newDiv.className = "meme";

					newContent = document.createElement("div");
					newContent.className = "meme-content";
					
            		newChildDiv = document.createElement("div");
            		newChildDiv.innerHTML = "Posted: " + omg.util.getTimeCaption(meme.datetime);
            		newChildDiv.className = "meme-datetime";
            		newContent.appendChild(newChildDiv);

            		newChildDiv = document.createElement("h2");
            		newChildDiv.innerHTML = meme.title;
            		newChildDiv.className = "meme-title";
            		newContent.appendChild(newChildDiv);
            							
            		newChildDiv = document.createElement("div");
            		newChildDiv.innerHTML = meme.text;
            		newChildDiv.className = "meme-text";
            		newContent.appendChild(newChildDiv);
            		
            		if (meme.tags) {
	            		newChildDiv = document.createElement("span");
	            		newChildDiv.innerHTML = "Tags: ";
	            		newChildDiv.className = "meme-tags-caption";
	            		newContent.appendChild(newChildDiv);
	
	            		newChildDiv = document.createElement("span");
	            		newChildDiv.innerHTML = meme.tags;
	            		newChildDiv.className = "meme-tags";
	            		newContent.appendChild(newChildDiv);
					}
					
					newDiv.appendChild(newContent);
					            		
            		newChildDiv = document.createElement("img");
            		newChildDiv.src = meme.picture;
            		newChildDiv.className = "meme-picture";
            		newDiv.appendChild(newChildDiv);



            		list.appendChild(newDiv);
            	}
            
            }

        }
    };
    xhr.send();        
	
	</script>


<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-50186685-3', 'auto');
  ga('send', 'pageview');

</script>

</body>
</html>

