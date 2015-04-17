<%--
   DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
  
   Copyright (c) 2007 Sun Microsystems Inc. All Rights Reserved
  
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

   $Id: PWResetSuccess.jsp,v 1.5 2008/08/28 06:41:11 mahesh_prasad_r Exp $

--%>
<%--
   Portions Copyrighted 2012 ForgeRock AS
--%>
    <%
     Cookie[] cookies = request.getCookies();
     String gotoURL = "";
     for (int i=0; i<cookies.length; i++)
       {
       if(cookies[i].getName().equals("gotoURL"))
	      gotoURL = cookies[i].getValue();
       }
    %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <%@include file="../ui/PWResetBase.jsp" %>
    <%@page info="PWResetSuccess" language="java" pageEncoding="UTF-8"%>
    <%@taglib uri="/WEB-INF/jato.tld" prefix="jato"%>
    <jato:useViewBean className="com.sun.identity.password.ui.PWResetSuccessViewBean" fireChildDisplayEvents="true">
        <head>
            <title>Smarter Balanced Password Reset</title>
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
                        <span class="title"><h1>Smarter Balanced Password Reset</h1></span>
                    </div>
            </div>
            <div class="content">
                <span class="success" id="ctl00_MainContentPlaceHolder_ucErrorList_spanErrorList">
                    <span id="ctl00_MainContentPlaceHolder_ucErrorList_ErrorList_ctl00_lblErrorInstruction"><jato:text name="ccTitle"/></span><br>
                    <ul>
                        <li>
                            <jato:text name="resetMsg"/>
                        </li>
                        <li>
                            Click <a href="/auth/UI/Login?goto=<%=gotoURL%>">here</a> to go back to the login page.
                        </li>
                    </ul>
                </span>
                <div class="login">
                    <div class="loginbox"> </div>
                    <div class="extrahelp"> <span class="icon"></span>
                    <p> <span> Smarter Balanced Help Desk Information:</span><br />
                    <b>Phone:</b> 1.855.833.1969<br />
                    <b>Email:</b> smarterbalancedhelpdesk@ets.org<br />
                    </p>
                    </div>
                </div>
            </div>
        </body>
    </jato:useViewBean>
</html>