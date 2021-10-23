import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xpath_parse/xpath_selector.dart';
import 'package:fast_gbk/fast_gbk.dart';

//筛选什么作者出来
List<String> authors = ["sug210","mikeandlily","shot","straybird"];

class Tiezi{
  String author = "";
  String link = "";
  String title = "";
}

//设置全局代理
class MyHttpOverrides extends HttpOverrides {
  String _findProxy(url) {
    return HttpClient.findProxyFromEnvironment(
        url, environment: {"http_proxy": "127.0.0.1:7790","https_proxy": "127.0.0.1:7790"});
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = _findProxy;
  }
}
Future<List<Tiezi>> fetchData() async{
  List<Tiezi> res = await _fetchData("http://www.mitbbs.com/bbsdoc/Stock.html");
  res.addAll(await _fetchData("http://www.mitbbs.com/bbsdoc1/Stock_101_0.html"));
  res.addAll(await _fetchData("http://www.mitbbs.com/bbsdoc1/Stock_201_0.html"));
  res.addAll(await _fetchData("http://www.mitbbs.com/bbsdoc1/Military_1_0.html"));
  res.addAll(await _fetchData("http://www.mitbbs.com/bbsdoc1/Military_101_0.html"));
  res.addAll(await _fetchData("http://www.mitbbs.com/bbsdoc1/Military_201_0.html"));

  return res;
}


Future<List<Tiezi>> _fetchData(String url) async {
  HttpOverrides.global = MyHttpOverrides();
  var future = await http.get(Uri.parse(url),headers: {
    "Accept": "*/*",
    "Accept-Encoding": "gzip,deflate",
    "Accept-Language": "en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4",
    "Connection": "keep-alive",
    "Content-Type": " application/x-www-form-urlencoded; charset=UTF-8",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36",
  });
  var decode = new GbkDecoder(allowMalformed: true);
  var source = XPath.source(decode.convert(future.bodyBytes));
  var list = source.query('//td[@class=taolun_leftright]//tr').list();

  List<Tiezi> res = [];


  //筛选
  for(var a in list){
    for(var au in authors){
      if(a.contains(au)){
        Tiezi t = Tiezi();
        var source = XPath.source(a);
        t.title = source.query("//a[@class=news1]/text()").get();
        t.link = "http://www.mitbbs.com/" + source.query("//a[@class=news1]/@href").get();
        t.author = source.query("//a[@class=news]/text()").get();
        res.add(t);
      }
    }
  }

  return res;
}