@echo off
"E:\PortableApps\commandsindemand\Data\nircmd.exe" killprocess "E:\PortableApps\commandsindemand\Commands in Demand.exe"
taskkill /f /IM explorer.exe
start "" "explorer.exe"