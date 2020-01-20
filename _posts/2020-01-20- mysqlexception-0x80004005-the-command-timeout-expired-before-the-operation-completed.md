---
published: false
layout: post
title: >-
  MySqlException (0x80004005): The Command Timeout expired before the operation
  completed
author: John Smith
tags:
  - '#mysql'
  - '#aspnet'
  - '#mysqlconnector.net'
  - '#mysqlexception'
---
**MySqlException (0x80004005): The Command Timeout expired before the operation completed**

Tonight has all been about trying to get rid of some ASP.Net MVC yellow screens of death (YSOD) caused by MySQL timing out.

![2020-01-20_12_56_38_ysod.png]({{site.baseurl}}/media/2020-01-20_12_56_38_ysod.png)


**Background**

My application is a fairly old ASP.Net MVC 5 web application that used to talk to a local instance of MySQL and now has been ported the cloud (AWS) with the MySQL database migrated to use Amazon's Aurora Serverless MySQL database service. I have a few of these now. They suit certain workloads and my dev environments very well.

**Timeouts**

A page in my application is quite query heavy which wasn't a problem but would just take a little while to load. After migrating to the AWS Aurora Serverless MySQL database I started to get some intermittent timeouts.

I would get either:

`MySqlException (0x80004005): The Command Timeout expired before the operation completed`

```csharp
[MySqlException (0x80004005): The Command Timeout expired before the operation completed.]
 System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +102
 System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +64
 MySqlConnector.Protocol.Serialization.d__2.MoveNext() +690
 System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +102
 System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +64
 MySqlConnector.Protocol.Serialization.ProtocolUtility.ReadPacketAsync(BufferedByteReader bufferedByteReader, IByteHandler byteHandler, Func`1 getNextSequenceNumber, ProtocolErrorBehavior protocolErrorBehavior, IOBehavior ioBehavior) +191
 MySqlConnector.Protocol.Serialization.ProtocolUtility.DoReadPayloadAsync(BufferedByteReader bufferedByteReader, IByteHandler byteHandler, Func`1 getNextSequenceNumber, ArraySegmentHolder`1 previousPayloads, ProtocolErrorBehavior protocolErrorBehavior, IOBehavior ioBehavior) +61
 MySqlConnector.Protocol.Serialization.StandardPayloadHandler.ReadPayloadAsync(ArraySegmentHolder`1 cache, ProtocolErrorBehavior protocolErrorBehavior, IOBehavior ioBehavior) +54
 MySqlConnector.Core.ServerSession.ReceiveReplyAsync(IOBehavior ioBehavior, CancellationToken cancellationToken) +80
 System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +102
 System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +64
 MySqlConnector.Core.d__78.MoveNext() +737
 System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +102
 System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +64
 System.Threading.Tasks.ValueTask`1.get_Result() +80
 MySqlConnector.Core.d__2.MoveNext() +346
```

or:

`A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond`

```csharp
[SocketException (0x274c): A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond]
 System.Net.Sockets.Socket.Receive(Byte[] buffer, Int32 offset, Int32 size, SocketFlags socketFlags) +94
 System.Net.Sockets.NetworkStream.Read(Byte[] buffer, Int32 offset, Int32 size) +130

[IOException: Unable to read data from the transport connection: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.]
 System.Net.Sockets.NetworkStream.Read(Byte[] buffer, Int32 offset, Int32 size) +290
 System.Net.FixedSizeReader.ReadPacket(Byte[] buffer, Int32 offset, Int32 count) +32
 System.Net.Security._SslStream.StartFrameHeader(Byte[] buffer, Int32 offset, Int32 count, AsyncProtocolRequest asyncRequest) +137
 System.Net.Security._SslStream.StartReading(Byte[] buffer, Int32 offset, Int32 count, AsyncProtocolRequest asyncRequest) +171
 System.Net.Security._SslStream.ProcessRead(Byte[] buffer, Int32 offset, Int32 count, AsyncProtocolRequest asyncRequest) +270
 System.Net.Security.SslStream.Read(Byte[] buffer, Int32 offset, Int32 count) +35
 MySqlConnector.Utilities.Utility.Read(Stream stream, Memory`1 buffer) +59
 MySqlConnector.Protocol.Serialization.StreamByteHandler.g__DoReadBytesSync|6_0(Memory`1 buffer_) +101

```

**Solution**

After a quick google I was able to improve the situation with the `0x80004005): The Command Timeout` exception by telling the `MySQLConnector.NET` driver to increase the timeout by appending this to the connection string where the timeout is in seconds:

`default command timeout=120`

As I use `ServiceStack.OrmLite` I could also have added `OrmLiteConfig.CommandTimeout = 120;` in code but apending to the web.config seemed neater.

That left the rare but repeatable `A connection attempt failed because the connected party...` timeout error, that is when looking at some other code that talks to AWS Aurora MySQL Serverless databases I noticed a connection string that appended this:

`SslMode=none`

So I decided to try that and it seems to have worked!

**Sucess?!**

Perhaps its AWS database thing or perhaps the bug will still re-appear but for now success.

This is the connection string I ended up using

```xml
<add key="MYSQL_CONNECTION_STRING_RDS" value="Uid=userid;Password=pass;Server=auroa-mysql-rds.cluster-random.eu-west-1.rds.amazonaws.com;Port=3306;Database=dbname;default command timeout=120;SslMode=none" />
```

Success 🎉


