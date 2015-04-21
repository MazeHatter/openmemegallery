package com.openmemegallery;

import java.io.IOException;

import javax.servlet.http.*;

import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.blobstore.BlobKey;

import java.util.Map;

@SuppressWarnings("serial")
public class UploadServlet extends HttpServlet {
	
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		UserHelper user = new UserHelper();
		if (!user.isAdmin())
			return;
		
		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("myFile");
		
		if (blobKey == null) {
		//	resp.sendRedirect("/");
			resp.getWriter().write("null");

		}
		else {
			resp.sendRedirect("/post.jsp?img-key=" + blobKey.getKeyString());
		}
		
	}


	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
		BlobKey blobKey = new BlobKey(req.getParameter("blob-key"));
		blobstoreService.serve(blobKey, resp);

	}

}
