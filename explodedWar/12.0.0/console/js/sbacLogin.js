$(function() {
    $("#pwHint2").html("minimum 6 characters, including one number")
    $("#pwHint3").html("enter your new password again")

    if ($("#pwHint3").length != 0) {
        if ($('input:hidden[name=isSAML]').val() == "false") {
            $('input[name="goto"]').val("/auth/idm/EndUser?action=sq");
            $('input[name="encoded"]').val("false");
        } else {
            $.cookie("passwordChange", "true", { path: '/auth/' });
        }
    }
});
