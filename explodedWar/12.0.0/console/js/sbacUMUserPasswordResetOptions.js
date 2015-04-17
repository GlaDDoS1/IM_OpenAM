$(function() {


    if ($.cookie('gotoURL')) {
        var base64Matcher = new RegExp("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})$");
        gotoURL = $.cookie('gotoURL');
        if (base64Matcher.test(gotoURL)) {
            gotoURL = $.base64.decode(gotoURL);
        }
    } else {
        gotoURL = "http://sbac.portal.airast.org/field-test/";
    }

    if ($('.AlrtMsgTxt').html() && $('.AlrtMsgTxt').html() == "The properties were saved successfully.") {
        $.removeCookie('gotoURL', { path: '/auth/'});
        if ($.cookie('passwordChange')) {
            $.removeCookie('passwordChange', { path: '/auth/'});
        }
        if (gotoURL.match("^/SSORedirect/metaAlias/sbac/idp")) {
            gotoURL = "/auth" + gotoURL;
        }
        window.location.href = gotoURL;
    } else {
        $('body').removeClass('display-none');
    }

    $('.TxtFld').keyup(function () {
        if ($(this).val() == "") {
            $(this).closest("tr").find("input[type=checkbox]").attr("checked", false);
        } else {
            $(this).closest("tr").find("input[type=checkbox]").attr("checked", true);
        };
    });

});