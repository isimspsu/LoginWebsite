function ValidateSave() {
    var status1 = $("#ddldrp option:selected").text();
    if (status1 == "--Select--") {
        $("#ddldrp").css("border", "1px solid red");
        return false;
    } else {
        $("#ddldrp").css("border", "1px solid silver");
    }
}