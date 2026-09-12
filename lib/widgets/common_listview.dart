import 'package:flutter/material.dart';

enum ViewType { list, grid }

class CommonListView<T> extends StatefulWidget {
  final List<T> items;
  final ViewType viewType;

  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final Widget emptyWidget;
  // ✅ ADD THESE
  final int gridColumnCount;
  final double childAspectRatio;

  const CommonListView({
    super.key,
    required this.items,
    required this.viewType,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.emptyWidget,
    this.gridColumnCount = 2,
    this.childAspectRatio = 0.89,
  });

  @override
  State<CommonListView<T>> createState() => _CommonListViewState<T>();
}

class _CommonListViewState<T> extends State<CommonListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _isLoadingMore = true;

      widget.onLoadMore().then((_) {
        _isLoadingMore = false; // allow next load after API
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.items.isEmpty
          ? ListView(
              controller: _scrollController,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: widget.emptyWidget,
                ),
              ],
            )
          : widget.viewType == ViewType.list
          ? _buildList()
          : _buildGrid(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridColumnCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
