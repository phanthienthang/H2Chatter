public with sharing class UploadAsynController {

	public String selectedWorkspace {get; set;}
	public List<SelectOption> availableWorkspaces {get; set;}
	
	public void prepareWorkSpaceList() {
	
		availableWorkspaces = new List<Selectoption>();	
		Map<ID, ContentWorkspace> mapWorkspace = new Map<ID, ContentWorkspace>();
		List<ContentVersion> contentsList = new List<ContentVersion>();
		
		for (ContentWorkspace workspace: [select name, id from  ContentWorkspace order by Name]) {
			ContentVersion content = new ContentVersion();
			content.PathOnClient = '';
			content.VersionData = Blob.valueOf('Hello');
			content.FirstPublishLocationId = workspace.id;
			contentsList.add(content);
			mapWorkspace.put(workspace.id, workspace);
		}
		
		Savepoint sp = Database.setSavepoint();
		Database.Saveresult[] results = Database.insert(contentsList, false);
		Map<Id, String> mapErrors = new Map<Id, String>();
		for (Integer index = 0; index < results.size(); index++) {
			Database.Saveresult result = results.get(index);
			ContentVersion con = contentsList.get(index);
			
			if (result.isSuccess()) {
				if (selectedWorkspace == null || selectedWorkspace == '') {
					selectedWorkspace = con.FirstPublishLocationId;
				}
				availableWorkspaces.add(new Selectoption(con.FirstPublishLocationId, mapWorkspace.get(con.FirstPublishLocationId).name));
			} // End if
			
		} //for
		
		Database.rollback(sp);
	
	} //Prepare workspace list
	
	//static testMethod void myUnitTest() {
		//Test.startTest();
		//Pagereference pageRef = Page.AsynUploadPage;
		//Test.setCurrentPageReference(pageRef)
		//UploadAsynController uCtrl = new UploadAsynController();
		//uCtrl.prepareWorkSpaceList();
		//uCtrl.selectedWorkspace = uCtrl.availableWorkspaces.get(0).getValue();
		//Test.stopTest();
	//}
}