/*****************************************************************************/
/* Trigger name: SalesPlanOwnerUpdate                                        */
/* Author: Saikishore Aengareddy                                             */
/* Last modified: 08/29/2010                                                 */
/* Purpose: Used to provide unit test coverage for SalesPlanOwnerUpdate      */
/*****************************************************************************/

@isTest
private class SalesplanOwnerTestClass {
    static testMethod void validateSalesPlanOwner() {
        //User
        Profile p = [select id from profile where name='Custom-Zimmer Sales'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,timezonesidkey='America/Los_Angeles',
                          username='zimmeruser@testorg.com',Region__c='AM', Geography__c='US', Business_Division__c='DN');
        insert u;
        System.debug('-----SalesplanOwnerTestClass.validateSalesPlanOwner-u----- = ' + u);
        System.runAs(u){
        // Insert account
        Account acct = new Account();
        
        // get a record type
        //String rtId = [select id from RecordType where SObjectType = 'Account' and IsActive = true and Name = 'Distributor'].Id;
        String rtId = [select id from RecordType where SObjectType = 'Account' and IsActive = true and DeveloperName = 'Distributor'].Id;
        
        // populate the required fields
        acct.RecordTypeId = rtId;
        acct.Name = 'TEST ACCOUNT1';
        acct.BillingCountry = 'US';   
       
        acct.ShippingCountry = 'US';  
       
        acct.BillingState='AL'; 
          
        acct.ShippingState ='AL';
       
        acct.BillingStreet ='Test street123 dr';
        acct.Sales_Plan_Owner__c = u.id;
        insert acct;
        
        // Insert account
        Account acct1 = new Account();
        
        // get a record type
        //String rtId1 = [select id from RecordType where SObjectType = 'Account' and IsActive = true and Name = 'Physician'].Id;
        String rtId1 = [select id from RecordType where SObjectType = 'Account' and IsActive = true and DeveloperName = 'Physician'].Id;
        
        // populate the required fields
        acct.RecordTypeId = rtId1;
        acct1.FirstName = 'TEST FIRST';
        acct1.LastName = 'TEST ACCOUNT2';
        acct1.BillingCountry = 'US';   
        acct1.PersonOtherCountry= 'US';   
        acct1.ShippingCountry = 'US';   
        acct1.PersonMailingCountry = 'US';   
        acct1.BillingState='AL'; 
        acct1.PersonMailingState='AK';
        acct1.PersonOtherState='AK';
        acct1.ShippingState ='AL';
        acct1.PersonOtherState='AL';
        acct1.BillingStreet ='Test street dr';
        acct1.PersonMailingStreet ='Test street two dr';
        acct1.PersonMailingStreet ='Sample street dr';
        acct1.PersonMailingCity='LA';        
        acct1.PersonMailingPostalCode='10106';
        insert acct1;

        //Insert Contact
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Doe';
        c.Email = 'test@zimmer.com';
        c.AccountId = acct.Id;
        c.RecordTypeId = '012800000002DoB';
        
        insert c;
        
        //Insert Opportunity
        Opportunity oppty = new opportunity();
        oppty.Amount = 1000.0;
        oppty.StageName = 'Commitment';
        oppty.Name = 'TEST POA OPPTY';
        oppty.Type = 'Opportunity';
        oppty.Competitor__c = 'TEST COMPETITOR22';
        oppty.CloseDate = Date.Today().addDays(60);
       // oppty.AccountId = acct1.Id;
        oppty.Primary_sales_associate__c = c.id;
        // insert the opportunity
        insert oppty;
        Id spOwner = [select sales_plan_owner__c from Account where 
        Name = 'TEST ACCOUNT1' and BillingStreet ='Test street123 dr' limit 1].sales_plan_owner__c;
        Id opOwner = [select ownerId from opportunity where competitor__c = 'TEST COMPETITOR22' limit 1].OwnerId;
        system.assertEquals(spOwner, opOwner);
        }         
    }
}