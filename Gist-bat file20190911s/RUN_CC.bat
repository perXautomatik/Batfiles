@REM Runs the PRC character creator. Use of this is required due to the memory requirements
@REM caused by the 2das in 2.3+ being greater than what Java VM normally assigns.

java -Xmx200M -Xms200M -jar CC.jar > cc.log 2>&1

