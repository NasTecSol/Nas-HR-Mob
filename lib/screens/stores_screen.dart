import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/stores_model.dart';
import 'package:nashr/screens/create_stores_screen.dart';
import 'package:nashr/screens/store_detail_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/loader.dart';


class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  @override
  void initState(){
    super.initState();
    getStores();
  }

  Future<void> fetchLatestStores() async {
    setState(() {
      isLoading = true;
    });

    try {
      await getStores();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
        child: Stack(
          children: [ Column(
            children: [
              ///Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.stores,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CreateStoresScreen()));
                      },
                      icon: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: NasColors.darkBlue,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                padding:
                const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: NasColors.darkBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            isSearching = value.isNotEmpty;
                          });
                        },
                        cursorColor: NasColors.darkBlue,
                        style: GoogleFonts.inter(fontSize: 14, color: NasColors.darkBlue),
                        decoration: InputDecoration(
                          hintText:
                          '${AppLocalizations.of(context)!.search}...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          searchController.clear();
                          setState(() {
                            isSearching = false;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ///Content
              Expanded(
                child: RefreshIndicator(
                  color: NasColors.darkBlue,
                  backgroundColor: Colors.white,
                  onRefresh: fetchLatestStores,
                  child: FutureBuilder(
                      future: getStores(),
                      builder: (context , snapshot){
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loader();
                        }  if (!snapshot.hasData ||
                            singletonClass
                                .companyNotificationDataList.first.data!.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child:
                                    Lottie.asset('images/empty.json'),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noData,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemCount: singletonClass.storeModelDataList.first.data!.length,
                          itemBuilder: (context , index){
                              final stores = singletonClass.storeModelDataList.first.data![index];
                              final searchText = searchController.text.toLowerCase();
                              if (isSearching) {
                                final matchesName = stores.storeName?.toLowerCase().contains(searchText) ?? false;
                                final matchesArea = stores.area?.toLowerCase().contains(searchText) ?? false;
                                final areaCode = stores.areaCode?.toString();
                                final matchesAreaCode = areaCode?.contains(searchText) ?? false;
                                final matchesCountry = stores.country?.toLowerCase().contains(searchText) ?? false;
                                final matchesCity = stores.city?.toLowerCase().contains(searchText) ?? false;

                                if (!matchesName && !matchesArea && !matchesCity && !matchesCountry && !matchesAreaCode) {
                                  return const SizedBox.shrink();
                                }
                              }
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> StoreDetailScreen(storeData: stores,)));
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.grey.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: Image.asset('images/thisMonth.png'),
                                          ),
                                          const SizedBox(width: 5),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              stores.storeName ?? '',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(Icons.location_on,
                                            color: Colors.red,
                                          ),
                                          Text(
                                            stores.city ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                                stores.address ?? '',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                          },
                        );
                      }),
                ),
              )
            ],
          ),
            if(isLoading)
              Loader()
          ]
        ),
      ),
    );
  }

  /// API MEtHODS
 Future<StoresModel?> getStores() async {
   var client = http.Client();
   var uri = Uri.parse('${singletonClass.baseURL}/stores/getStores');
   var response = await client.get(uri , headers: singletonClass.getHeaders(),
   );
   if (response.statusCode == 200) {
     var responseBody = json.decode(response.body);
     var storesData = StoresModel.fromJson(responseBody);
     singletonClass.storeModelDataList.clear();
     singletonClass.storeModelDataList.addAll([storesData]);
     return storesData;
   }
   return null ;
 }
}
