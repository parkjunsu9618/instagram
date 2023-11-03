import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'notifications.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => Store1()),
        ChangeNotifierProvider(create: (c) => Store2()),
      ],
      child: MaterialApp(
        theme: style.theme,
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var scrollDirection = 0;
  var data = [];
  var getNumber = 0;
  var userImage;

  void saveData() async {
    var storage = await SharedPreferences.getInstance();

    var savedData = storage.getString('savedData') ?? '데이터없음';
    if (savedData == '데이터없음') {
      getData();
      return;
    } else {
      setState(() {
        data = jsonDecode(savedData);
      });
      print("sharedpreferences 작동중 !!!!!!!!!!!!!!!!!");
      print(savedData);
    }
  }

  void updateSaveData(updateData) async {
    print("업데이트중!!!!!!!!!!!!!!!!!!!!!!");

    var storage = await SharedPreferences.getInstance();
    storage.setString("savedData", jsonEncode(updateData));

    var re = storage.getString("savedData") ?? "데이터없음";
    print(jsonDecode(re));
  }

  void getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if (result.statusCode == 200) {
      var result2 = jsonDecode(result.body);
      updateSaveData(result2);
      setState(() {
        data = result2;
      });
    } else {
      print("서버에러");
    }
  }

  void moreData() async {
    var re = await http
        .get(Uri.parse("https://codingapple1.github.io/app/more1.json"));
    if (re.statusCode == 200) {
      var re2 = jsonDecode(re.body);

      if (data[data.length - 1]["id"] == re2["id"]) {
        print("같은데이터 업데이트 안함");
        return;
      } else {
        setState(() {
          getNumber++;
          data.add(re2);
          updateSaveData(data);
        });
      }
    } else {
      print("서버에러");
    }
  }

  void bottomBarHide(int scrollValue) {
    setState(() {
      scrollDirection = scrollValue;
    });
  }

  void createPost(user, content) async {
    var myData = {
      'id': 99,
      'image': userImage,
      'likes': 0,
      'date': 'July 24',
      'content': content,
      'liked': false,
      'user': user
    };
    setState(() {
      data.insert(0, myData);
      updateSaveData(data);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initNotification(context);
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Instagram",
        ),
        actions: [
          IconButton(
            onPressed: () async {
              //여러이미지 //var image = await picker.pickMultiImage(source: ImageSource.gallery);
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              } else {
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => UploadWidget(
                      userImage: userImage, createPost: createPost),
                ),
              );
            },
            icon: Icon(Icons.add_box_outlined),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNotification2();
        },
        child: Icon(Icons.notification_add),
      ),
      body: [
        HomeWidget(
            data: data, moreData: moreData, bottomBarHide: bottomBarHide),
        Text("샵페이지")
      ][tab],
      bottomNavigationBar: [
        BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (i) {
            setState(() {
              tab = i;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "홈",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: "샵",
            ),
          ],
        ),
        BottomAppBar()
      ][scrollDirection],
    );
  }
}

class UploadWidget extends StatelessWidget {
  UploadWidget({super.key, this.userImage, this.createPost});
  final userImage;
  final createPost;

  var user = TextEditingController();
  var content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("글작성"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              createPost(user.text, content.text);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(userImage),
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    controller: user,
                    decoration: InputDecoration(hintText: "글작성자"),
                  ),
                  TextField(
                    controller: content,
                    decoration: InputDecoration(hintText: "글내용"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, this.data, this.moreData, this.bottomBarHide});
  final data;
  final moreData;
  final bottomBarHide;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  var scroll = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //왼쪽에 있는 변수가 변할 때마다
    scroll.addListener(() {
      //여기코드 실행해줌.

      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        // 데이터 가져오기.
        widget.moreData();
      }

      if (scroll.position.userScrollDirection == ScrollDirection.reverse) {
        widget.bottomBarHide(1);
      } else {
        widget.bottomBarHide(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
        itemCount: widget.data.length,
        controller: scroll,
        itemBuilder: (context, index) {
          return Column(
            children: [
              widget.data[index]["image"].runtimeType == String
                  ? CachedNetworkImage(
                      // 1번
                      imageUrl: widget.data[index]["image"].toString(),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  : Image.file(
                      widget.data[index]["image"],
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "좋아요수 : ${widget.data[index]["likes"]}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      child: Text("글쓴이 : ${widget.data[index]["user"]}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => Profile(),
                              transitionsBuilder: (c, a1, a2, child) =>
                                  FadeTransition(
                                    opacity: a1,
                                    child: child,
                                  )),
                        );
                      },
                    ),
                    Text("글내용 : ${widget.data[index]["content"]}"),
                  ],
                ),
              )
            ],
          );
        },
      );
    } else {
      return Text("로딩중");
    }
  }
}

class Store1 extends ChangeNotifier {
  var name = 'junsu park';
  var follower = 0;
  var followState = false;

  var profileImage = [];

  void getDate() async {
    var response = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var re = jsonDecode(response.body);
    profileImage = re;
    notifyListeners();
  }

  changeName() {
    name = 'alalalal1111';
    notifyListeners();
  }

  void following() {
    !followState ? follower++ : follower--;
    followState = !followState;
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier {
  var name = 'mizin';
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    // TODO: implement initState
    context.read<Store1>().getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<Store2>().name),
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: ProfileHeader(),
        ),
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Container(
                child: Image.network(context.watch<Store1>().profileImage[i])),
            childCount: context.watch<Store1>().profileImage.length,
          ),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        ),
      ]),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text("팔로워 ${context.watch<Store1>().follower}명"),
          trailing: !context.watch<Store1>().followState
              ? TextButton(
                  onPressed: () {
                    context.read<Store1>().following();
                  },
                  child: Text(
                    "팔로우",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                )
              : TextButton(
                  onPressed: () {
                    context.read<Store1>().following();
                  },
                  child: Text(
                    "언팔로우",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
        ),
      ],
    );
  }
}
