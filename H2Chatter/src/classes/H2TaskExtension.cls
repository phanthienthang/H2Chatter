public with sharing class H2TaskExtension{
    
    public H2TaskExtension(ApexPages.StandardController iStdCtrl) {
        Task lTasks = (Task)iStdCtrl.getRecord();
    }

}