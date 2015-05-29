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

   $Id: PWResetUserValidation.jsp,v 1.5 2008/08/28 06:41:11 mahesh_prasad_r Exp $

--%>
<%--
   Portions Copyrighted 2012 ForgeRock AS
--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <%@include file="../ui/PWResetBase.jsp" %>
    <%@page info="PWResetUserValidation" language="java" pageEncoding="UTF-8"%>
    <%@taglib uri="/WEB-INF/jato.tld" prefix="jato"%>
    <jato:useViewBean className="com.sun.identity.password.ui.PWResetUserValidationViewBean" fireChildDisplayEvents="true">
        <head>
            <title>Smarter Balanced Password Reset</title>
            <link rel="icon" type="image/x-icon" href="/auth/images/favicon.ico" />
            <link href="<%= ServiceURI%>/css/sbac_style.css" rel="stylesheet" type="text/css" />
            <!--[if IE 9]> <link href="<%= ServiceURI %>/css/ie9.css" rel="stylesheet" type="text/css"> <![endif]-->
            <!--[if lte IE 7]> <link href="<%= ServiceURI %>/css/ie7.css" rel="stylesheet" type="text/css"> <![endif]-->
            <script language="javascript">
                <!-- set the focus for a given field and form -->
                function setFocus(frmName,field) {
                    var frm = document.forms[frmName];
                    if (frm != null) {
                        var elm = frm.elements[field];
                        if (elm != null) {
                            elm.focus();
                            elm.select();
                        }
                    }
                }
            </script>
        </head>
        <body class="LogBdy" onLoad="setFocus('PWResetUserValidation','PWResetUserValidation.tfUserAttr');">
    <div class="wrapper">
    <div class="clientlogo"></div>
    <div class="banner">
    <span class="logo">
    <a href="#">
    <img name="SBAC_logo" alt="SBAC Logo" src="/auth/images/logo_sbac.jpg">
    </a>
    </span>
    <span class="title"><h1>Smarter Balanced Password Reset</h1></span>
    <%--<jato:content name="ContentStaticTextHeader">--%>
    <%--<h1><jato:getDisplayFieldValue name='StaticTextHeader' defaultValue='Authentication' fireDisplayEvents='true' escape='false'/></h1>--%>
    <%--</jato:content>--%>
    </div>
    </div>


    <div class="content">
    <jato:content name="errorBlock">
        <span class="error" id="ctl00_MainContentPlaceHolder_ucErrorList_spanErrorList">
            <span id="ctl00_MainContentPlaceHolder_ucErrorList_ErrorList_ctl00_lblErrorInstruction">The following errors have occurred:</span><br>
            <ul>
                <%--<li>--%>
                    <%--<jato:text name="errorTitle"/>--%>
                <%--</li>--%>
                <li>
                    <jato:text name="errorMsg"/>
                </li>
            </ul>
        </span>
    </jato:content>
    <div class="login">
    <div class="loginbox">

                    <%--<div class="grid_9 left-seperator">--%>
                        <%--<div class="box-content clear-float">--%>
                            <h1><jato:text name="userValidationTitle"/></h1>
                            <%--<jato:content name="errorBlock">--%>
                                <%--<div class="message">--%>
                                    <%--<span class="icon error"></span>--%>
                                    <%--<h3><jato:text name="errorTitle"/></h3>--%>
                                    <%--<h4><jato:text name="errorMsg"/></h4>--%>
                                <%--</div>    --%>
                            <%--</jato:content>--%>
                            <jato:content name="infoBlock">
                                <div class="message">
                                    <span class="icon info"></span>
                                    <h3><jato:text name="infoMsg"/></h3>
                                </div>     
                            </jato:content>
                            <jato:content name ="resetPage">
                                <jato:form name="PWResetUserValidation" method="post" defaultCommandChild="/btnNext">
                                    <fieldset style="height: 168px;">
                                        <jato:hidden name="fldUserAttr"/>
                                        <div class="row">


                                            <label for="PWResetUserValidation.tfUserAttr" style="margin-top: 28px;">
                                                Email Address:
                                                <%--<jato:text name="lblUserAttr" />:--%>
                                            </label>
                                            <jato:textField name="tfUserAttr" styleClass="textbox"/>

                                        </div>
                                        <div class="row">

                                            <input name="PWResetUserValidation.btnNext" type="submit" class="button primary" style="width: inherit;" value="<jato:text name="btnNext" />" />
                                            <input type="hidden" name="goto" value="<%= request.getParameter("goto") %>" />
                                    </div>

                                </fieldset>
                            </jato:form>
                        </jato:content>
                    </div>
                    <div class="extrahelp"> <span class="icon"></span>
                    <p> <span> Help Desk Information:</span><br />
                    <b>Phone:</b> 1.800.555.1212<br />
                    <b>Email:</b> help@fake-email.com<br />
                    </p>
                    </div>
            </div>
            <div class="info">
    <h2>Reset Your Password</h2>

    <p>Enter your email address that is on file in TIDE, and click [Next]. You will be prompted to enter the answer for your selected security question. </p>
    <p>You will receive an email that contains a new, temporary password. You will need to log in with the temporary password and update your account with a new permanent password. </p>
            </div>
        </div>
    </body>
</jato:useViewBean>
</html>
