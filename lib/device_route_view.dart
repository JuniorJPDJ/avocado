import 'package:flutter/material.dart';

class DeviceRoute extends StatefulWidget {
  DeviceRouteState createState() => DeviceRouteState();
}

class NewItem {
  bool isExpanded;
  final String header;
  final Widget body;
  final Icon iconpic;

  NewItem(this.isExpanded, this.header, this.body, this.iconpic);
}

class DeviceRouteState extends State<DeviceRoute> {
  List<NewItem> items = <NewItem>[
    NewItem(
        false, // isExpanded ?
        'Header', // header
        Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(children: <Widget>[
              Text('data'),
              Text('data'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('data'),
                  Text('data'),
                  Text('data'),
                ],
              ),
              Radio(value: null, groupValue: null, onChanged: null)
            ])), // body
        Icon(Icons.image) // iconPic
        ),
  ];
  ListView listCriteria;

  Widget build(BuildContext context) {
    listCriteria = ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                items[index].isExpanded = !items[index].isExpanded;
              });
            },
            children: items.map((NewItem item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                      leading: item.iconpic,
                      title: Text(
                        item.header,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ));
                },
                isExpanded: item.isExpanded,
                body: item.body,
              );
            }).toList(),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Device Route"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: listCriteria,
    );
  }
}
