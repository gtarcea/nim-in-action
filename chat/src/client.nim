import os, threadpool

if os.paramCount() == 0:
    quit("Please specify the server address")

let serverAddr = os.paramStr(1)

echo("Connect to: ", serverAddr)

while true:
    let message = spawn stdin.readLine
    echo("Sending: ", ^message)