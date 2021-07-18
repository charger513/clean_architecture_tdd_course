import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImpl remoteDataSource;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    remoteDataSource = NumberTriviaRemoteDataSourceImpl(client: mockClient);
  });

  void setUpMockClientSuccess200(MockClient mockClient) {
    when(mockClient.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockClientFailure404(MockClient mockClient) {
    when(mockClient.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      "should perform a GET request on a URL with number being the endpoint and with application/json header",
      () {
        // arrange
        setUpMockClientSuccess200(mockClient);
        // act
        remoteDataSource.getConcreteNumberTrivia(tNumber);
        // assert
        final uri = Uri.parse('http://numbersapi.com/$tNumber');
        verify(mockClient.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      "should return NumberTrivia when de response code is 200 (success)",
      () async {
        // arrange
        setUpMockClientSuccess200(mockClient);
        // act
        final result = await remoteDataSource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      "should throw ServerException when response code is 404 or other",
      () async {
        // arrange
        setUpMockClientFailure404(mockClient);
        // act
        final call = remoteDataSource.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      "should perform a GET request on a URL with random being the endpoint and with application/json header",
      () {
        // arrange
        setUpMockClientSuccess200(mockClient);
        // act
        remoteDataSource.getRandomNumberTrivia();
        // assert
        final uri = Uri.parse('http://numbersapi.com/random');
        verify(mockClient.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      "should return NumberTrivia when de response code is 200 (success)",
      () async {
        // arrange
        setUpMockClientSuccess200(mockClient);
        // act
        final result = await remoteDataSource.getRandomNumberTrivia();
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      "should throw ServerException when response code is 404 or other",
      () async {
        // arrange
        setUpMockClientFailure404(mockClient);
        // act
        final call = remoteDataSource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );
  });
}
