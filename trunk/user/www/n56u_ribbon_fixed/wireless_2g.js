var wep1, wep2, wep3, wep4;

function automode_hint() {
    var gmode = document.form.rt_gmode.value;
    if ((gmode == "2" || gmode == "5" || gmode == "6") &&
        (document.form.rt_wep_x.value == 1 || document.form.rt_wep_x.value == 2 || document.form.rt_auth_mode.value == "radius" ||
            (document.form.rt_crypto.value.indexOf("tkip") == 0 && !document.form.rt_crypto.disabled))) {
        $("rt_gmode_hint").style.display = "block";
    }
    else {
        $("rt_gmode_hint").style.display = "none";
    }
}

function nmode_limitation() {
    if (document.form.rt_gmode.value == "3") {
        if (document.form.rt_auth_mode.selectedIndex == 0 && (document.form.rt_wep_x.selectedIndex == "1" || document.form.rt_wep_x.selectedIndex == "2")) {
            alert("<#WLANConfig11n_nmode_limition_hint#>");
            document.form.rt_auth_mode.selectedIndex = 0;
            document.form.rt_wep_x.selectedIndex = 0;
        }
        else if (document.form.rt_auth_mode.selectedIndex == 1) {
            alert("<#WLANConfig11n_nmode_limition_hint#>");
            document.form.rt_auth_mode.selectedIndex = 3;
            document.form.rt_wpa_mode.value = 2;
        }
        else if (document.form.rt_auth_mode.selectedIndex == 2) {
            alert("<#WLANConfig11n_nmode_limition_hint#>");
            document.form.rt_auth_mode.selectedIndex = 3;
            document.form.rt_wpa_mode.value = 2;
        }
        else if (document.form.rt_auth_mode.selectedIndex == 7) {
            alert("<#WLANConfig11n_nmode_limition_hint#>");
            document.form.rt_auth_mode.selectedIndex = 8;
        } 
		else if ((document.form.rt_auth_mode.selectedIndex == 9 || document.form.rt_auth_mode.selectedIndex == 5) && (document.form.rt_crypto.selectedIndex == 1)) {
            alert("<#WLANConfig11n_nmode_limition_hint#>");
            document.form.rt_crypto.selectedIndex = 0;
        }
        rt_auth_mode_change(0);
    }
}

function RefreshRateSetList(gmode, chg) {
    orig = document.form.WLANConfig11b_DataRate.value;
    free_options(document.form.WLANConfig11b_DataRate);
    if (gmode != "3") {
        if (gmode == "1") {
            items = new Array("1 & 2 Mbps", "Default", "All");
        }
        else {
            items = new Array("1 & 2 Mbps", "Default", "All");
        }
        if (chg) orig = 1;
    }
    else {
        items = new Array("1 & 2 Mbps", "Default");
        if (chg) orig = 1;
    }
    add_options_x(document.form.WLANConfig11b_DataRate, items, orig);
}

