package com.openmemegallery;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Text;


@SuppressWarnings("serial")
public class MemeServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
	
		resp.setContentType("text/plain");
	
		DatastoreService ds = DatastoreServiceFactory.getDatastoreService();
			
		String id = req.getParameter("id");
		if (id == null){
			Query q = new Query("Meme");
			q.addSort("datetime", Query.SortDirection.DESCENDING);

			String pall = req.getParameter("all");

			if (pall == null || !pall.equals("true"))
				q.addFilter("front", FilterOperator.EQUAL, true);
			
			boolean first = true;
			resp.getWriter().print("{\"result\": \"good\", \"data\": [");
			
			for (Entity meme : ds.prepare(q).asIterable(FetchOptions.Builder.withLimit(30))){
				if (first){
					first = false;
				}
				else {
					resp.getWriter().print(", \n");
				}
				resp.getWriter().print("{\"title\" : \"" + meme.getProperty("title") + "\", " );
				resp.getWriter().print("\"picture\" : \"" + meme.getProperty("picture") + "\", " );
				resp.getWriter().print("\"text\" : \"" + ((Text)meme.getProperty("text")).getValue() + "\", " );
				resp.getWriter().print("\"video\" : \"" + meme.getProperty("video") + "\", " );				
				resp.getWriter().print("\"views\" : " + meme.getProperty("views") + ", " );
				resp.getWriter().print("\"datetime\" : " + meme.getProperty("datetime") + ", " );
				resp.getWriter().print("\"tags\" : \"" + meme.getProperty("tags") + "\", " );
				resp.getWriter().print("\"id\" : \"" + Long.toString(meme.getKey().getId()) + "\"");
								
				resp.getWriter().print("}") ;
				
			}
			resp.getWriter().print("]}");
		}
		else {
			Query q = new Query("Meme", KeyFactory.createKey("Meme", Long.parseLong(id)));
			
			Entity meme = ds.prepare(q).asSingleEntity();
			if (meme == null){
				resp.getWriter().print("{\"result\": \"bad\"}");
			}
			else{
				long views;
				Object oviews = meme.getProperty("views");
				if (oviews == null) {
					views = 1;
				}
				else {
					views = 1 + (Long)oviews;
				}
				meme.setProperty("views", views);
				ds.put(meme);

				
				resp.getWriter().print("{\"result\": \"good\", \"data\": [");
				
				resp.getWriter().print("{\"title\" : \"" + meme.getProperty("title") + "\", " );
				resp.getWriter().print("\"picture\" : \"" + meme.getProperty("picture") + "\", " );
				resp.getWriter().print("\"text\" : \"" + ((Text)meme.getProperty("text")).getValue() + "\", " );
				resp.getWriter().print("\"video\" : \"" + meme.getProperty("video") + "\", " );				
				resp.getWriter().print("\"views\" : " + meme.getProperty("views") + ", " );
				resp.getWriter().print("\"datetime\" : " + meme.getProperty("datetime") + ", " );
				resp.getWriter().print("\"tags\" : \"" + meme.getProperty("tags") + "\", " );
				resp.getWriter().print("\"id\" : \"" + Long.toString(meme.getKey().getId()) + "\"");
				
				Text customJson = (Text)meme.getProperty("custom-json");
				if (customJson != null) {
					resp.getWriter().print(", \"custom_json\" : \"" + customJson.getValue() + "\" " );	
				}
												
				resp.getWriter().print("}") ;
					
				resp.getWriter().print("]}");

				
			}
		}
	}

	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		try {
			UserHelper user = new UserHelper();
			
			DatastoreService ds = DatastoreServiceFactory.getDatastoreService();

			Entity meme = new Entity("Meme");
	
			String title = req.getParameter("title");
			String picture = req.getParameter("picture");
			String text = req.getParameter("text");
			String video = req.getParameter("video");
			String tags = req.getParameter("tags");
			String customJSON = req.getParameter("custom-json");
			
			if (title == null || text == null ) {
				resp.getWriter().print("{\"status\":\"bad\"}");
			}
			
			// get rid of new lines in the textarea
		    text = text.replaceAll("[\n]", "<br/>").
		    		replaceAll("[\r]", "");
			
			meme.setProperty("title", title);
			meme.setProperty("picture", picture);
			meme.setProperty("text", new Text(text));
			meme.setProperty("video", video);
			meme.setProperty("views", 0);			
			meme.setProperty("tags", tags);
			meme.setProperty("front", user.isAdmin());
			
			if (customJSON != null && customJSON.length() > 0) {
				meme.setProperty("custom-json", new Text(customJSON));					
			}
			
			meme.setProperty("datetime", System.currentTimeMillis());
			
			String userId = "";
			//UserInfo userInfo = new UserInfo();
			//if (userInfo.isLoggedIn()){
			//	userId = userInfo.getId();
			//}
			meme.setProperty("user", userId);
				
			Key key = ds.put(meme);
			
			resp.getWriter().print("{\"status\":\"good\", \"id\":");
			resp.getWriter().print(Long.toString(key.getId()));
			resp.getWriter().print("}");
			
			resp.sendRedirect("meme.jsp?id=" + Long.toString(key.getId()));
		
		}
		catch (Exception e) {
			resp.getWriter().print("{\"status\":\"bad\"}");		
		}
	}
}