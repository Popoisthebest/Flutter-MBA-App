import 'dart:convert';
import 'package:api_test/model/team.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class TeamPage extends StatelessWidget {
  TeamPage({super.key});

  List<Team> teams = [];

  // get team
  Future getTeams() async {
    const String apiUrl = "https://api.balldontlie.io/v1/teams";
    const String apiKey = "d531a72c-1a15-4f55-9155-d2fa812dfa9a";

    final response =
        await http.get(Uri.parse(apiUrl), headers: {'Authorization': apiKey});
    var jsonData = jsonDecode(response.body);

    // json데이터에서 data부분을 eachTeam에 넣기
    for (var eachTeam in jsonData['data']) {
      final team = Team(
        abbreviation: eachTeam['abbreviation'],
        city: eachTeam['city'],
      );
      teams.add(team);
    }
  }

  @override
  Widget build(BuildContext context) {
    getTeams();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teams' Page"),
      ),
      body: FutureBuilder(
        future: getTeams(),
        builder: (context, snapshot) {
          // 로딩 완료 시 팀 데이터 표시
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: teams.length, // itemCount 추가
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(teams[index].abbreviation),
                      subtitle: Text(teams[index].city),
                    ),
                  ),
                );
              },
            );
          }
          // 로딩 중이라면 로딩 인디케이터 표시
          else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