function change_common_rt(o, s, v) {
    change = 1;
    pageChanged = 1;
    if (v == "rt_auth_mode") {
        rt_auth_mode_change(0);
        if (o.value == "psk" || o.value == "wpa" || o.value == "owe") {
            opts = document.form.rt_auth_mode.options;

            if (opts[opts.selectedIndex].text == "WPA-Personal") {
                document.form.rt_wpa_mode.value = "1";
                automode_hint();
            }
            else if (opts[opts.selectedIndex].text == "WPA2-Personal")
                document.form.rt_wpa_mode.value = "2";
            else if (opts[opts.selectedIndex].text == "WPA3-Personal")
                document.form.rt_wpa_mode.value = "5";
            else if (opts[opts.selectedIndex].text == "WPA-Auto-Personal")
                document.form.rt_wpa_mode.value = "0";
            else if (opts[opts.selectedIndex].text == "WPA2-WPA3-Mixed")
                document.form.rt_wpa_mode.value = "6";
            else if (opts[opts.selectedIndex].text == "WPA-Enterprise")
                document.form.rt_wpa_mode.value = "3";
            else if (opts[opts.selectedIndex].text == "WPA-Auto-Enterprise")
                document.form.rt_wpa_mode.value = "4";
            else if (opts[opts.selectedIndex].text == "Enhanced Open")
                document.form.rt_wpa_mode.value = "7";

            if (o.value == "psk") {
                document.form.rt_wpa_psk.focus();
                document.form.rt_wpa_psk.select();
            }
        }
        else if (o.value == "shared") {
            document.form.rt_key1.focus();
            document.form.rt_key1.select();
        }
        nmode_limitation();
        automode_hint();
    }
    else if (v == "rt_crypto") {
        rt_auth_mode_change(0);
        nmode_limitation();
        automode_hint();
    }
    else if (v == "rt_wep_x") {
        change_wlweptype(o, "WLANConfig11b");
        nmode_limitation();
        automode_hint();
    }
    else if (v == "rt_key") {
        var selected_key = eval("document.form.rt_key" + o.value);

        selected_key.focus();
        selected_key.select();
    }
    else if (v == "rt_country_code") {
        insertChannelOption();
        insertExtChannelOption();
    }
    else if (v == "rt_channel") {
        insertExtChannelOption();
    }
    else if (v == "rt_HT_BW") {
        automode_hint();
        insertExtChannelOption();
    }
    else if (v == "rt_gmode") {
        enableExtChRows(o);
        insertExtChannelOption();
        nmode_limitation();
        automode_hint();
    }
    else if (v == "rt_guest_auth_mode_1")
    {
        rt_auth_mode_change_guest(0);
        if (o.value == "psk") {
            document.form.rt_guest_wpa_psk_1.focus();
            document.form.rt_guest_wpa_psk_1.select();
        }
        else if (o.value == "shared" || o.value == "radius") {
            document.form.rt_guest_phrase_x_1.focus();
            document.form.rt_guest_phrase_x_1.select();
        }
    }
    else if (v == "rt_guest_wep_x_1")
    {
        change_wlweptype_guest(o, "WLANConfig11b");
    }
    else if (v == "rt_guest_crypto_1") {
        rt_auth_mode_change_guest(0);
    }

    return true;
}

function change_wlweptype(o, s, isload) {
    if (o.value == "0") {
        wflag = 0;
        wep = "";

        document.form.rt_key1.value = wep;
        document.form.rt_key2.value = wep;
        document.form.rt_key3.value = wep;
        document.form.rt_key4.value = wep;
    }
    else {
        wflag = 1;

        if (document.form.rt_phrase_x.value.length > 0 && isload == 0)
            is_wlphrase("WLANConfig11b", "rt_phrase_x", document.form.rt_phrase_x);
    }

    inputCtrl(document.form.rt_phrase_x, wflag);
    inputCtrl(document.form.rt_key1, wflag);
    inputCtrl(document.form.rt_key2, wflag);
    inputCtrl(document.form.rt_key3, wflag);
    inputCtrl(document.form.rt_key4, wflag);
    inputCtrl(document.form.rt_key, wflag);

    rt_wep_change();
}

function change_wlkey(o, s) {
    if (document.form.current_page.value == "Advanced_WirelessGuest_Content.asp")
        wep = document.form.rt_guest_wep_x_1.value;
    else
        wep = document.form.rt_wep_x.value;

    if (wep == "1") {
        if (o.value.length > 10)
            o.value = o.value.substring(0, 10);
    }
    else if (wep == "2") {
        if (o.value.length > 26)
            o.value = o.value.substring(0, 26);
    }

    return true;
}

