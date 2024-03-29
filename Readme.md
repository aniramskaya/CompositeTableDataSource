#  Composite table data source

Composite table data source is a convenience UITavleView data source and delegate which decouples UITableView and its constroller from section implementation details. Section cells, header and footer are provided by TableViewSectionProvider which simplifies all the operations needed to maintain section content while keeping flexibility of UITableView.
  
Composite table data source supports differential table updates which minimizes changes to the UITableView when its content is changing. It also minimizes the number of potential table updates by postponing data reloading requests from TableViewSectionProviders to the next RunLoop cycle.

Section providers provide views for header and footer as well as an array of TableItems. TableItem is a protocol which contains minimum information to let composite table data source to perform diffing operations and to automatically dequeue cell corresponding to the item. As TableItem is a protocol, its implementations may have the semantics needed for certain section provider - they may be just a pure cell placeholders containing minimum information or models to be displayed in cells. 
