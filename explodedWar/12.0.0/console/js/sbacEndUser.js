$(function() {

    // Hide close buttons
    $('input[value=Close]').addClass('display-none');

    var action = GetURLParameter('action');
    if (action != null) {
        switch (action) {
            case "sq":
                window.location.href = $('a[href*="iplanet-am-user-password-reset-options"]').prop('href');
                break;
            case "pw":
                $.cookie('gotoURL', document.referrer, {path: "/auth/"} );
                window.location.href = $('a[href*="ChangePassword"]').prop('href');
                break;
        }
    }
    // allow showing of the /idm/EndUser page if ?show=true is passed to it
    var show = GetURLParameter('show');
    if (show != null && show == "true") {
        $('body').removeClass('display-none');
    }

});

function GetURLParameter(sParam) {
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    if (sURLVariables.length > 0) {
        for (var i = 0; i < sURLVariables.length; i++) {
            var sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] == sParam) {
                return sParameterName[1];
            }
        }
    } else {
        return null;
    }
}

function openNewWindow(){
    return false;
}
