<%--
   DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
  
   Copyright (c) 2005 Sun Microsystems Inc. All Rights Reserved
  
   The contents of this file are subject to the terms
   of the Common Development and Distribution License
   (the License). You may not use this file except in
   compliance with the License.
                                                                                
   You can obtain a copy of the License at
   https://opensso.dev.java.net/public/CDDLv1.0.html or
   opensso/legal/CDDLv1.0.txt
   See the License for the specific language governing
   permission and limitations under the License.
                                                                                
   When distributing Covered Code, include this CDDL
   Header Notice in each file and include the License file
   at opensso/legal/CDDLv1.0.txt.
   If applicable, add the following below the CDDL Header,
   with the fields enclosed by brackets [] replaced by
   your own identifying information:
   "Portions Copyrighted [year] [name of copyright owner]"
                                                                                
   $Id: Logout.jsp,v 1.5 2008/08/15 01:05:27 veiming Exp $
                                                                                
--%>
<%--
   Portions Copyrighted 2012 ForgeRock AS
--%>

<%-- Delete gotoURL cookie upon Logout --%>
<%
   Cookie cookie = null;
   Cookie[] cookies = null;
   // Get an array of Cookies associated with this domain
   cookies = request.getCookies();
   if( cookies != null ){
      for (int i = 0; i < cookies.length; i++){
         cookie = cookies[i];
         if((cookie.getName( )).compareTo("gotoURL") == 0 ){
            cookie.setMaxAge(0);
            cookie.setPath("/auth/");
            response.addCookie(cookie);
         }
      }
  }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <%@page info="Logout" language="java"%>
    <%@taglib uri="/WEB-INF/jato.tld" prefix="jato"%>
    <%@taglib uri="/WEB-INF/auth.tld" prefix="auth"%>
    <jato:useViewBean className="com.sun.identity.authentication.UI.LogoutViewBean">
        <%@page contentType="text/html" %>
        <head>
            <title>Smarter Balanced</title>
            <%
                String ServiceURI = (String) viewBean.getDisplayFieldValue(viewBean.SERVICE_URI);
            %>
            <link rel="icon" type="image/x-icon" href="/auth/images/favicon.ico" />
            <link href="<%= ServiceURI%>/css/sbac_style.css" rel="stylesheet" type="text/css" />
            <!--[if IE 9]> <link href="<%= ServiceURI %>/css/ie9.css" rel="stylesheet" type="text/css"> <![endif]-->
            <!--[if lte IE 7]> <link href="<%= ServiceURI %>/css/ie7.css" rel="stylesheet" type="text/css"> <![endif]-->
        </head>
        <body>
            <div class="wrapper">
                <div class="clientlogo"></div>
                <div class="banner">
                    <span class="logo">
                        <a href="#">
                            <img name="SBAC_logo" alt="SBAC Logo" src="/auth/images/logo_sbac.jpg">
                        </a>
                    </span>
                    <%
                    String appName = request.getParameter("appName");
                    if (appName == null) {
                        appName = "Smarter Balanced Sign-In";
                    }
                    %>
                    <span class="title"><h1><%= appName %></h1></span>
                    <%--<jato:content name="ContentStaticTextHeader">--%>
                    <%--<h1><jato:getDisplayFieldValue name='StaticTextHeader' defaultValue='Authentication' fireDisplayEvents='true' escape='false'/></h1>--%>
                    <%--</jato:content>--%>
                </div>
            </div>
            <div class="content">
                <span class="logout" id="ctl00_MainContentPlaceHolder_ucErrorList_spanErrorList">
                    <span id="ctl00_MainContentPlaceHolder_ucErrorList_ErrorList_ctl00_lblErrorInstruction"><jato:text name="txtLogout" /></span>
                </span>
                <div>
                    <jato:content name="ContentHrefLogout">
                        <auth:href name="urlLogin" fireDisplayEvents='true'><jato:text name="txtGotoLoginAfterLogout" /></auth:href></p>
                    </jato:content>
                </div>
            <%--<div class="container_12">--%>
                <%--<div class="grid_4 suffix_8">--%>
                    <%--&nbsp;--%>
                <%--</div>--%>
                <%--<div class="box clear-float">--%>
                    <%--<div class="grid_3">--%>
                        <%--&nbsp;--%>
                    <%--</div>--%>
                <%--</div>--%>
                    <%--<div class="grid_3">&nbsp;</div>--%>
                    <%--<div class="grid_6">--%>
                        <%--<div class="box-content clear-float login">--%>
                            <%--<div class="message">--%>
                                <%--<h3>--%>
                                    <%--<jato:content name="ContentTextBoxLogout">--%>
                                        <%--<jato:text name="txtLogout" />--%>
                                    <%--</jato:content>--%>
                                <%--</h3>--%>
                                <%--<jato:content name="ContentHrefLogout">--%>
                                    <%--<p>--%>
                                        <%--<auth:href name="urlLogin" fireDisplayEvents='true'><jato:text name="txtGotoLoginAfterLogout" /></auth:href>--%>
                                        <%--</p>--%>
                                <%--</jato:content>--%>
                            <%--</div>--%>
                        <%--</div>--%>
                    <%--</div>--%>
                <%--</div>--%>
                <%--<div class="grid_3">&nbsp;</div>--%>
            </div>
        </body>
    </jato:useViewBean>
</html>
