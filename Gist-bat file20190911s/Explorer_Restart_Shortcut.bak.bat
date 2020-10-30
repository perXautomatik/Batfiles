@echo off
"E:\random\PortableApps\commandsindemand\Data\nircmd.exe" killprocess "E:\random\PortableApps\commandsindemand\Commands in Demand.exe"
taskkill /f /IM explorer.exe
start "" "explorer.exe"