/* Used when WEP is changed */
function changeWEPType() {
    if (document.form.rt_wep.value == "0") {
        flag = 0;
    }
    else {
        flag = 1;
    }
    inputCtrl(document.form.rt_phrase_x, flag);
    inputCtrl(document.form.rt_key1, flag);
    inputCtrl(document.form.rt_key2, flag);
    inputCtrl(document.form.rt_key3, flag);
    inputCtrl(document.form.rt_key4, flag);
    inputCtrl(document.form.rt_key, flag);
}
/* Used when Authenication Method is changed */
function changeAuthType() {
    if (document.form.rt_auth_mode.value == "shared") {
        inputCtrl(document.form.rt_crypto, 0);
        inputCtrl(document.form.rt_wpa_psk, 0);
        inputCtrl(document.form.rt_wep, 1);
        inputCtrl(document.form.rt_phrase_x, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key2, 1);
        inputCtrl(document.form.rt_key3, 1);
        inputCtrl(document.form.rt_key4, 1);
        inputCtrl(document.form.rt_key, 1);
        inputCtrl(document.form.rt_wpa_gtk_rekey, 0);
    }
    else if (document.form.rt_auth_mode.value == "psk") {
        inputCtrl(document.form.rt_crypto, 1);
        inputCtrl(document.form.rt_wpa_psk, 1);
        inputCtrl(document.form.rt_wep, 1);
        inputCtrl(document.form.rt_phrase_x, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key2, 1);
        inputCtrl(document.form.rt_key3, 1);
        inputCtrl(document.form.rt_key4, 1);
        inputCtrl(document.form.rt_key, 1);
        inputCtrl(document.form.rt_wpa_gtk_rekey, 0);
    }
    else if (document.form.rt_auth_mode.value == "wpa") {
        inputCtrl(document.form.rt_crypto, 0);
        inputCtrl(document.form.rt_wpa_psk, 0);
        inputCtrl(document.form.rt_wep, 0);
        inputCtrl(document.form.rt_phrase_x, 0);
        inputCtrl(document.form.rt_key1, 0);
        inputCtrl(document.form.rt_key2, 0);
        inputCtrl(document.form.rt_key3, 0);
        inputCtrl(document.form.rt_key4, 0);
        inputCtrl(document.form.rt_key, 0);
        inputCtrl(document.form.rt_wpa_gtk_rekey, 0);
    }
    else if (document.form.rt_auth_mode.value == "radius") {
        inputCtrl(document.form.rt_crypto, 1);
        inputCtrl(document.form.rt_wpa_psk, 1);
        inputCtrl(document.form.rt_wep, 1);
        inputCtrl(document.form.rt_phrase_x, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key2, 1);
        inputCtrl(document.form.rt_key3, 1);
        inputCtrl(document.form.rt_key4, 1);
        inputCtrl(document.form.rt_key, 1);
        inputCtrl(document.form.rt_wpa_gtk_rekey, 0);
    }
    else {
        inputCtrl(document.form.rt_crypto, 0);
        inputCtrl(document.form.rt_wpa_psk, 0);
        inputCtrl(document.form.rt_wep, 1);
        inputCtrl(document.form.rt_phrase_x, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key1, 1);
        inputCtrl(document.form.rt_key, 1);
        inputCtrl(document.form.rt_wpa_gtk_rekey, 0);
    }
}
/* input : s: service id, v: value name, o: current value */
/* output: wep key1~4       */
function is_wlphrase(s, v, o) {
    var pseed = new Array;
    var wep_key = new Array(5);

    if (v == 'rt_wpa_psk')
        return(valid_WPAPSK(o));

    if (document.form.current_page.value == "Advanced_WirelessGuest_Content.asp") {
        wepType = document.form.rt_guest_wep_x_1.value;
        wepKey1 = document.form.rt_guest_key1_1;
        wepKey2 = document.form.rt_guest_key2_1;
        wepKey3 = document.form.rt_guest_key3_1;
        wepKey4 = document.form.rt_guest_key4_1;
    }
    else {    // note: current_page == "Advanced_Wireless_Content.asp"
        wepType = document.form.rt_wep_x.value;
        wepKey1 = document.form.rt_key1;
        wepKey2 = document.form.rt_key2;
        wepKey3 = document.form.rt_key3;
        wepKey4 = document.form.rt_key4;
    }

    phrase = o.value;
    if (wepType == "1") {
        for (var i = 0; i < phrase.length; i++) {
            pseed[i % 4] ^= phrase.charCodeAt(i);
        }

        randNumber = pseed[0] | (pseed[1] << 8) | (pseed[2] << 16) | (pseed[3] << 24);
        for (var j = 0; j < 5; j++) {
            randNumber = ((randNumber * 0x343fd) % 0x1000000);
            randNumber = ((randNumber + 0x269ec3) % 0x1000000);
            wep_key[j] = ((randNumber >> 16) & 0xff);
        }

        wepKey1.value = binl2hex_c(wep_key);
        for (var j = 0; j < 5; j++) {
            randNumber = ((randNumber * 0x343fd) % 0x1000000);
            randNumber = ((randNumber + 0x269ec3) % 0x1000000);
            wep_key[j] = ((randNumber >> 16) & 0xff);
        }

        wepKey2.value = binl2hex_c(wep_key);
        for (var j = 0; j < 5; j++) {
            randNumber = ((randNumber * 0x343fd) % 0x1000000);
            randNumber = ((randNumber + 0x269ec3) % 0x1000000);
            wep_key[j] = ((randNumber >> 16) & 0xff);
        }

        wepKey3.value = binl2hex_c(wep_key);
        for (var j = 0; j < 5; j++) {
            randNumber = ((randNumber * 0x343fd) % 0x1000000);
            randNumber = ((randNumber + 0x269ec3) % 0x1000000);
            wep_key[j] = ((randNumber >> 16) & 0xff);
        }

        wepKey4.value = binl2hex_c(wep_key);
    }
    else if (wepType == "2" || wepType == "3") {
        password = "";

        if (phrase.length > 0) {
            for (var i = 0; i < 64; i++) {
                ch = phrase.charAt(i % phrase.length);
                password = password + ch;
            }
        }

        password = calcMD5(password);
        if (wepType == "2") {
            wepKey1.value = password.substr(0, 26);
        }
        else {
            wepKey1.value = password.substr(0, 32);
        }

        wepKey2.value = wepKey1.value;
        wepKey3.value = wepKey1.value;
        wepKey4.value = wepKey1.value;
    }

    return true;
}

