#!/bin/bash

# Iterate through all standard folders, ignoring hidden ones
find "$HOME" -not -path '*/\.*' -type d 2>/dev/null | while read -r dir; do
    
    # ---------------------------------------------------------
    # WIZARD-GENERATED FOLDERS
    # ---------------------------------------------------------
    WIZARD=$(getfattr -n user.wizard --only-values "$dir" 2>/dev/null)
    
    if [ "$WIZARD" = "true" ]; then
        FW_HOURS=$(getfattr -n user.fw_hours --only-values "$dir" 2>/dev/null)
        CW_HOURS=$(getfattr -n user.cw_hours --only-values "$dir" 2>/dev/null)
        DEL_METHOD=$(getfattr -n user.del_method --only-values "$dir" 2>/dev/null)
        CTIME=$(getfattr -n user.creation_time --only-values "$dir" 2>/dev/null)
        
        NOW=$(date +%s)
        
        # 1. Handle Content Wiping
        if [ -n "$CW_HOURS" ] && [ "$CW_HOURS" -gt 0 ]; then
            CW_MINS=$((CW_HOURS * 60))
            if [ "$DEL_METHOD" = "permanent" ]; then
                find "$dir" -type f -mmin +"$CW_MINS" -exec rm -f {} +
            else
                find "$dir" -type f -mmin +"$CW_MINS" -exec /usr/bin/trash-put {} +
            fi
        fi
        
        # 2. Handle Entire Folder Wiping
        if [ -n "$FW_HOURS" ] && [ "$FW_HOURS" -gt 0 ] && [ -n "$CTIME" ]; then
            DIFF=$((NOW - CTIME))
            FW_SEC=$((FW_HOURS * 3600))
            
            if [ "$DIFF" -ge "$FW_SEC" ]; then
                
                # SAFETY: If this is an unlocked Vault, unmount it first
                if mountpoint -q "$dir"; then
                    fusermount -u "$dir"
                fi
                
                CIPHER_DIR="$(dirname "$dir")/.$(basename "$dir").cipher"
                
                if [ "$DEL_METHOD" = "permanent" ]; then
                    rm -rf "$dir"
                    if [ -d "$CIPHER_DIR" ]; then rm -rf "$CIPHER_DIR"; fi
                else
                    /usr/bin/trash-put "$dir"
                    if [ -d "$CIPHER_DIR" ]; then /usr/bin/trash-put "$CIPHER_DIR"; fi
                fi
            fi
        fi
        
        # Skip the legacy checks below for Wizard folders
        continue 
    fi
    
    # ---------------------------------------------------------
    # LEGACY FOLDERS (Backward Compatibility)
    # ---------------------------------------------------------
    TYPE=$(getfattr -n user.folder_type --only-values "$dir" 2>/dev/null)
    
    if [ "$TYPE" = "content_48" ]; then
        find "$dir" -type f -mmin +2880 -exec /usr/bin/trash-put {} +
        
    elif [ "$TYPE" = "folder_24" ]; then
        CTIME=$(getfattr -n user.creation_time --only-values "$dir" 2>/dev/null)
        if [ -n "$CTIME" ]; then
            NOW=$(date +%s)
            DIFF=$((NOW - CTIME))
            if [ "$DIFF" -ge 86400 ]; then
                /usr/bin/trash-put "$dir"
            fi
        fi
    fi
done
