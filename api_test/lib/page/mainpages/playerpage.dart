import 'dart:convert';
import 'package:api_test/page/detailpages/playersdetali.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../model/player.dart';

String searchText = '';

// ignore: must_be_immutable
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  List<Player> players = [];
  List<Player> filteredPlayers = []; // 필터링된 선수들을 위한 리스트

  Future getplayers() async {
    const String apiUrl = "https://api.balldontlie.io/v1/players";
    const String apiKey = "d531a72c-1a15-4f55-9155-d2fa812dfa9a";

    final response =
        await http.get(Uri.parse(apiUrl), headers: {'Authorization': apiKey});
    var jsonData = jsonDecode(response.body);
    List<Player> tempList = [];
    for (var eachPlayer in jsonData['data']) {
      tempList.add(Player(
        first_name: eachPlayer['first_name'],
        last_name: eachPlayer['last_name'],
        jersey_number: eachPlayer['jersey_number'].toString(),
        weight: eachPlayer['weight_poundsd'].toString(),
        height: eachPlayer['height_feet'].toString(),
        position: eachPlayer['position'],
        country: eachPlayer['country'], // API에서 'country' 필드는 제공되지 않으므로 가정
        team_name: eachPlayer['team']['abbreviation'],
      ));
    }

    setState(() {
      players = tempList;
      filteredPlayers = players; // 초기에는 모든 선수를 보여줍니다.
    });
  }

  // 검색 로직 추가
  void _filterPlayers(String enteredKeyword) {
    List<Player> results = [];
    if (enteredKeyword.isEmpty) {
      // 검색어가 비어있으면 모든 선수를 표시
      results = players;
    } else {
      // 검색어에 맞는 선수를 필터링
      results = players
          .where((player) =>
              player.first_name
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              player.last_name
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // 결과 반영
    setState(() {
      filteredPlayers = results;
    });
  }

  @override
  void initState() {
    super.initState();
    getplayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Players' Page"),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: '검색어를 입력해주세요.',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _filterPlayers(value);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlayers.length, // 필터링된 리스트 사용
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerDetailPage(
                            first_name: filteredPlayers[index].first_name,
                            last_name: filteredPlayers[index].last_name,
                            height: filteredPlayers[index].height,
                            weight: filteredPlayers[index].weight,
                            position: filteredPlayers[index].position,
                            country: filteredPlayers[index].country,
                            team_name: filteredPlayers[index].team_name,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(
                            "${filteredPlayers[index].first_name} ${filteredPlayers[index].last_name}"),
                        subtitle: Text(
                            "등번호: ${filteredPlayers[index].jersey_number}"),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