function rt_wep_change() {
    var mode = document.form.rt_auth_mode.value;
    var wep = document.form.rt_wep_x.value;

    if (mode == "psk" || mode == "wpa" || mode == "wpa2") {
        if (mode != "wpa" && mode != "wpa2") {
            inputCtrl(document.form.rt_crypto, 1);
            inputCtrl(document.form.rt_wpa_psk, 1);
        }
        inputCtrl(document.form.rt_wpa_gtk_rekey, 1);
        inputCtrl(document.form.rt_wep_x, 0);
        inputCtrl(document.form.rt_phrase_x, 0);
        inputCtrl(document.form.rt_key1, 0);
        inputCtrl(document.form.rt_key2, 0);
        inputCtrl(document.form.rt_key3, 0);
        inputCtrl(document.form.rt_key4, 0);
        inputCtrl(document.form.rt_key, 0);

        $("row_wpa3").style.display = "";
        $("row_wep1").style.display = "none";
        $("row_wep2").style.display = "none";
        $("row_wep3").style.display = "none";
        $("row_wep4").style.display = "none";
        $("row_wep5").style.display = "none";
        $("row_wep6").style.display = "none";
        $("row_wep7").style.display = "none";
    }
    else if (mode == "radius") {
        inputCtrl(document.form.rt_crypto, 0);
        inputCtrl(document.form.rt_wpa_psk, 0);
        inputCtrl(document.form.rt_wpa_gtk_rekey, 0);
        inputCtrl(document.form.rt_wep_x, 0);
        inputCtrl(document.form.rt_phrase_x, 0);
        inputCtrl(document.form.rt_key1, 0);
        inputCtrl(document.form.rt_key2, 0);
        inputCtrl(document.form.rt_key3, 0);
        inputCtrl(document.form.rt_key4, 0);
        inputCtrl(document.form.rt_key, 0);

        $("row_wpa3").style.display = "none";
        $("row_wep1").style.display = "none";
        $("row_wep2").style.display = "none";
        $("row_wep3").style.display = "none";
        $("row_wep4").style.display = "none";
        $("row_wep5").style.display = "none";
        $("row_wep6").style.display = "none";
        $("row_wep7").style.display = "none";
    }
    else {
        inputCtrl(document.form.rt_wpa_psk, 0);
        inputCtrl(document.form.rt_wpa_gtk_rekey, 0);
        inputCtrl(document.form.rt_wep_x, 1);

        $("row_wpa3").style.display = "none";
	if (mode == "owe") {
		inputCtrl(document.form.rt_crypto, 1);
		$("row_wep1").style.display = "none";
	} else {
		inputCtrl(document.form.rt_crypto, 0);
		$("row_wep1").style.display = "";
	}

        if (wep != "0") {
            inputCtrl(document.form.rt_phrase_x, 1);
            inputCtrl(document.form.rt_key1, 1);
            inputCtrl(document.form.rt_key2, 1);
            inputCtrl(document.form.rt_key3, 1);
            inputCtrl(document.form.rt_key4, 1);
            inputCtrl(document.form.rt_key, 1);

            $("row_wep2").style.display = "";
            $("row_wep3").style.display = "";
            $("row_wep4").style.display = "";
            $("row_wep5").style.display = "";
            $("row_wep6").style.display = "";
            $("row_wep7").style.display = "";
        }
        else {
            inputCtrl(document.form.rt_phrase_x, 0);
            inputCtrl(document.form.rt_key1, 0);
            inputCtrl(document.form.rt_key2, 0);
            inputCtrl(document.form.rt_key3, 0);
            inputCtrl(document.form.rt_key4, 0);
            inputCtrl(document.form.rt_key, 0);

            $("row_wep2").style.display = "none";
            $("row_wep3").style.display = "none";
            $("row_wep4").style.display = "none";
            $("row_wep5").style.display = "none";
            $("row_wep6").style.display = "none";
            $("row_wep7").style.display = "none";
        }
    }

    change_key_des();	// 2008.01 James.
}

