
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:dio_http/dio_http.dart';
import 'package:dio_http/adapter.dart';
import 'package:xpath_parse/xpath_selector.dart';
import 'dart:convert';
import 'package:fast_gbk/fast_gbk.dart';

class Tiezi{
  String author = "";
  String link = "";
  String title = "";
}

//筛选什么作者出来
List<String> authors = ["sug210","mikeandlily","shot","新高"];

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
main() async{


  // HttpClient client = new HttpClient();
  // client.findProxy = (url) {
  //   return HttpClient.findProxyFromEnvironment(
  //       url, environment: {"http_proxy": "127.0.0.1:7790", "https_proxy": "127.0.0.1:7790"});
  // };
  // final request = await client.getUrl(Uri.parse(
  //     'http://www.mitbbs.com/bbsdoc/Stock.html'));
  // final response = await request.close();
  // final contentAsString = await gbk.decodeStream(response);


  // Response  response = await dio.get("http://www.mitbbs.com/bbsdoc/Stock.html",options: Options(
  // responseDecoder: (msg, opt, bd) => gbk.decode(msg)
  // ));
  // print(response.data.toString());
  // contentType: ContentType("application", "json", charset: "gbk"),
  // responseDecoder: (msg, opt, bd) => gbk.decode(msg)
  HttpOverrides.global = MyHttpOverrides();
  var future = await http.get(Uri.parse("http://www.mitbbs.com/bbsdoc/Stock.html"),headers: {
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
  for(var a in res){
    print(a);
  }

}