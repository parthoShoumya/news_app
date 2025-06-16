import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_app/models/categories_new_model.dart';
import 'package:news_app/models/news_channels_headlines_model.dart';
import 'package:news_app/view/categories_screen.dart';
import 'package:news_app/view/news_detail_screen.dart';
import 'package:news_app/view_model/news_view_model.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum FilterList {bbcNews,bloomberg,abc,cnn,alJazeera}

class _HomeScreenState extends State<HomeScreen> {

  NewsViewModel newsViewModel = NewsViewModel();

  final BehaviorSubject<String> _selectedChannel = BehaviorSubject<String>.seeded('bbc-news');

  // FilterList? selectedMenu;

  final format = DateFormat('MMMM dd, yyyy');

  // String name = 'bbc-news';

  @override
  void dispose(){
    _selectedChannel.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 1;
    final height = MediaQuery.sizeOf(context).height * 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => CategoriesScreen()));
            },
            icon: Image.asset('images/category_icon.png',
              height: 30,
              width: 30,
            ),
        ),
        title: Text('News', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),),
        actions: [
          StreamBuilder<String>(
              stream: _selectedChannel.stream,
              builder: (context,snapshot){
                final currentChannelName = snapshot.data ?? 'bbc-news';

                FilterList? currentSelectedMenu;

                if (currentChannelName == 'bbc-news') currentSelectedMenu = FilterList.bbcNews;
                else if (currentChannelName == 'bloomberg') currentSelectedMenu = FilterList.bloomberg;
                else if (currentChannelName == 'abc-news') currentSelectedMenu = FilterList.abc;
                else if (currentChannelName == 'cnn') currentSelectedMenu = FilterList.cnn;
                else if (currentChannelName == 'al-jazeera-english') currentSelectedMenu = FilterList.alJazeera;

                return PopupMenuButton<FilterList>(
                  initialValue: currentSelectedMenu,
                  icon: Icon(Icons.more_vert, color: Colors.black,),
                  onSelected: (FilterList item){
                    String newChannelName;
                    if(FilterList.bbcNews.name == item.name){
                      newChannelName = 'bbc-news';
                    }
                    else if(FilterList.bloomberg.name == item.name){
                      newChannelName = 'bloomberg';
                    }
                    else if(FilterList.abc.name == item.name){
                      newChannelName = 'abc-news';
                    }
                    else if(FilterList.cnn.name == item.name){
                      newChannelName = 'cnn';
                    }
                    else if(FilterList.alJazeera.name == item.name){
                      newChannelName = 'al-jazeera-english';
                    }
                    else
                      newChannelName = 'bbc-news';

                    _selectedChannel.sink.add(newChannelName);

                    // Here something should be done
                    // setState(() {
                    //   selectedMenu = item;
                    // });

                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterList>>[
                    PopupMenuItem<FilterList>(
                      value: FilterList.bbcNews,
                      child: Text('BBC News'),
                    ),
                    PopupMenuItem<FilterList>(
                      value: FilterList.bloomberg,
                      child: Text('Bloomberg'),
                    ),
                    PopupMenuItem<FilterList>(
                      value: FilterList.cnn,
                      child: Text('CNN'),
                    ),
                    PopupMenuItem<FilterList>(
                      value: FilterList.alJazeera,
                      child: Text('Al Jazeera'),
                    ),
                    PopupMenuItem<FilterList>(
                      value: FilterList.abc,
                      child: Text('ABC News'),
                    ),
                  ],
                );
              })

        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: height * 0.5,
            width: width,
            child: StreamBuilder<String>(
              stream: _selectedChannel.stream,
              initialData: 'bbc-news',
              builder: (context, channelSnapshot) {
                if(!channelSnapshot.hasData){
                  return const Center(child: CircularProgressIndicator());
                }
                return FutureBuilder<NewsChannelsHeadlinesModel>(
                    future: newsViewModel.fetchNewsChannelHeadlinesApi(channelSnapshot.data!),
                    builder: (BuildContext context, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(
                          child: SpinKitCircle(
                            size: 50,
                            color: Colors.blue,
                          ),
                        );
                      }
                      else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      else if (!snapshot.hasData || snapshot.data!.articles == null) {
                        return const Center(child: Text('No articles found.'));
                      }
                      else {
                        return ListView.builder(
                            itemCount: snapshot.data!.articles!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index){

                              DateTime dateTime = DateTime.parse(snapshot.data!.articles![index].publishedAt.toString());

                              return InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    NewsDetailScreen(
                                        newsImage: snapshot.data!.articles![index].urlToImage.toString(),
                                        newsTitle: snapshot.data!.articles![index].title.toString(),
                                        newsDate: snapshot.data!.articles![index].publishedAt.toString(),
                                        author: snapshot.data!.articles![index].author.toString(),
                                        description: snapshot.data!.articles![index].description.toString(),
                                        content: snapshot.data!.articles![index].content.toString(),
                                        source: snapshot.data!.articles![index].source!.name.toString())
                                  ));
                                },
                                child: SizedBox(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: height * 0.6,
                                        width: width * 0.9,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: height * 0.02,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            imageUrl: snapshot.data!.articles![index].urlToImage.toString(),
                                            fit: BoxFit.cover,
                                            placeholder: (context,url) => Container(
                                              child: spinKit2,
                                            ),
                                            errorWidget: (context,url, error) => Icon(Icons.error_outline, color: Colors.red,),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        child: Card(
                                          elevation: 5,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child:  Container(
                                            alignment: Alignment.bottomCenter,
                                            padding: EdgeInsets.all(15),
                                            height: height * 0.22,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: width * 0.7,
                                                  child: Text(snapshot.data!.articles![index].title.toString(),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),),
                                                ),
                                                Spacer(),
                                                Container(
                                                  width: width * 0.7,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(snapshot.data!.articles![index].source!.name!.toString(),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),),
                                                      Text(format.format(dateTime),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                        );
                      }
                    }
                );
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<CategoriesNewsModel>(
                future: newsViewModel.fetchCategoriesNewsApi('general'),
                builder: (BuildContext context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: SpinKitCircle(
                        size: 50,
                        color: Colors.blue,
                      ),
                    );
                  }
                  else {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.articles!.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index){

                          DateTime dateTime = DateTime.parse(snapshot.data!.articles![index].publishedAt.toString());

                          return InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  NewsDetailScreen(
                                      newsImage: snapshot.data!.articles![index].urlToImage.toString(),
                                      newsTitle: snapshot.data!.articles![index].title.toString(),
                                      newsDate: snapshot.data!.articles![index].publishedAt.toString(),
                                      author: snapshot.data!.articles![index].author.toString(),
                                      description: snapshot.data!.articles![index].description.toString(),
                                      content: snapshot.data!.articles![index].content.toString(),
                                      source: snapshot.data!.articles![index].source!.name.toString())
                              ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data!.articles![index].urlToImage.toString(),
                                      fit: BoxFit.cover,
                                      height: height * 0.18,
                                      width: width * 0.3,
                                      placeholder: (context,url) => Container(
                                        child: Center(
                                          child: SpinKitCircle(
                                            size: 50,
                                            color: Colors.blue,
                                          ),
                                        ),// 15:00 minutes done
                                      ),
                                      errorWidget: (context,url, error) => Icon(Icons.error_outline, color: Colors.red,),
                                    ),
                                  ),
                                  Expanded(
                                      child: Container(
                                        height: height * 0.18,
                                        padding: EdgeInsets.only(left: 15),
                                        child: Column(
                                          children: [
                                            Text(snapshot.data!.articles![index].title.toString(),
                                              maxLines: 3,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                            Spacer(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(snapshot.data!.articles![index].source!.name.toString(),
                                                  maxLines: 3,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                      fontWeight: FontWeight.w600
                                                  ),
                                                ),
                                                Text(format.format(dateTime),
                                                  //maxLines: 3,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      //color: Colors.black54,
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                    );
                  }
                }
            ),
          ),
        ],
      ),
    );
  }
}

const spinKit2 = SpinKitFadingCircle(
    color: Colors.amber,
    size: 50,
);
