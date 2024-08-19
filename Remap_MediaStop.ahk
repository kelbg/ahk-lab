; Remaps Media Stop Button to Media Play/Pause Button
; ⚠️ Requires AHK v1.1

#NoEnv
#Persistent
#SingleInstance
#NoTrayIcon
SendMode Input

vkB2::              ; Media_Stop Button
    Send, {vkB3}    ; Media_Play_Pause Button
return
