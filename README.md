# parallel_scroll_view

A widget that can scroll multiple ScrollView at once

# Demo

![preview](https://media.giphy.com/media/h4xKxL7d21dQHdjGLC/giphy.gif)

```dart
class ParallelScrollViewDemo extends StatefulWidget {
  @override
  _ParallelScrollViewDemoState createState() =>
      _ParallelScrollViewDemoState();
}

class _ParallelScrollViewDemoState
    extends State<ParallelScrollViewDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ParallelScrollView(
        scrollDirection: Axis.vertical,
        behavior: ParallelScrollBehavior.Interpolate,
        padding: EdgeInsets.all(12),
        children: <Widget>[
          ParallelScrollChild(
            height: 100,
            width: 100,
            children: _getList(10, 100, 100, Colors.red),
          ),
          _buildLabel(),
          ParallelScrollChild(
            height: 100,
            width: 100,
            children: _getList(7, 100, 100, Colors.blue),
          ),
          _buildLabel(),
          ParallelScrollChild(
            height: 50,
            width: 100,
            children: _getList(10, 150, 50, Colors.yellow),
          ),
        ],
      ),
    );
  }

  Container _buildLabel() {
    return Container(
      height: 40,
      width: 100,
      margin: EdgeInsets.all(12),
      alignment: Alignment.center,
      color: Colors.green,
      child: Text("Label"),
    );
  }

  List<Widget> _getList(int count, double width, double height, Color color) {
    return List.generate(
        count,
        (i) => Container(
              margin: EdgeInsets.only(right: 12),
              alignment: Alignment.center,
              width: width,
              height: height,
              color: color,
              child: Text("Item $i"),
            ));
  }
}
```


