global with sharing class UploadFileController {
	
	public String parentId {get; set;} 
	
	
	public UploadFileController() {
		
		for (Account acc : [Select id, ownerid from account where ownerid =: Userinfo.getUserid() limit 1])
		{
			parentId = acc.id;
		}		
	}
	@RemoteAction
    global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
        /*
        parentId: The sfdc object Id this file will be attached to
        attachmentId: The record of the current Attachment file being processed
        fileName: Name of the attachment
        contentTye: Content Type of the file being attached
        base64BlobValue: Base64 encoded string of the file piece currently processing
        */
               
        //If recordId is blank this is the first part of a multi piece upload
        if(attachmentId == '' || attachmentId == null){
        	
        	Document doc = new Document();
        	doc.Body = EncodingUtil.Base64Decode(base64BlobValue);
        	doc.Name = fileName;
        	doc.ContentType = contentType;
        	doc.AuthorId = Userinfo.getUserId();
        	doc.FolderId = '00li0000001aEtl';
        	insert doc;
        	
        	//Attachment att = new Attachment();
            //att.ParentId = parentId;
            //att.OwnerId  = '001i000000kFxOlAAK';
            //att.Body = EncodingUtil.Base64Decode(base64BlobValue);
            //att.Name = fileName;
            //att.ContentType = contentType;
            //insert att;
            
            //Return the new attachment Id
            return doc.Id;
            
        }else{
        	
        	
        	for (Document doc : [select Id, Body from Document where Id = :attachmentId]){
        		 //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Document(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(doc.Body) + base64BlobValue));
        	}
        	
        	
            /*for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }*/
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }

}