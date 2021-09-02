@isTest
public class TestClassProfile {

   public static testMethod void checkROSAKneeAccess() {

      List<Profile> lstPrfls = [SELECT Id, Name FROM Profile where 	UserLicense.Name = 'Salesforce' order by Name LIMIT 15 OFFSET 75];
       
       for (Profile p :lstPrfls) {
          User u2 = new User(Alias = 'newUser', Email='newuser@testorg'+p.Id+'.com',
             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
             LocaleSidKey='en_US', ProfileId = p.Id,
             TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg'+p.Id+'.com');
           
           System.debug('The Profile : '+p.Name);
    
          System.runAs(u2) {
             // The following code runs as user u2.                     
    
             List<String> availableOppTypes = 
                MV_Util.GetAvailableRecordTypeNamesForSObject(Opportunity.SObjectType);
              System.debug('Current User: ' + UserInfo.getUserName()+ ' - ' + UserInfo.getProfileId());  
          }
           
          //delete u2;
       }
   }
}