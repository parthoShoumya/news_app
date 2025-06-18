part of 'news_channel_bloc.dart';

@immutable
abstract class NewsChannelEvent extends Equatable {
  const NewsChannelEvent();

  @override
  List<Object> get props => [];
}

class FetchNewsChannelHeadlines extends NewsChannelEvent {
  final String channelName;

  const FetchNewsChannelHeadlines({required this.channelName});

  @override
  List<Object> get props => [channelName];
}