function change_wep_type(mode, isload) {
    var cur_wep = document.form.rt_wep_x.value;
    var wep_type_array;
    var value_array;

    free_options(document.form.rt_wep_x);

    if (mode == "shared") {
        wep_type_array = new Array("WEP-64bits", "WEP-128bits");
        value_array = new Array("1", "2");
    }
    else {
        wep_type_array = new Array("None", "WEP-64bits", "WEP-128bits");
        value_array = new Array("0", "1", "2");
    }

    add_options_x2(document.form.rt_wep_x, wep_type_array, value_array, cur_wep);

    if (mode == "psk" || mode == "wpa" || mode == "wpa2" || mode == "radius")
        document.form.rt_wep_x.value = "0";

    change_wlweptype(document.form.rt_wep_x, "WLANConfig11b", isload);
}

function enableExtChRows(o) {
    if (o.value == "1" || o.value == "2")
        $("row_protect").style.display = "";
    else
        $("row_protect").style.display = "none";

    if (o.value == "0" || o.value == "1" || o.value == "4"){
        $("row_HT_BW").style.display = "none";
        $("row_HT_EXTCHA").style.display = "none";
    }else{
        $("row_HT_BW").style.display = "";
        $("row_HT_EXTCHA").style.display = "";
    }
}

function insertChannelOption() {
    var channels;
    var country = document.form.rt_country_code.value;
    var orig = document.form.rt_channel.value;
    free_options(document.form.rt_channel);

    channels = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14);

    if (country == "CA" || country == "CO" ||
        country == "DO" || country == "GT" ||
        country == "MX" || country == "NO" ||
        country == "PA" || country == "PR" ||
        country == "TW" || country == "US" ||
        country == "UZ")
        channels.splice(12,3);
    else if (country != "DB")
        channels.splice(14,1);

    var ch_v = new Array();
    for (var i = 0; i < channels.length; i++) {
        ch_v[i] = channels[i];
    }
    if (ch_v[0] == "0")
        channels[0] = "<#APChnAuto#>";

    add_options_x2(document.form.rt_channel, channels, ch_v, orig);
}

