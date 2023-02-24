#  CompositeTableDataSource tests

Что хотим протестировать?

1. При подключении CompositeTableDataSource к TableView без провайдеров таблица остается пустой
2. При подключении провайдера у него вызывается метод registerCells
3. При отключении провайдера у него вызывается метод unregisterCells
4. При вызове у CompositeTableDataSource метода viewWillAppesr, он вызывает reloadIfNeeded для всех провайдеров
5. При подключении провайдера в таблице появляется одна секция с содержимым, данным провайдером
6. При изменении данных провайдера и вызове onNeedsDisplay таблица обновляет содержимое
7. При назначении провайдеру нового хедера и вызове onNeedsDisplay этот хедер появляется в таблице 
8. При назначении провайдеру нового футера и вызове onNeedsDisplay этот футер появляется в таблице 
9. При изменении у провайдера isVisible и вызове onNeedsDisplay соответстующая ему секция скрывается и отображается согласно выполенному изменению
10. Повторный вызов onNeedsDisplay у провайдера не влечет повторного вызова reloadData или beginUpdates у таблицы.



    willDisplay
    didEndDisplaying