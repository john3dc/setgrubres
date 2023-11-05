#!/bin/sh

GRUB_CONFIG="/etc/default/grub"

delete_line() {
    local pattern="$1"
    local file="$2"
    sed -i "/^${pattern}/d" "${file}"
}

add_line() {
    local line="$1"
    local file="$2"
    echo "${line}" >> "${file}"
}

show_help() {
    echo "Usage: $(basename $0) [-r resolution] [-h]"
    echo
    echo "  -r  Set the GRUB resolution (e.g., -r 1024x768)"
    echo "  -h  Display this help and exit"
    exit 0
}

is_valid_resolution() {
    local resolution="$1"
    if ! echo "${resolution}" | grep -Eq '^[1-9][0-9]*x[1-9][0-9]*$'; then
        echo "Invalid resolution format. Please use the format WidthxHeight (e.g., 1024x768)."
        exit 1
    fi
}

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

while getopts 'hr:' OPTION; do
    case "$OPTION" in
        r) resolution=$OPTARG;;
        h) show_help;;
        ?) show_help;;
    esac
done

if [ -z "$resolution" ]; then
    echo -n "Enter the System-Resolution (e.g., 1024x768): "
    read resolution
fi

is_valid_resolution "$resolution"

if [ -f "$GRUB_CONFIG" ]; then
    delete_line "GRUB_GFXMODE=" "$GRUB_CONFIG"
    delete_line "GRUB_GFXPAYLOAD_LINUX=" "$GRUB_CONFIG"

    add_line "GRUB_GFXMODE=${resolution}" "$GRUB_CONFIG"
    add_line "GRUB_GFXPAYLOAD_LINUX=keep" "$GRUB_CONFIG"

    echo "Resolution set to ${resolution} in /etc/default/grub."
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "The file $GRUB_CONFIG does not exist."
fi