function insertExtChannelOption() {
    var wmode = document.form.rt_gmode.value;
    var CurrentCh = document.form.rt_channel.value;
    var option_length = document.form.rt_channel.options.length;
    if ((wmode == "2" || wmode == "3" || wmode == "5" || wmode == "6") && document.form.rt_HT_BW.value != "0") {
        inputCtrl(document.form.rt_HT_EXTCHA, 1);
        var x = document.form.rt_HT_EXTCHA;
        var length = document.form.rt_HT_EXTCHA.options.length;
        if (length > 1) {
            x.selectedIndex = 1;
            x.remove(x.selectedIndex);
        }

        if ((CurrentCh >= 1) && (CurrentCh <= 4)) {
            x.options[0].text = 1 * CurrentCh + 4;
            x.options[0].value = 1;
        }
        else if ((CurrentCh >= 5) && (CurrentCh <= 7)) {
            x.options[0].text = 1 * CurrentCh - 4;
            x.options[0].value = 0;
            CurrentCh = 1 * CurrentCh;
            CurrentCh += 4;
            add_a_option(document.form.rt_HT_EXTCHA, 1, CurrentCh);
            if (document.form.rt_HT_EXTCHA_old.value == 1)
                document.form.rt_HT_EXTCHA.options.selectedIndex = 1;
        }
        else if ((CurrentCh >= 8) && (CurrentCh <= 9)) {
            x.options[0].text = 1 * CurrentCh - 4;
            x.options[0].value = 0;
            if (option_length >= 14) {
                CurrentCh = 1 * CurrentCh;
                CurrentCh += 4;
                add_a_option(document.form.rt_HT_EXTCHA, 1, CurrentCh);
                if (document.form.rt_HT_EXTCHA_old.value == 1)
                    document.form.rt_HT_EXTCHA.options.selectedIndex = 1;
            }
        }
        else if (CurrentCh == 10) {
            x.options[0].text = 1 * CurrentCh - 4;
            x.options[0].value = 0;
            if (option_length > 14) {
                CurrentCh = 1 * CurrentCh;
                CurrentCh += 4;
                add_a_option(document.form.rt_HT_EXTCHA, 1, CurrentCh);
                if (document.form.rt_HT_EXTCHA_old.value == 1)
                    document.form.rt_HT_EXTCHA.options.selectedIndex = 1;
            }
        }
        else if (CurrentCh >= 11) {
            x.options[0].text = 1 * CurrentCh - 4;
            x.options[0].value = 0;
        }
        else {
            x.options[0].text = "<#APChnBelow#>";
            x.options[0].value = "0";
            add_a_option(document.form.rt_HT_EXTCHA, 1, "<#APChnAbove#>");
            if (document.form.rt_HT_EXTCHA_old.value == 1)
                document.form.rt_HT_EXTCHA.options.selectedIndex = 1;
        }
    }
    else
        inputCtrl(document.form.rt_HT_EXTCHA, 0);
}

