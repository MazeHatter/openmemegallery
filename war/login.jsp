<%@ page import="com.openmemegallery.UserHelper" %>

<%
    UserHelper user = new UserHelper();
    String url = user.getLoginUrl();
    response.sendRedirect(url);
    
%>
