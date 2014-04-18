public with sharing class H2FollowingCtrl {
	
	public List<EntitySubscription> followings {get; set;}
	public String mAccountJson;
	public String mAccSubscript {get; set;}
	
	public H2FollowingCtrl() {
		Map<String, AccountFollowDetail> lAccountMap = new Map<String, AccountFollowDetail>();
		
		List<String> lAccountIds = new List<String>();
		
		for (EntitySubscription es : getAccountSubscription()) {
			lAccountIds.add(es.parentid);			
		}
		
		List<Account> lAccounts = [SELECT id, name, billingstreet from Account where id IN: lAccountIds];
		
		for (Account ac: lAccounts) {
			lAccountMap.put(ac.id, new AccountFollowDetail(ac.name, ac.billingstreet));
		}
		
		mAccSubscript = JSON.serialize(lAccountMap);
	}
	
	
	
	public List<EntitySubscription> getUserSubscription() {
		
		List<EntitySubscription> lUsers = new List<EntitySubscription>();
		String userSObjectPrefix = User.sObjectType.getDescribe().getKeyPrefix();
		
		EntitySubscription[] followingES = [select id, parentid, subscriberid, parent.name, subscriber.name
		                                    from EntitySubscription
		                                    where subscriberid =:UserInfo.getUserId()];//Set to the User's Id
		
		for( EntitySubscription es: followingES )
		{
			
			if( ('' + es.parentid).substring(0,3) == userSObjectPrefix) // users only
	        {
	           lUsers.add(es);
	        }
		}
		return lUsers;
	}
	
	public List<EntitySubscription> getAccountSubscription(){
		
		List<EntitySubscription> lES = [SELECT Id, parentid FROM EntitySubscription  WHERE SubscriberId =: Userinfo.getUserId()
		AND ParentId IN ( SELECT Id FROM Account ) LIMIT 200]; 
		return lES;		
	}
	 
	public EntitySubscription getFileSubscription(){return null;} //TODO: File Subscription, will be implemented later
	public EntitySubscription getTopicSubscription(){return null;}//TODO: Topic Subscription, will be implemented later
		
	/*
	 * Detail information of Account user's following go here.
	 */
	class AccountFollowDetail implements DetailFollowingIF {
		
		public String Name;
		public String BillingStreet;
		
		public AccountFollowDetail(String iName, String iBillingStreet) {
			this.Name = iName;
			this.BillingStreet = iBillingStreet;
		}
		
		public String getType() {
			return 'Account' ;
		}
		public String getName() {
			return Name;
		}
		
	}
	
	
	
}