public with sharing class H2FollowerCtrl {
	
	List<EntitySubscription> followers {get; set;}
	
	public H2FollowerCtrl()  {
		followers = [select id, subscriberid, subscriber.name
											from EntitySubscription  
											where parentid =:UserInfo.getUserId()]; // the id of the user/record for which you want to list followers
	    
	    Integer noOfFollowers = followers.size();
	}

}