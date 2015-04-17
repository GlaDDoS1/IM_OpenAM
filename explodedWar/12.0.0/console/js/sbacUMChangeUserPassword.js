$(function() {
    if ($('.AlrtMsgTxt').html() && $('.AlrtMsgTxt').html() == "Password was changed.") {
        window.location.href = "/auth/idm/EndUser?action=sq";
    } else {
        $('body').removeClass('display-none');
    }
});