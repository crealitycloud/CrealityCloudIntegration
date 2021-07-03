.pragma library

var api_url = ""
var os_version = ""
var duid = ""
var identical = ""

function qrLogin(callback) {
    var getQrUrl = api_url + "/api/account/qrLogin"
    sendForm(getQrUrl, "{}", callback)
}

function qrQuery(callback) {
    var getUrl = api_url + "/api/account/qrQuery"
    sendForm(getUrl, JSON.stringify({"identical": identical}), callback)
}

function getUserInfo(token, userId, callback) {
    var getUrl = api_url + "/api/cxy/v2/user/getInfo"
    sendForm(getUrl, "{}", callback, function(http) {
        http.setRequestHeader("__CXY_TOKEN_", token)
        http.setRequestHeader("__CXY_UID_", userId)
        http.setRequestHeader("__CXY_REQUESTID_", guid)
    })
}

function getVerCode(account, callback) {
    var getUrl = api_url + "/api/account/getVerifyCode"
    sendForm(getUrl, JSON.stringify({"account": account, "verifyCodeType": 6, "accountType": 1}), callback)
}

function quickLogin(phone, countryCode, verCode, callback) {
    var getUrl = api_url + "/api/account/quickLogin"
    sendForm(getUrl, JSON.stringify({ "phoneNumber": phone, "phoneAreaCode": countryCode, "verifyCode": verCode }), callback)
}

function accountLogin(type, account, password, callback) {
    var getUrl = api_url + "/api/account/loginV2"
    sendForm(getUrl, JSON.stringify({ "type": type, "account": account, "password": password }), callback)
}

//AJAX request tool
function sendForm(url, params, callback, header) {
    var http = new XMLHttpRequest()
    http.open("POST", url, true)

    http.setRequestHeader("Content-type", "application/json")
    http.setRequestHeader("__CXY_APP_ID_", "creality_model")
    http.setRequestHeader("__CXY_OS_LANG_", "0")
    http.setRequestHeader("__CXY_DUID_", duid)
    http.setRequestHeader("__CXY_OS_VER_", os_version)
    http.setRequestHeader("__CXY_PLATFORM_", "6")
    if (header !== undefined) {
        header(http)
    }

    http.onreadystatechange = function(data) {
        var response
        if (http.readyState === XMLHttpRequest.DONE) {
            if (http.status === 200) {
                response = JSON.parse(http.responseText)
            }else {
                response = JSON.parse('{ "result": false, "message": ' + http.status +  '}')

            }
            callback(response)
        }
    }
    http.send(params);
}

function guid() {
    return 'xxxxxxxxxxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0,
            v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

function timestamp() {
    return Math.round(new Date().getTime()/1000) 
}
