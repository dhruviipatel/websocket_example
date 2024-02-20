import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DissmissKeyboard(
      child: MaterialApp(
        title: 'Web socket example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(
          channel: IOWebSocketChannel.connect('ws://echo.websocket.org'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final WebSocketChannel channel;
  const MyHomePage({super.key, required this.channel});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

TextEditingController message = TextEditingController();
List mylist = [];

class _MyHomePageState extends State<MyHomePage> {
  void _sendMessage() {
    if (message.text.isNotEmpty) {
      widget.channel.sink.add(message.text);

      setState(() {
        mylist.add(message.text);
      });

      message.text = '';
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _removeMessage(index) {
    setState(() {
      mylist.remove(index);
    });
  }

  //show data without stream builder
  // @override
  // void initState() {
  //   widget.channel.stream.listen((data) {
  //     setState(() {
  //       mylist.add(message.text);
  //     });
  //   });
  //   super.initState();
  // }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Form(
                  child: TextFormField(
                controller: message,
                decoration: const InputDecoration(hintText: "Type Message"),
              )),
              if (mylist.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                      itemCount: mylist.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(mylist[index]),
                          trailing: IconButton(
                              onPressed: () {
                                _removeMessage(mylist[index]);
                              },
                              icon: const Icon(Icons.remove)),
                        );
                      }),
                ),
              // StreamBuilder(
              //     stream: widget.channel.stream,
              //     builder: (context, snapshot) {
              //       if (mylist.isNotEmpty) {
              //         return Expanded(
              //           child: ListView.builder(
              //               itemCount: mylist.length,
              //               itemBuilder: (context, index) {
              //                 return ListTile(
              //                   title: Text(mylist[index]),
              //                   trailing: IconButton(
              //                       onPressed: () {
              //                         _removeMessage(mylist[index]);
              //                       },
              //                       icon: const Icon(Icons.remove)),
              //                 );
              //               }),
              //         );
              //       }
              //       return Container();
              //     })
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _sendMessage();
          },
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
}

class DissmissKeyboard extends StatelessWidget {
  final Widget child;
  const DissmissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentfocuse = FocusScope.of(context);
        if (!currentfocuse.hasPrimaryFocus &&
            currentfocuse.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}
