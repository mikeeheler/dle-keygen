function generateCodes() {
    let sysopName = document.getElementById("sysop_name");
    let sysopCode = document.getElementById("sysop_code");
    let code = getCode(sysopName.value);
    sysopCode.innerHTML = code;

    let bbsName = document.getElementById("bbs_name");
    let bbsCode = document.getElementById("bbs_code");
    code = getCode(bbsName.value);
    bbsCode.innerHTML = code;
}

function getCode(inputValue) {
    let result = "";
    for (let i = 0; i < inputValue.length; i++) {
        let code = inputValue.charCodeAt(i);
        let encoded = code ^ rngTable[i];
        let hex = encoded.toString(16);
        while (hex.length < 2) { hex = "0" + hex }
        result += hex;
    }
    return result.toUpperCase();
}
