@isTest
private class TaskListControllerTest {

    public static testMethod void testTaskListController() {
        //just a little bit of code coverage to get you by :-)
        TaskListController t = new TaskListController();        
        t.getTasks();    
        t.getDisableNext();
        t.getDisablePrevious();
        t.getTotal_size();
        t.Next();
        t.Next();
        t.Previous();  
        t.End();    
        t.getMyCommandButtons();
        t.SelectedPage='10';
        t.total_size=50;
        t.refreshGrid();        
        t.getMyCommandButtons(); 
        t.getPageNumber();
        t.getTotalPages();                       
    }

}