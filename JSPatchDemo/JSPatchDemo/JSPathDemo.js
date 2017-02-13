require('UITableView,UITableViewCell,UIColor');
defineClass('ViewController',{
            
loadDemoTableVC: function() {
    var tableView = UITableView.alloc().initWithFrame_style(self.view().bounds(), 1);
    tableView.setDelegate(self);
    tableView.setDataSource(self);
    self.view().addSubview(tableView);
    self.setDemoTableVC(tableView);
}
            
})
            
defineClass('ViewController',{
            
tableView_numberOfRowsInSection: function(tableView, section) {
    return 8;
},
numberOfSectionsInTableView: function(tableView) {
    return 2;
},
tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
    var cell = tableView.dequeueReusableCellWithIdentifier("kID");
    if (!cell) {
        cell = require('UITableViewCell').alloc().initWithStyle_reuseIdentifier(0, "kID");
    }
    cell.setBackgroundColor(indexPath.row() % 2 == 0 ? UIColor.greenColor() : UIColor.redColor());
    return cell;
}
        
})
