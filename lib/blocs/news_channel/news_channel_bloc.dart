import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:news_app/models/news_channels_headlines_model.dart';
import 'package:news_app/view_model/news_view_model.dart';
part 'news_channel_event.dart';
part 'news_channel_state.dart';

class NewsChannelBloc extends Bloc<NewsChannelEvent, NewsChannelState> {
  final NewsViewModel _newsViewModel;

  NewsChannelBloc({required NewsViewModel newsViewModel})
      : _newsViewModel = newsViewModel,
        super(NewsChannelInitial()) { // Initial state when the BLoC is created
    on<FetchNewsChannelHeadlines>(_onFetchNewsChannelHeadlines);
  }

  void _onFetchNewsChannelHeadlines(FetchNewsChannelHeadlines event, Emitter<NewsChannelState> emit,) async {
    emit(NewsChannelLoading(currentChannel: event.channelName));

    try {
      final news = await _newsViewModel.fetchNewsChannelHeadlinesApi(event.channelName);
      emit(NewsChannelLoaded(newsHeadlines: news, currentChannel: event.channelName)); // Emit loaded state on success
    }

    catch (e) {
      emit(NewsChannelError(message: e.toString(), currentChannel: event.channelName)); // Emit error state on failure
    }
  }
}