import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:the_pink_club2/core/models/service_provider_model.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowData extends StatefulWidget {
  final String item;
  const ShowData({required this.item, super.key});

  @override
  State<ShowData> createState() => _ShowDataState();
}

class _ShowDataState extends State<ShowData> {
  final String apiUrl =
      "https://sheets.googleapis.com/v4/spreadsheets/1LwRP1cl9EHcdUPbjfJojujeTSzfv2kZAA4i0FAA4Skk/values/Sheet1?key=AIzaSyC37ENyw6zsqoX4hJzaxuTRfuNxERrgCrk";

  List<ServiceProvider> allServiceProviders = [];
  List<ServiceProvider> filteredProviders = [];
  List<String> governorates = [];
  String? selectedGovernorate;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey("values")) {
          final List<dynamic> values = jsonData["values"];

          if (values.isNotEmpty) {
            final List rows = values.skip(3).toList();
            Set<String> governorsSet = {};
            List<ServiceProvider> providersList = [];

            for (var row in rows) {
              if (row.length > 1) {
                final provider = ServiceProvider.fromRawList(row);
                if (provider.type.contains(widget.item)) {
                  providersList.add(provider);
                  governorsSet.add(provider.governorate);
                }
              }
            }

            setState(() {
              allServiceProviders = providersList;
              governorates = governorsSet.toList();
              filterData();
            });
          }
        }
      } else {
        throw Exception('خطأ في تحميل البيانات: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = "فشل تحميل البيانات، تأكد من اتصال الإنترنت.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData() {
    setState(() {
      filteredProviders =
          allServiceProviders
              .where(
                (provider) =>
                    selectedGovernorate == null ||
                    provider.governorate == selectedGovernorate,
              )
              .toList();
    });
  }

  List<String> _splitPhoneNumbers(String phoneNumbers) {
    return phoneNumbers
        .split('/')
        .map((number) => number.trim())
        .where((number) => number.isNotEmpty)
        .toList();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'تعذر فتح تطبيق الهاتف';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر الاتصال: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCallDialog(BuildContext context, String phoneNumbers) {
    final List<String> numbers = _splitPhoneNumbers(phoneNumbers);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 80.w : 20.w,
            vertical: isLandscape ? 20.h : 80.h,
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone,
                    size: isLandscape ? 28.w : 32.w,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'اختر رقم للاتصال',
                  style: TextStyle(
                    fontSize: isLandscape ? 16.sp : 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: isLandscape ? 120.h : null,
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          numbers.map((number) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.phone,
                                  color: AppColors.primary,
                                ),
                                title: Text(
                                  number,
                                  style: TextStyle(
                                    fontSize: isLandscape ? 14.sp : 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _makePhoneCall(number);
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar:
            isLandscape
                ? null
                : AppBar(
                  iconTheme: const IconThemeData(color: Colors.white),
                  backgroundColor: AppColors.primary,
                  title: Text(
                    widget.item,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
        body: SafeArea(
          top: !isLandscape,
          child: RefreshIndicator(
            onRefresh: fetchData,
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD31F75),
                      ),
                    )
                    : errorMessage != null
                    ? Center(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(fontSize: isLandscape ? 14.sp : 16.sp),
                      ),
                    )
                    : Column(
                      children: [
                        if (!isLandscape) SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 16.w : 8.w,
                            vertical: isLandscape ? 8.h : 0,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedGovernorate,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.w),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 1.w,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: isLandscape ? 8.h : 12.h,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            hint: Text(
                              "اختر المحافظة",
                              style: TextStyle(
                                fontSize: isLandscape ? 14.sp : 16.sp,
                              ),
                            ),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGovernorate = newValue;
                                filterData();
                              });
                            },
                            items:
                                governorates.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: isLandscape ? 14.sp : 16.sp,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        SizedBox(height: isLandscape ? 8.h : 0),
                        Expanded(
                          child:
                              filteredProviders.isEmpty
                                  ? Center(
                                    child: Text(
                                      "لا توجد بيانات متاحة",
                                      style: TextStyle(
                                        fontSize: isLandscape ? 14.sp : 16.sp,
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isLandscape ? 16.w : 8.w,
                                      vertical: 8.h,
                                    ),
                                    itemCount: filteredProviders.length,
                                    itemBuilder: (context, index) {
                                      final provider = filteredProviders[index];
                                      return Card(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: isLandscape ? 4.w : 8.w,
                                          vertical: 8.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.w,
                                          ),
                                        ),
                                        elevation: 2,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal:
                                                isLandscape ? 12.w : 16.w,
                                            vertical: isLandscape ? 8.h : 12.h,
                                          ),
                                          leading: Icon(
                                            Icons.business,
                                            color: AppColors.primary,
                                            size: isLandscape ? 28.w : 32.w,
                                          ),
                                          title: Text(
                                            provider.name,
                                            style: TextStyle(
                                              fontSize:
                                                  isLandscape ? 16.sp : 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding: EdgeInsets.only(top: 8.h),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _infoRow(
                                                  Icons.location_on,
                                                  provider.governorate,
                                                ),
                                                _infoRow(
                                                  Icons.place,
                                                  provider.address,
                                                ),
                                                _infoRow(
                                                  Icons.phone,
                                                  provider.phone,
                                                  isLink: true,
                                                  onTap: () {
                                                    _showCallDialog(
                                                      context,
                                                      provider.phone,
                                                    );
                                                  },
                                                ),
                                                _infoRow(
                                                  Icons.discount,
                                                  provider.discount,
                                                  color: Colors.green,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text, {
    bool isLink = false,
    Color color = Colors.grey,
    VoidCallback? onTap,
  }) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isLandscape ? 16.w : 18.w, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  isLink
                      ? InkWell(
                        onTap: onTap,
                        child: Text(
                          text.replaceAll('/', ' / '),
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: isLandscape ? 12.sp : 14.sp,
                          ),
                        ),
                      )
                      : Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: isLandscape ? 12.sp : 14.sp),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
