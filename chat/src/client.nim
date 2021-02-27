import os, threadpool, asyncdispatch, asyncnet
import protocol

proc connect(socket: AsyncSocket, serverAddr: string) {.async.} =
    echo("Connecting to: ", serverAddr)
    await socket.connect(serverAddr, 7687.Port)
    echo("Connected.")
    
    while true:
        let line = await socket.recvLine()
        echo("received:", line)
        let m = parseMessage(line)
        echo(m.username, " said: ", m.message)


if not os.paramCount() == 2:
    quit("Please specify the server address and user")

let serverAddr = os.paramStr(1)
let user = os.paramStr(2)
var socket = newAsyncSocket()

asyncCheck connect(socket, serverAddr)

var messageFlowVar = spawn stdin.readLine()
while true:
    if messageFlowVar.isReady:
        let message = createMessage(user, ^messageFlowVar)
        asyncCheck socket.send(message)
        messageFlowVar = spawn stdin.readLine

    asyncdispatch.poll()