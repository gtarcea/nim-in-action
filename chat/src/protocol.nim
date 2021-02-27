import json

type
    Message* = object
        username*: string
        message*: string

proc parseMessage*(data: string): Message =
    let jsonObj = parseJson(data)
    result = to(jsonObj, Message)

proc createMessage*(username, message: string): string =
    result = $(%{
        "username": %username,
        "message": %message
    }) & "\c\l"
    
when isMainModule:
    let data = """{"username": "John", "message": "hello"}"""
    let parsed = data.parseMessage
    doAssert parsed.username == "John"
    doAssert parsed.message == "hello"
    let m = Message(username: "bob", message: "my message")
    echo %m
    echo "All tests passed"