function rt_auth_mode_change(isload) {
    var mode = document.form.rt_auth_mode.value;
    var i, cur, algos, opts; // 显式声明变量

    inputCtrl(document.form.rt_wep_x, 1);

    /* 1. 基础显示控制 */
    if (mode == "wpa" || mode == "wpa2" || mode == "psk" || mode == "owe") {
        inputCtrl(document.form.rt_crypto, 1);
        $("row_wpa1").style.display = "";
    } else {
        inputCtrl(document.form.rt_crypto, 0);
        $("row_wpa1").style.display = "none";
    }

    if (mode == "psk") {
        inputCtrl(document.form.rt_wpa_psk, 1);
        $("row_wpa2").style.display = "";
    } else {
        inputCtrl(document.form.rt_wpa_psk, 0);
        $("row_wpa2").style.display = "none";
    }

    /* 2. 处理加密算法 (Crypto) 逻辑 */
    // 先记录当前的加密算法
    cur = "";
    for (i = 0; i < document.form.rt_crypto.length; i++) {
        if (document.form.rt_crypto[i].selected) {
            cur = document.form.rt_crypto[i].value.toLowerCase();
            break;
        }
    }

    opts = document.form.rt_auth_mode.options;
    var selectedText = opts[opts.selectedIndex].text;

    if (mode == "psk" || mode == "owe") {
        if (selectedText == "WPA-Personal") {
            algos = ["TKIP"];
        } else if (selectedText == "WPA2-Personal" || selectedText == "WPA3-Personal" || selectedText == "WPA2-WPA3-Mixed" || selectedText == "Enhanced Open") {
            algos = ["AES"];
        } else {
            algos = ["AES", "TKIP+AES"];
        }
    } else if (mode == "wpa") {
        if (selectedText == "WPA-Enterprise") {
            algos = ["TKIP"];
        } else {
            algos = ["AES", "TKIP+AES"];
        }
    } else if (mode == "wpa2") {
        algos = ["AES"];
    }

    // 重新构建算法列表
    if (algos) {
        document.form.rt_crypto.length = algos.length;
        for (i = 0; i < algos.length; i++) {
            document.form.rt_crypto[i] = new Option(algos[i], algos[i].toLowerCase());
            document.form.rt_crypto[i].value = algos[i].toLowerCase();
            if (algos[i].toLowerCase() == cur) {
                document.form.rt_crypto[i].selected = true;
            }
        }
        // 如果当前加密算法不在新列表里，默认选第一个
        if (!document.form.rt_crypto[0].selected) {
            document.form.rt_crypto[0].selected = true;
        }
    }

    /* 3. 处理 PMF (保护管理帧) 逻辑 */
    if (selectedText == "WPA3-Personal" || selectedText == "Enhanced Open") {
        document.form.rt_pmf.value = 2; // Required
    } else if (selectedText == "WPA2-Personal") {
        // WPA2 只有在开启 AES 时才建议开启 PMF (可选)，这里根据你的需求设为 1 或 0
        document.form.rt_pmf.value = (document.form.rt_crypto[0].value == "aes") ? 1 : 0;
    } else {
        document.form.rt_pmf.value = 0; // Disabled
    }

    /* 4. 处理密钥索引 (Key Index) 逻辑 */
    change_wep_type(mode, isload);

    // 记录当前索引
    cur = "";
    for (i = 0; i < document.form.rt_key.length; i++) {
        if (document.form.rt_key[i].selected) {
            cur = document.form.rt_key[i].value;
            break;
        }
    }

    if (mode == "wpa" || mode == "wpa2" || mode == "psk" || mode == "radius") {
        algos = ["2", "3"];
    } else {
        algos = ["1", "2", "3", "4"];
        if (!isload) cur = "1";
    }

    document.form.rt_key.length = algos.length;
    for (i = 0; i < algos.length; i++) {
        document.form.rt_key[i] = new Option(algos[i], algos[i]);
        document.form.rt_key[i].value = algos[i];
        if (algos[i] == cur) {
            document.form.rt_key[i].selected = true;
        }
    }

    rt_wep_change();
}

function validate_wlkey(key_obj){

	var wep_type = document.form.rt_wep_x.value;
	var iscurrect = true;
	var str = "<#JS_wepkey#>";

	if(wep_type == "0")
		iscurrect = true;
	else if(wep_type == "1"){
		if(key_obj.value.length == 5 && validate_string(key_obj)){
			document.form.rt_key_type.value = 1;
			iscurrect = true;
		}
		else if(key_obj.value.length == 10 && validate_hex(key_obj)){
			document.form.rt_key_type.value = 0;
			iscurrect = true;
		}
		else{
			str += "(<#WLANConfig11b_WEPKey_itemtype1#>)";
			
			iscurrect = false;
		}
	}
	else if(wep_type == "2"){
		if(key_obj.value.length == 13 && validate_string(key_obj)){
			document.form.rt_key_type.value = 1;
			iscurrect = true;
		}
		else if(key_obj.value.length == 26 && validate_hex(key_obj)){
			document.form.rt_key_type.value = 0;
			iscurrect = true;
		}
		else{
			str += "(<#WLANConfig11b_WEPKey_itemtype2#>)";
			
			iscurrect = false;
		}
	}
	else{
		alert("System error!");
		iscurrect = false;
	}
	
	if(iscurrect == false){
		alert(str);
		
		key_obj.focus();
		key_obj.select();
	}
	
	return iscurrect;
}

