part of 'news_channel_bloc.dart';

@immutable
abstract class NewsChannelState extends Equatable {
  final String currentChannel;
  const NewsChannelState({this.currentChannel = 'bbc-news'});

  @override
  List<Object> get props => [currentChannel];
}

class NewsChannelInitial extends NewsChannelState {
  NewsChannelInitial({super.currentChannel});
}

class NewsChannelLoading extends NewsChannelState {
  const NewsChannelLoading({required super.currentChannel});

  @override
  List<Object> get props => [currentChannel];
}

class NewsChannelLoaded extends NewsChannelState {
  final NewsChannelsHeadlinesModel newsHeadlines;

  const NewsChannelLoaded({required this.newsHeadlines, required super.currentChannel});

  @override
  List<Object> get props => [newsHeadlines,currentChannel];
}

class NewsChannelError extends NewsChannelState {
  final String message;

  const NewsChannelError({required this.message, required super.currentChannel});

  @override
  List<Object> get props => [message,currentChannel];
}