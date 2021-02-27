import asyncdispatch, asyncnet

type
    Client = ref object
        socket: AsyncSocket
        netAddr: string
        id: int
        connected: bool
    
    Server = ref object
        socket: AsyncSocket
        clients: seq[Client]

proc newServer(): Server = Server(socket: newAsyncSocket(), clients: @[])

proc `$`(client: Client): string = $client.id & "(" & client.netAddr & ")"

proc processMessages(server: Server, client: Client) {.async.} =
    while true:
        let line = await client.socket.recvLine
        if line.len == 0:
            echo(client, " disconnected.")
            client.connected = false
            client.socket.close()
            break

        echo(client, " sent: ", line)
        for c in server.clients:
            if c.id != client.id and c.connected:
                await c.socket.send(line & "\c\l")

proc loop(server: Server, port = 7687) {.async.} =
    server.socket.bindAddr(port.Port)
    server.socket.listen()

    while true:
        let (netAddr, clientSocket) = await server.socket.acceptAddr()
        echo("Accepted connection from: ", netAddr)
        let client = Client(
            socket: clientSocket,
            netAddr: netAddr,
            id: server.clients.len,
            connected: true
        )
        server.clients.add(client)
        asyncCheck processMessages(server, client)

var server = newServer()
waitFor loop(server)

# when isMainModule:
    # var future = newFuture[int]()
    # doAssert not future.finished

    # proc callback(future: Future[int]) = echo("Future value:", future.read())
    # future.addCallback(callback)
    
    # future.complete(42)
    # #future.fail(newException(ValueError, "The future failed"))
    # doAssert future.finished
    # echo "Ran isMainModule"
    # asyncdispatch.runForever()
    # import asyncfile

    # var file = openAsync("/etc/passwd")
    # let dataFut = file.readAll()
    # dataFut.callback = proc(future: Future[string]) = echo(future.read())
    # asyncdispatch.runForever()

    # proc readFiles() {.async.} = 
    #     var file = openAsync("/etc/passwd")
    #     let data = await file.readAll()
    #     echo(data)
    #     file.close()

    # waitFor readFiles()

