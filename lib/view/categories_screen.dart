import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_app/models/categories_new_model.dart';
import 'package:news_app/view/news_detail_screen.dart';
import 'package:news_app/view_model/news_view_model.dart';
import 'package:rxdart/rxdart.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  NewsViewModel newsViewModel = NewsViewModel();

  final format = DateFormat('MMMM dd, yyyy');
  // String categoryName = 'general';

  final BehaviorSubject<String> _selectedCategory = BehaviorSubject<String>.seeded('general');

  List<String> categoriesList = [
    'general',
    'entertainment',
    'health',
    'sports',
    'business',
    'technology'
  ];

  @override
  void dispose(){
    _selectedCategory.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 1;
    final height = MediaQuery.sizeOf(context).height * 1;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: StreamBuilder<String>(
                stream: _selectedCategory.stream,
                initialData: 'general',
                builder: (context, categorySnapshot) {
                  final currentCatgegory = categorySnapshot.data!;

                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoriesList.length,
                      itemBuilder: (context,index){
                        return InkWell(
                          onTap: (){
                            _selectedCategory.sink.add(categoriesList[index]);

                            // categoryName = categoriesList[index];
                            // setState(() {}); // HERE
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: currentCatgegory == categoriesList[index]? Colors.blue: Colors.grey,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Center(child: Text(categoriesList[index].toString(), style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),)),
                            ),
                          ),
                        );
                      }
                  );
                }
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: StreamBuilder<String>(
                stream: _selectedCategory.stream,
                initialData: 'general',
                builder: (context, categorySnapshot) {
                  if(!categorySnapshot.hasData){
                    return const Center(child: CircularProgressIndicator());
                  }

                  final selectedCategoryName = categorySnapshot.data!;

                  return FutureBuilder<CategoriesNewsModel>(
                      future: newsViewModel.fetchCategoriesNewsApi(selectedCategoryName),
                      builder: (BuildContext context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(
                            child: SpinKitCircle(
                              size: 50,
                              color: Colors.blue,
                            ),
                          );
                        }

                        else if(snapshot.hasError){
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        else if (!snapshot.hasData || snapshot.data!.articles == null || snapshot.data!.articles!.isEmpty) {
                          return const Center(child: Text('No news found for this category.'));
                        }

                        else {
                          return ListView.builder(
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
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}



