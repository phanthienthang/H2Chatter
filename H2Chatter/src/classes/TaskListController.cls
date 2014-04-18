/*
 * This source is refered from:
 * https://developer.salesforce.com/forums/ForumsMain?id=906F00000098QYIAY
 */

global with sharing class TaskListController {

    private integer counter=0;  //keeps track of the offset
    private integer list_size=20; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
        
    public string selectedPage{get;set{selectedPage=value;}}
    
    public TaskListController() {
        total_size = [select count() from Task]; //set the total size in the constructor
        selectedPage='0';
    }
    
    @RemoteAction
    global static List<TaskData> getTaskData(Map<String, String> parameter) {
    	System.debug('Parameters: '+ parameter);
    	List<TaskData> lTaskDatas = new List<TaskData>();
    	try 
    	{						
	    		for (Task lTask : [select Id, Subject, Status, Description from Task 
    							where ActivityDate =: Date.today() order by Id]) {
	    								
	    			lTaskDatas.add(new TaskData(lTask.subject, lTask.status, lTask.Description));
	    		}
	    		return lTaskDatas;
    	
    	} catch (QueryException e) {
    		ApexPages.addMessages(e);
    		return null;
    	}
    	return null;
    
    }
    
    @RemoteAction
    global static List<TaskData> getUrgentTaskData(Map<String, String> parameter) {
    	System.debug('Parameters: '+ parameter);
    	List<TaskData> lTaskDatas = new List<TaskData>();
    	try 
    	{						
	    		for (Task lTask : [select Id, Subject, Status, Description from Task 
    							where priority = 'High' order by Id]) {
	    								
	    			lTaskDatas.add(new TaskData(lTask.subject, lTask.status, lTask.Description));
	    		}
	    		return lTaskDatas;
    	
    	} catch (QueryException e) {
    		ApexPages.addMessages(e);
    		return null;
    	}
    	return null;
    
    }
    
    global class TaskData {
    	String subject;
    	String status;
    	String comment;
    	
    	public TaskData(String iSubject, String iStatus, String iComment) {
    		this.subject = iSubject;
    		this.status = iStatus;
    		this.comment = iComment;
    	}
    	
    }
    
    public Task[] getTasks() {
                
        if (selectedPage != '0') counter = list_size*integer.valueOf(selectedPage)-list_size;
        try { //we have to catch query exceptions in case the list is greater than 2000 rows
                Task[] taskList = [select Id,Subject, Status, Description
                                     from Task 
                                     order by Id
                                     limit :list_size
                                    offset :counter];                   
                return taskList;
        
        } catch (QueryException e) {                            
                ApexPages.addMessages(e);                   
                return null;
        }        
    }
    
    public Component.Apex.pageBlockButtons getMyCommandButtons() {
        
        //the reRender attribute is a set NOT a string
        Set<string> theSet = new Set<string>();
        theSet.add('myPanel');
        theSet.add('myButtons');
                
        integer totalPages;
        if (math.mod(total_size, list_size) > 0) {
            totalPages = total_size/list_size + 1;
        } else {
            totalPages = (total_size/list_size);
        }
        
        integer currentPage;        
        if (selectedPage == '0') {
            currentPage = counter/list_size + 1;
        } else {
            currentPage = integer.valueOf(selectedPage);
        }
     
        Component.Apex.pageBlockButtons pbButtons = new Component.Apex.pageBlockButtons();        
        pbButtons.location = 'top';
        pbButtons.id = 'myPBButtons';
        
        Component.Apex.outputPanel opPanel = new Component.Apex.outputPanel();
        opPanel.id = 'myButtons';
                                
        //the Previous button will alway be displayed
        Component.Apex.commandButton b1 = new Component.Apex.commandButton();
        b1.expressions.action = '{!Previous}';
        b1.title = 'Previous';
        b1.value = 'Previous';
        b1.expressions.disabled = '{!disablePrevious}';        
        b1.reRender = theSet;

        opPanel.childComponents.add(b1);        
                        
        for (integer i=0;i<totalPages;i++) {
            Component.Apex.commandButton btn = new Component.Apex.commandButton();
            
            if (i+1==1) {
                btn.title = 'First Page';
                btn.value = 'First Page';
                btn.rendered = true;                                        
            } else if (i+1==totalPages) {
                btn.title = 'Last Page';
                btn.value = 'Last Page';
                btn.rendered = true;                            
            } else {
                btn.title = 'Page ' + string.valueOf(i+1) + ' ';
                btn.value = ' ' + string.valueOf(i+1) + ' ';
                btn.rendered = false;             
            }
            
            if (   (i+1 <= 5 && currentPage < 5)
                || (i+1 >= totalPages-4 && currentPage > totalPages-4)
                || (i+1 >= currentPage-2 && i+1 <= currentPage+2))
            {
                btn.rendered = true;
            }
                                     
            if (i+1==currentPage) {
                btn.disabled = true; 
                btn.style = 'color:blue;';
            }  
            
            btn.onclick = 'queryByPage(\''+string.valueOf(i+1)+'\');return false;';
                 
            opPanel.childComponents.add(btn);
            
            if (i+1 == 1 || i+1 == totalPages-1) { //put text after page 1 and before last page
                Component.Apex.outputText text = new Component.Apex.outputText();
                text.value = '...';        
                opPanel.childComponents.add(text);
            } 
             
        }
        
        //the Next button will alway be displayed
        Component.Apex.commandButton b2 = new Component.Apex.commandButton();
        b2.expressions.action = '{!Next}';
        b2.title = 'Next';
        b2.value = 'Next';
        b2.expressions.disabled = '{!disableNext}';        
        b2.reRender = theSet;
        opPanel.childComponents.add(b2);
                
        //add all buttons as children of the outputPanel                
        pbButtons.childComponents.add(opPanel);  
  
        return pbButtons;

    }    
    
    public PageReference refreshGrid() { //user clicked a page number        
        system.debug('**** ' + selectedPage);
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        selectedPage = '0';
        counter -= list_size;
        return null;
    }

    public PageReference Next() { //user clicked next button
        selectedPage = '0';
        counter += list_size;
        return null;
    }

    public PageReference End() { //user clicked end
        selectedPage = '0';
        counter = total_size - math.mod(total_size, list_size);
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }

    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
}