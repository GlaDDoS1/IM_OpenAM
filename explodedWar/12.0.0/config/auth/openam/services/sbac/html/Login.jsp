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

       $Id: Login.jsp,v 1.11 2009/01/09 07:13:21 bhavnab Exp $

    --%>
        <%--
           Portions Copyrighted 2012 ForgeRock Inc
        --%>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

        <html xmlns="http://www.w3.org/1999/xhtml">
        <%@page info="Login" language="java"%>
        <%@taglib uri="/WEB-INF/jato.tld" prefix="jato"%>
        <%@taglib uri="/WEB-INF/auth.tld" prefix="auth"%>
        <jato:useViewBean className="com.sun.identity.authentication.UI.LoginViewBean">
        <%@page contentType="text/html" %>
	<%@ page import = "org.owasp.esapi.ESAPI" %>
        <head>
        <meta charset="UTF-8">
        <title>Smarter Balanced</title>
            <%
               String ServiceURI = (String) viewBean.getDisplayFieldValue(viewBean.SERVICE_URI);
               String encoded = "false";
               String gotoURL = (String) viewBean.getValidatedInputURL(
                       request.getParameter("goto"), request.getParameter("encoded"), request);
               String gotoOnFailURL = (String) viewBean.getValidatedInputURL(
                       request.getParameter("gotoOnFail"), request.getParameter("encoded"), request);
               String encodedQueryParams = (String) viewBean.getEncodedQueryParams(request);

               Cookie[] cookies = null;
               cookies = request.getCookies();

               // Delete any existing gotoURL cookies
               Cookie gotoCookie = null;
               if( cookies != null ){
                  for (int i = 0; i < cookies.length; i++){
                     gotoCookie = cookies[i];
                     if((gotoCookie.getName( )).compareTo("gotoURL") == 0 ){
                        gotoCookie.setMaxAge(0);
                        gotoCookie.setPath("/auth/");
                        response.addCookie(gotoCookie);
                     }
                  }
               }

               // Delete any existing passwordChange cookies
               Cookie pwcCookie = null;
               if( cookies != null ){
                  for (int i = 0; i < cookies.length; i++){
                     pwcCookie = cookies[i];
                     if((pwcCookie.getName( )).compareTo("passwordChange") == 0 ){
                        pwcCookie.setMaxAge(0);
                        pwcCookie.setPath("/auth/");
                        response.addCookie(pwcCookie);
                     }
                  }
               }

               if ((gotoURL != null) && (gotoURL.length() != 0) && (!request.getParameter("goto").equals("/auth/idm/EndUser?action=sq"))) {
                   encoded = "true";
                   Cookie cookie = new Cookie("gotoURL", request.getParameter("goto"));
                   cookie.setPath("/auth/");
                   response.addCookie( cookie );
               }

               // Set isSAML parameter for evaluation in sbacLogin.js when a password change is forced
               String isSAML = request.getParameter("isSAML");
               if ((isSAML == null)) {
                    isSAML = "false";
                    String gotoParam = request.getParameter("goto");
                    if ((gotoParam != null) && (gotoParam.contains("SSORedirect"))) {
                        isSAML = "true";
                    }
               } 
            %>
        <link rel="icon" type="image/x-icon" href="/auth/images/favicon.ico" />
        <link href="<%= ServiceURI%>/css/sbac_style.css" rel="stylesheet" type="text/css" />
        <!--[if IE 9]> <link href="<%= ServiceURI%>/css/ie9.css" rel="stylesheet" type="text/css"> <![endif]-->
        <!--[if lte IE 7]> <link href="<%= ServiceURI%>/css/ie7.css" rel="stylesheet" type="text/css"> <![endif]-->
        <script language="JavaScript" src="<%= ServiceURI%>/js/auth.js" type="text/javascript"></script>
        <script src="https://code.jquery.com/jquery-1.6.4.min.js" type="text/javascript"></script>
        <script src="<%= ServiceURI%>/js/browser.js" type="text/javascript"></script>
        <script src="<%= ServiceURI%>/js/modernizer.js" type="text/javascript"></script>
        <script src="/auth/console/js/sbacLogin.js" type="text/javascript"></script>
        <script src="<%= ServiceURI%>/js/jquery.cookie.js" type="text/javascript"></script>
        <script type="text/javascript">
        $(function(){

        $('.more').toggle(function () {
        $(this).prev().addClass("active");
        }, function () {
        $(this).prev().removeClass("active");
        });});
        </script>

        <jato:content name="validContent">
        <script language="JavaScript" type="text/javascript">
        <!--
        var defaultBtn = 'Submit';
        var elmCount = 0;

        /**
        * submit form with given button value
        *
        * @param value of button
        */
        function LoginSubmit(value) {
        aggSubmit();
        var hiddenFrm = document.forms['Login'];

        if (hiddenFrm != null) {
        hiddenFrm.elements['IDButton'].value = value;
        if (this.submitted) {
        alert("The request is currently being processed");
        }
        else {
        this.submitted = true;
        hiddenFrm.submit();
        }
        }
        }
        -->
        </script>
        </jato:content>
        </head>
        <body onload="placeCursorOnFirstElm();">
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
                    appName = "Smarter Balanced Single Sign On";
                }
            %>
        <span class="title"><h1><%= appName %></h1></span>
        <%--<jato:content name="ContentStaticTextHeader">--%>
        <%--<h1><jato:getDisplayFieldValue name='StaticTextHeader' defaultValue='Authentication' fireDisplayEvents='true' escape='false'/></h1>--%>
        <%--</jato:content>--%>
        </div>
        </div>


        <div class="content">

        <jato:content name="ContentStaticTextHeader">
            <span class="error" id="ctl00_MainContentPlaceHolder_ucErrorList_spanErrorList">
                <span id="ctl00_MainContentPlaceHolder_ucErrorList_ErrorList_ctl00_lblErrorInstruction"></span><br>
                    <ul>
                        <li>
                            <jato:getDisplayFieldValue name='StaticTextHeader' defaultValue='Authentication' fireDisplayEvents='true' escape='false'/>
                        </li>
                    </ul>
            </span>
        </jato:content>

        <div class="info">
        <h2>Please Log In</h2>
        <p>Enter your username and password to log into the Smarter Balanced applications. After you log in, you will automatically be directed to the application  you selected.</p>
        </div>


        <div class="login">
        <div class="loginbox">
        <jato:content name="validContent">
        <auth:form name="Login" method="post" defaultCommandChild="DefaultLoginURL">
        <jato:tiledView name="tiledCallbacks" type="com.sun.identity.authentication.UI.CallBackTiledView">
        <script language="javascript" type="text/javascript">
        <!--
        elmCount++;
        -->
        </script>


        <jato:content name="textBox">
        <ul>
        <li>
        <%--<div class="row">--%>
        <label for="IDToken<jato:text name="txtIndex" />">
        <jato:text name="txtPrompt" defaultValue="Username" escape="false" />
        <jato:content name="isRequired">
        <img src="<%= ServiceURI %>/images/required.gif" alt="Required Field" title="Required Field" width="7" height="14" />
        </jato:content>
        <span class="small">Enter your email address</span>
        </label>
        <input type="text" name="IDToken<jato:text name="txtIndex" />" id="IDToken<jato:text name="txtIndex" />" value="<jato:text name="txtValue" />" />
        <%--</div>--%>
        </li>
        </ul>
        </jato:content>

        <%--<li>--%>
        <jato:content name="password">
        <ul>
        <li>
        <%--<div class="row">--%>
        <label for="IDToken<jato:text name="txtIndex" />">
        <jato:text name="txtPrompt" defaultValue="Password" escape="false" />
        <jato:content name="isRequired">
        <img src="<%= ServiceURI %>/images/required.gif" alt="Required Field"
        title="Required Field" width="7" height="14" />
        </jato:content>
        <span class="small" id="pwHint<jato:text name="txtIndex" />"></span>
        </label>
        <input type="password" name="IDToken<jato:text name="txtIndex" />" id="IDToken<jato:text name="txtIndex" />" value="" />
        <%--<a href="http://sso-dev.opentestsystem.org:8080/auth/ui/PWResetUserValidation?realm=sbac" class="forgetpassword">Forget Your Password?</a>--%>
        <%--</div>--%>
        </li>
        </ul>
        </jato:content>

        <jato:content name="choice">
        <ul>
        <li>
        <%--<div class="row">--%>
        <label for="IDToken<jato:text name="txtIndex" />">
        <jato:text name="txtPrompt" defaultValue="RadioButton:" escape="false" />
        <jato:content name="isRequired">
        <img src="<%= ServiceURI %>/images/required.gif" alt="Required Field"
        title="Required Field" width="7" height="14" />
        </jato:content>
        </label>
        <div class="radios">
        <jato:tiledView name="tiledChoices" type="com.sun.identity.authentication.UI.CallBackChoiceTiledView">
        <jato:content name="selectedChoice">
        <input type="radio" name="IDToken<jato:text name="txtParentIndex" />" id="IDToken<jato:text name="txtIndex" />" value="<jato:text name="txtIndex" />" checked="checked" />
        <label for="IDToken<jato:text name="txtIndex" />">
        <jato:text name="txtChoice" />
        </label>
        </jato:content>

        <jato:content name="unselectedChoice">
        <input type="radio" name="IDToken<jato:text name="txtParentIndex" />" id="IDToken<jato:text name="txtIndex" />" value="<jato:text name="txtIndex" />" />
        <label for="IDToken<jato:text name="txtIndex" />">
        <jato:text name="txtChoice" />
        </label>
        </jato:content>
        </jato:tiledView>
        </div>
        <%--</div>--%>
        </li>
        </ul>
        </jato:content>
        </jato:tiledView>
        <%--</li>--%>
        <%--<li>--%>
        <jato:content name="ContentStaticTextResult">
        <!-- after login output message -->
        <p><b><jato:getDisplayFieldValue name='StaticTextResult'
        defaultValue='' fireDisplayEvents='true' escape='false'/></b></p>
        </jato:content>
        <jato:content name="ContentHref">
        <!-- URL back to Login page -->
        <p><auth:href name="LoginURL" fireDisplayEvents='true'>
        <jato:text name="txtGotoLoginAfterFail" /></auth:href></p>
        </jato:content>
        <jato:content name="ContentImage">
        <!-- customized image defined in properties file -->
        <p><img name="IDImage" src="<jato:getDisplayFieldValue name='Image'/>" alt=""/></p>
        </jato:content>

        <div>
        <a href="/auth/ui/PWResetUserValidation?goto=<%= gotoURL%>" class="forgetpassword">Forgot Your Password?</a>
        </div>
        <jato:content name="ContentButtonLogin">
        <fieldset>
        <jato:content name="hasButton">


        <ul>
        <li style="white-space: nowrap; text-align: center;">
        <%--<div class="row">--%>
        <jato:tiledView name="tiledButtons"
        type="com.sun.identity.authentication.UI.ButtonTiledView">
        <input name="Login.Submit" type="button" onclick="LoginSubmit('<jato:text name="txtButton" />'); return false;" class="button" style="width: inherit; float: inherit; margin-left: inherit" value="<jato:text name="txtButton" />" />
        </jato:tiledView>
        <%--</div>--%>
        </li>
        </ul>
        <script language="javascript" type="text/javascript">
        <!--
        defaultBtn = '<jato:text name="defaultBtn" />';
        var inputs = document.getElementsByTagName('input');
        for (var i = 0; i < inputs.length; i ++) {
        if (inputs[i].type == 'button' && inputs[i].value == defaultBtn) {
        inputs[i].setAttribute("class", "button primary");;
        break;
        }
        }
        -->
        </script>
        <input type="hidden" name="passwordChange" value="true" />
        </jato:content>
        <jato:content name="hasNoButton">
        <ul>
        <li>
        <%--<div class="row">--%>
        <input name="Login.Submit" type="submit" onclick="LoginSubmit('<jato:text name="lblSubmit" />'); return false;" class="button primary" style="width: inherit; float: inherit;" value="<jato:text name="lblSubmit" />" />
        <%--</div>--%>
        </li>
        </ul>
        </jato:content>
        </fieldset>
        </jato:content>
        <script language="javascript" type="text/javascript">
        <!--
        if (elmCount != null) {
        document.write("<input name=\"IDButton"  + "\" type=\"hidden\">");
        }
        -->
        </script>
        <input type="hidden" name="goto" value="<%= gotoURL%>" />
        <input type="hidden" name="gotoOnFail" value="<%= gotoOnFailURL%>"/>
        <input type="hidden" name="SunQueryParamsString" value="<%= encodedQueryParams%>" />
        <input type="hidden" name="encoded" value="<%= encoded%>" />
        <input type="hidden" name="appName" value="<%= appName%>" />
        <input type="hidden" name="isSAML" value="<%= isSAML%>" />
        </auth:form>
        </jato:content>
        <%--</li>--%>
        <%--</ul>--%>
        </div>
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
