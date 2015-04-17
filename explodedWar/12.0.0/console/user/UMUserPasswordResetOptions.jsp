<%--
   DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
  
   Copyright (c) 2006 Sun Microsystems Inc. All Rights Reserved
  
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

   $Id: UMUserPasswordResetOptions.jsp,v 1.3 2008/09/20 07:05:04 babysunil Exp $

--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Smarter Balanced Security Questions</title>
        <link rel="icon" type="image/x-icon" href="/auth/images/favicon.ico" />
        <link href="/auth/css/sbac_style.css" rel="stylesheet" type="text/css" />
        <!--[if IE 9]> <link href="/auth/css/ie9.css" rel="stylesheet" type="text/css"> <![endif]-->
        <!--[if lte IE 7]> <link href="/auth/css/ie7.css" rel="stylesheet" type="text/css"> <![endif]-->
        <script language="JavaScript" src="/auth/js/auth.js" type="text/javascript"></script>
        <script src="https://code.jquery.com/jquery-1.6.4.min.js" type="text/javascript"></script>
        <script src="/auth/js/browser.js" type="text/javascript"></script>
        <script src="/auth/js/modernizer.js" type="text/javascript"></script>
        <script src="/auth/js/jquery.cookie.js" type="text/javascript"></script>
        <script src="/auth/console/js/sbacEndUser.js" type="text/javascript"></script>
        <script src="/auth/console/js/jquery.base64.min.js" type="text/javascript"></script>
        <script src="/auth/console/js/sbacUMUserPasswordResetOptions.js" type="text/javascript"></script>
    </head>
    <body class="display-none">
        <div class="wrapper">
            <div class="clientlogo"></div>
            <div class="banner">
                <span class="logo">
                    <a href="#">
                        <img name="SBAC_logo" alt="SBAC Logo" src="/auth/images/logo_sbac.jpg">
                    </a>
                </span>
            <span class="title"><h1>Smarter Balanced Security Questions</h1></span>
            </div>
        </div>
        <div class="content">

<%@ page info="UMUserPasswordResetOptions" language="java" %>
<%@taglib uri="/WEB-INF/jato.tld" prefix="jato" %>
<%@taglib uri="/WEB-INF/cc.tld" prefix="cc" %>
<jato:useViewBean
    className="com.sun.identity.console.user.UMUserPasswordResetOptionsViewBean"
    fireChildDisplayEvents="true" >

<cc:i18nbundle baseName="amConsole" id="amConsole"
    locale="<%=((com.sun.identity.console.base.AMViewBeanBase)viewBean).getUserLocale()%>"/>

<%--<cc:header name="hdrCommon" pageTitle="webconsole.title" bundleID="amConsole" copyrightYear="2004" fireDisplayEvents="true">--%>

<script language="javascript" src="../console/js/am.js"></script>

<cc:form name="UMUserPasswordResetOptions" method="post" defaultCommandChild="/btnSearch">
<jato:hidden name="szCache" />

<script language="javascript">
    function confirmLogout() {
        return confirm("<cc:text name="txtLogout" defaultValue="masthead.logoutMessage" bundleID="amConsole"/>");
    }
</script>
<%--<cc:primarymasthead name="mhCommon" bundleID="amConsole"  logoutOnClick="return confirmLogout();"/>--%>

<table border="0" cellpadding="10" cellspacing="0" width="100%">
    <tr>
	<td>
	<cc:alertinline name="ialertCommon" bundleID="amConsole" />
	</td>
    </tr>
</table>

<%-- PAGE CONTENT --------------------------------------------------------- --%>
<cc:pagetitle name="pgtitle" bundleID="amConsole" pageTitleText="page.title.UMUserPasswordResetOptions" showPageTitleSeparator="true" viewMenuLabel="" pageTitleHelpMessage="" showPageButtonsTop="true" showPageButtonsBottom="false" />
    <div>&nbsp;</div>
    <p>Select one security question from the list below and provide your security answer in the "Answer" text field. In the event that you forget your password, you will be prompted to enter your answer for the selected security question. </p>
<cc:spacer name="spacer" height="10" newline="true" />

<jato:content name="Questions">
<cc:actiontable
    name="tblSearch"
    title="table.UMUserPasswordResetOptions.title.name"
    bundleID="amConsole"
    summary="table.UMUserPasswordResetOptions.summary"
    empty="table.UMUserPasswordResetOptions.empty.message"
    selectionType="multiple"
    showAdvancedSortingIcon="false"
    showLowerActions="false"
    showPaginationControls="false"
    showPaginationIcon="false"
    showSelectionIcons="false"
    selectionJavascript="toggleTblButtonState('UMUserPasswordResetOptions', 'UMUserPasswordResetOptions.tblSearch', 'tblButton', null, this)"
    showSelectionSortIcon="false"
    showSortingRow="false" />
</jato:content>

<jato:content name="ForceReset">
<div class="ConFldSetDiv">
    <table border="0" cellpadding="0" cellspacing="0" title="">
	<tr>
	    <td valign="top">
	    <div class="ConTblCl1Div"><span class="LblLev2Txt"><label for="psLbl1"><cc:text name="lblForceResetPwd" defaultValue="user.password.reset.force.reset.next.login" bundleID="amConsole" /></label>:</span></div></td>
	    <td valign="top"><div class="ConTblCl2Div"><cc:checkbox name="cbForceResetPwd" /></div></td></tr>
</table>
</div>
</jato:content>

</cc:form>


    <%--</cc:header>--%>
    </jato:useViewBean>
    </div>
    </body>
</html>
