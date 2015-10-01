# Prints the bitcoin price in dollars
# Requires curl cli installed (you can change curl to wget with similar results).
# Originally based on the wan_ip checker, so it only checks once a minute.
# Uses the Coinbase.com api.  There are plenty of other API's available.
# By: Steve Cook <booyahmedia@gmail.com>
# Github: RevBooyah

run_segment() {
        local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/bitcoin.txt"
        local bitcoin

        if [ -f "$tmp_file" ]; then
                if shell_is_osx || shell_is_bsd; then
                        stat >/dev/null 2>&1 && is_gnu_stat=false || is_gnu_stat=true
                        if [ "$is_gnu_stat" == "true" ];then
                                last_update=$(stat -c "%Y" ${tmp_file})
                        else
                                last_update=$(stat -f "%m" ${tmp_file})
                        fi
                elif shell_is_linux || [ -z $is_gnu_stat]; then
                        last_update=$(stat -c "%Y" ${tmp_file})
                fi

                time_now=$(date +%s)
                update_period=60
                up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)

                if [ "$up_to_date" -eq 1 ]; then
                        bitcoin=$(cat ${tmp_file})
                fi
        fi

        if [ -z "$bitcoin" ]; then
                bitcoin=`curl -s https://coinbase.com/api/v1/prices/spot_rate | sed -e 's/^.*"amount":"\([^"]*\)".*$/\1/'`

                if [ "$?" -eq "0" ]; then
                        echo "${bitcoin}" > $tmp_file
                elif [ -f "${tmp_file}" ]; then
                        bitcoin=$(cat "$tmp_file")
                fi
        fi

        if [ -n "$bitcoin" ]; then
                echo "฿ ${bitcoin}"
        fi

    return 0
}
